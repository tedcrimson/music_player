import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_templates/ui_widgets/navigation/navigation_body.dart';
import 'package:flutter_ui_templates/ui_widgets/navigation/tabmodel.dart';
import 'package:flutter_ui_templates/ui_widgets/presence_widget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/audio_player_task.dart';
import 'package:music_player/pages/album_page.dart';
import 'package:music_player/pages/music_list_page.dart';
import 'package:music_player/pages/player_page.dart';
import 'package:music_player/pages/profile_page.dart';
import 'package:music_player/widgets/my_bottom_item.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();

  static MyHomePageState of(BuildContext context) {
    return context.findAncestorStateOfType<MyHomePageState>();
  }
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<MyBottomItem> defaultPages;

  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
    defaultPages = [
      MyBottomItem(
          TabModel(page: MusicListPage(), icon: Icons.list, name: 'Lists')),
      MyBottomItem(
          TabModel(page: ProfilePage(), icon: Icons.person, name: 'Profile')),
    ];
  }

  @override
  void dispose() {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  static Future<bool> play(List<MediaItem> queue) async {
    if (AudioService?.playbackState?.basicState == BasicPlaybackState.none ||
        AudioService?.playbackState?.basicState == BasicPlaybackState.stopped)
      await AudioService.start(
        backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'Audio Service Demo',
        notificationColor: 0xFF8B84F0,
        androidNotificationIcon: 'mipmap/ic_launcher',
        enableQueue: true,
      );

    await AudioService.removeQueueItem(MediaItem(id: "", album: "", title: ""));

    for (var item in queue) {
      await AudioService.addQueueItem(item);
    }
    await AudioService.playFromMediaId(queue.last.id);

    // AudioServiceBackground.setQueue(_queue);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: StreamBuilder<ScreenState>(
            stream: Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
                    ScreenState>(
                AudioService.queueStream,
                AudioService.currentMediaItemStream,
                AudioService.playbackStateStream,
                (queue, mediaItem, playbackState) =>
                    ScreenState(queue, mediaItem, playbackState)),
            builder: (context, snapshot) {
              final screenState = snapshot.data;
              final queue = screenState?.queue;
              final mediaItem = screenState?.mediaItem;
              final state = screenState?.playbackState;
              final basicState = state?.basicState ?? BasicPlaybackState.none;
              return Stack(
                children: <Widget>[
                  NavigationBody(
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    pages: defaultPages,
                  ),
                  // audioPlayerButton(context),
                  // stopButton(),
                ],
              );
            }));
  }
}

void audioPlayerTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

class AudioPlayerTask extends BackgroundAudioTask {
  List<MediaItem> queue = [];
  int queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => queueIndex + 1 < queue.length;

  bool get hasPrevious => queueIndex > 0;

  MediaItem get mediaItem => queue[queueIndex];

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      // case AudioPlaybackState.buffering:
      //   return BasicPlaybackState.buffering;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  @override
  Future<void> onStart() async {
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    if (queue.isNotEmpty) {
      AudioServiceBackground.setQueue(queue);
      await onSkipToNext();
    }

    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onPause();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  // @override
  // void onCustomAction(String name, arguments) async {
  //   if (name == "loadAlbum") {
  //     queue.clear();
  //     List<MediaItem> q = arguments;
  //     for (var item in q) {
  //       await AudioService.addQueueItem(item);
  //     }
  //     print("OKOKO");
  //     AudioService.skipToNext();
  //   }
  // }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final newPos = queueIndex + offset;
    if (!(newPos >= 0 && newPos < queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) {
    queue.add(mediaItem);
    AudioServiceBackground.setQueue(queue);
  }

  @override
  void onRemoveQueueItem(MediaItem mediaItem) {
    if (mediaItem.id.isEmpty) {
      queue.clear();
      queueIndex = -1;
      if (_audioPlayer != null) _audioPlayer.stop();
    }
  }

  @override
  void onPlayFromMediaId(String mediaId) async {
    int index = queue.indexWhere((x) => x.id == mediaId);
    if (index != null && index >= 0) {
      if (_playing == null) {
        // First time, we want to start playing
        _playing = true;
      } else if (_playing) {
        // Stop current item
        await _audioPlayer.stop();
      }
      MediaItem item = queue[index];

      queueIndex = index;
      AudioServiceBackground.setMediaItem(item);
      await _audioPlayer.setUrl(item.id);
      _skipState = null;
      if (_playing) {
        onPlay();
      } else {
        _setState(state: BasicPlaybackState.paused);
      }
    }
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }
}
