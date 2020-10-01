import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/audio_player_task.dart';
import 'package:music_player/const.dart';
import 'package:music_player/main.dart';
import 'package:music_player/pages/my_page.dart';
import 'package:music_player/widgets/my_button.dart';
import 'package:music_player/widgets/shadow_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class PlayerPage extends StatelessWidget {
  final BehaviorSubject<int> _dragPositionSubject = BehaviorSubject.seeded(null);
  // Future<bool> _loadAlbum() async {
  //   final _queue = <MediaItem>[
  //     MediaItem(
  //       id: "https://firebasestorage.googleapis.com/v0/b/doers-app.appspot.com/o/Gorillaz%20-%20De%CC%81sole%CC%81%20ft.%20Fatoumata%20Diawara%20(Episode%20Two).mp3?alt=media&token=da47fb49-8484-40fe-bdbc-2da11adfc28a",
  //       album: "Song Machine",
  //       title: "Désolé ft. Fatoumata Diawara",
  //       artist: "Gorillaz",
  //       duration: 361000,
  //       artUri:
  //           "https://images.genius.com/fb93904f2f5ba3f96713b3901da74106.1000x1000x1.jpg",
  //     ),
  //     MediaItem(
  //       id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
  //       album: "Science Friday",
  //       title: "From Cat Rheology To Operatic Incompetence",
  //       artist: "Science Friday and WNYC Studios",
  //       duration: 2856950,
  //       artUri:
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
  //     ),
  //   ];
  //   return AudioService.start(
  //     backgroundTaskEntrypoint: () async {
  //       AudioServiceBackground.run(() => AudioPlayerTask());
  //       print("ok");
  //     },
  //     androidNotificationChannelName: 'Audio Service Demo',
  //     notificationColor: 0xFF2196f3,
  //     androidNotificationIcon: 'mipmap/ic_launcher',
  //     enableQueue: true,
  //   );
  //   // return true;
  // }

  @override
  Widget build(BuildContext context) {
    return MyPage(
      title: 'Now Playing',
      actions: {},
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: StreamBuilder<ScreenState>(
        stream: Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
            AudioService.queueStream,
            AudioService.currentMediaItemStream,
            AudioService.playbackStateStream,
            (queue, mediaItem, playbackState) => ScreenState(queue, mediaItem, playbackState)),
        builder: (context, snapshot) {
          final screenState = snapshot.data;
          final queue = screenState?.queue;
          final mediaItem = screenState?.mediaItem ?? MediaItem(id: null, title: "", album: "", artist: "");
          final state = screenState?.playbackState;
          var basicState = state?.basicState ?? BasicPlaybackState.none;
          if (basicState == BasicPlaybackState.playing && state.position <= 1)
            basicState = BasicPlaybackState.connecting;
          return Column(
            children: <Widget>[
              Flexible(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ShadowWidget(
                    width: MediaQuery.of(context).size.height * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    offset: 10,
                    child: ClipOval(
                        child: mediaItem.artUri != null
                            ? Image.network(
                                mediaItem.artUri,
                                fit: BoxFit.fill,
                              )
                            : Container(color: mainColor)),
                  ),
                ),
              ),
              Spacer(
                  // height: 40,
                  ),
              Container(
                height: 30,
                child: mediaItem.title.length < 20
                    ? Text(mediaItem.title, style: TextStyle(color: darker, fontSize: 24, fontWeight: FontWeight.w600))
                    : Marquee(
                        text: mediaItem.title,
                        style: TextStyle(color: darker, fontSize: 24, fontWeight: FontWeight.w600),
                        scrollAxis: Axis.horizontal,
                        blankSpace: 50.0,
                        velocity: 50.0,
                        pauseAfterRound: Duration(seconds: 5),
                        startPadding: 0.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // accelerationDuration: Duration(seconds: 1),
                        // accelerationCurve: Curves.linear,
                        // decelerationDuration:
                        //     Duration(milliseconds: 500),
                        // decelerationCurve: Curves.easeOut,
                      ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                // "Flume ft. Vic Mensa",
                mediaItem.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // if (basicState != BasicPlaybackState.none &&
              //     basicState != BasicPlaybackState.stopped)
              positionIndicator(mediaItem, state, basicState),
              // Spacer(),
              // if (basicState == BasicPlaybackState.playing)
              //   pauseButton()
              // else if (basicState == BasicPlaybackState.paused)
              //   playButton(),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: MyButton(
                        Icons.fast_rewind,
                        width: 80,
                        height: 80,
                        iconSize: 25,
                        onTap: mediaItem == queue?.first ? () => AudioService.seekTo(0) : AudioService.skipToPrevious,
                      ),
                    ),
                    Expanded(
                      child: basicState == BasicPlaybackState.paused
                          ? MyButton(Icons.play_arrow,
                              width: 80,
                              height: 80,
                              iconSize: 25,
                              iconColor: Colors.white,
                              backgroundColor: mainColor,
                              gradient: RadialGradient(
                                center: Alignment(.5, .4),
                                colors: [
                                  // Colors.white,
                                  mainColor,
                                  Color.fromRGBO(70, 120, 255, 1),
                                ],
                                stops: [0, 1],
                                radius: 1,
                              ),
                              onTap: AudioService.play)
                          : MyButton(Icons.pause,
                              width: 80,
                              height: 80,
                              iconSize: 25,
                              iconColor: Colors.white,
                              backgroundColor: mainColor,
                              gradient: RadialGradient(
                                center: Alignment(.5, .4),
                                colors: [
                                  // Colors.white,
                                  mainColor,
                                  Color.fromRGBO(70, 120, 255, 1),
                                ],
                                stops: [0, 1],
                                radius: 1,
                              ),
                              onTap: AudioService.pause),
                    ),
                    Expanded(
                      child: MyButton(Icons.fast_forward,
                          width: 80,
                          height: 80,
                          iconSize: 25,
                          onTap: mediaItem == queue?.last ? () => AudioService.seekTo(0) : AudioService.skipToNext),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              )
              // Spacer(),
            ],
          );
        },
      ),
    );
  }

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state, BasicPlaybackState basicState) {
    int seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<int, int, int>(
          _dragPositionSubject.stream, Stream.periodic(Duration(milliseconds: 200)), (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        int position = 0;
        // print(lastUp);
        // print(state.position);
        // print(lastUp == state.position);
        if (basicState != BasicPlaybackState.connecting && basicState != BasicPlaybackState.none)
          position = snapshot.data ?? state.currentPosition;
        int duration = mediaItem?.duration ?? 11;
        return _mySlider(
            value: seekPos ?? max(0, min(position, duration)),
            maxLength: duration,
            onChange: (value) {
              _dragPositionSubject.add(value);
              AudioService.seekTo(value.toInt());
              // Due to a delay in platform channel communication, there is
              // a brief moment after releasing the Slider thumb before the
              // new position is broadcast from the platform side. This
              // hack is to hold onto seekPos until the next state update
              // comes through.
              // TODO: Improve this code.
              seekPos = value;
              _dragPositionSubject.add(null);
            });
        // return Column(
        //   children: [
        //     if (duration != null)
        //       Slider(
        //         min: 0.0,
        //         max: duration,
        //         value: seekPos ?? max(0.0, min(position, duration)),
        //         onChanged: (value) {
        //           _dragPositionSubject.add(value);
        //         },
        //         onChangeEnd: (value) {
        //           AudioService.seekTo(value.toInt());
        //           // Due to a delay in platform channel communication, there is
        //           // a brief moment after releasing the Slider thumb before the
        //           // new position is broadcast from the platform side. This
        //           // hack is to hold onto seekPos until the next state update
        //           // comes through.
        //           // TODO: Improve this code.
        //           seekPos = value;
        //           _dragPositionSubject.add(null);
        //         },
        //       ),
        //     Text("${(state.currentPosition / 1000).toStringAsFixed(3)}"),
        //   ],
        // );
      },
    );
  }

  _mySlider({int value, int maxLength, ValueChanged<int> onChange}) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (TapDownDetails a) {
          if (a.localPosition.dx > 0 && a.localPosition.dx < constraints.biggest.width) {
            onChange((a.localPosition.dx / constraints.biggest.width * maxLength).toInt());
          }
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Text(
                  _getTime(value),
                  style: TextStyle(fontSize: 10, color: dark, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child:
                    Text(_getTime(maxLength), style: TextStyle(fontSize: 10, color: dark, fontWeight: FontWeight.bold)),
              ),
              //background
              Container(
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: dim, width: 0.8),
                    gradient: LinearGradient(colors: [
                      dim,
                      Color.fromRGBO(255, 255, 255, 1)
                    ], stops: [
                      0,
                      1,
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              ),

              Container(
                height: 5,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value / maxLength,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: mainColor),
                  ),
                ),
              ),

              GestureDetector(
                onHorizontalDragUpdate: (a) {
                  if (a.localPosition.dx > 0 && a.localPosition.dx < constraints.biggest.width)
                    onChange((a.localPosition.dx / constraints.biggest.width * maxLength).toInt());
                },
                child: Container(
                  alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, value / maxLength),
                  // left: 100,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xfff0f0f0),
                        boxShadow: [BoxShadow(color: dim, offset: Offset(5, 5), spreadRadius: 1, blurRadius: 20)]),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: light,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [
                                Color.fromRGBO(214, 224, 244, 1),
                                Colors.white,
                              ], stops: [
                                0,
                                1
                              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getTime(int mili) {
    int d = mili ~/ 1000;
    String min = (d ~/ 60).toString();
    int s = d % 60;
    String sec = (s < 10 ? "0" : "") + s.toString();
    return '$min:$sec';
  }
}
