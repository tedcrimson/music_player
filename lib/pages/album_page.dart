import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_templates/ui_widgets/page.dart';
import 'package:music_player/audio_player_task.dart';
import 'package:music_player/models/album_model.dart';
import 'package:music_player/pages/my_page.dart';
import 'package:music_player/pages/player_page.dart';
import 'package:music_player/widgets/my_button.dart';
import 'package:music_player/widgets/shadow_widget.dart';

import '../const.dart';
import '../main.dart';

class AlbumPage extends Page {
  final Album album;
  AlbumPage(this.album);
  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  bool loaded = false;
  Album album;
  MediaItem currentItem;
  @override
  void initState() {
    super.initState();
    album = widget.album;
    // _loadAlbum(widget.album).then((loaded) {
    //   setState(() {
    //     this.loaded = loaded;
    //   });
    // });
  }

  Future<bool> _loadAlbum() async {
    return MyHomePageState.play(album.tracks);
  }

  @override
  Widget build(BuildContext context) {
    return MyPage(
        title: album.title,
        actions: {},
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  MyButton(
                    CupertinoIcons.heart_solid,
                    // iconSize: 30,
                    onTap: () {},
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ShadowWidget(
                          // backgroundColor: Color.fromRGBO(214, 224, 238, 1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: 8,
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: ClipOval(
                              child: GestureDetector(
                            onTap: () {
                              if (AudioService?.playbackState?.basicState !=
                                      BasicPlaybackState.none ||
                                  AudioService?.playbackState?.basicState !=
                                      BasicPlaybackState.stopped)
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (_) => PlayerPage()));
                            },
                            child: Image.network(
                              album.imageUrl,
                              fit: BoxFit.fill,
                            ),
                          )),
                        ),
                      ),
                    ),
                  ),
                  MyButton(
                    Icons.more_horiz,
                    iconSize: 30,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: album.tracks.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  MediaItem track = album.tracks[index];
                  bool isActive = track == currentItem;
                  return Material(
                    color: isActive
                        ? Color.fromRGBO(195, 209, 237, 0.6)
                        : Colors.transparent,
                    shape: isActive
                        ? RoundedRectangleBorder(
                            side: BorderSide(
                              width: 0.1,
                              color: dark,
                            ),
                            borderRadius: BorderRadius.circular(15.0))
                        : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () async {
                        if (isActive) {
                          AudioService.seekTo(0);
                        } else {
                          setState(() {
                            currentItem = track;
                          });
                          await _playTrack(currentItem);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 20.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    album.tracks[index].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: darker,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    album.title,
                                    style: TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            isActive ? activeButton() : inactiveButton()
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  Widget inactiveButton() {
    return MyButton(
      Icons.play_arrow,
      width: 40,
      height: 40,
    );
  }

  Widget activeButton() {
    bool isPlaying =
        AudioService?.playbackState?.basicState != BasicPlaybackState.paused;
    return MyButton(isPlaying ? Icons.pause : Icons.play_arrow,
        width: 40,
        height: 40,
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
        onTap: isPlaying ? AudioService.pause : AudioService.play);
  }

  Future _playTrack(MediaItem track) async {
    if (!loaded) {
      await _loadAlbum();
      loaded = true;
    }
    // return AudioService.skipToPrevious();
    return AudioService.playFromMediaId(track.id);
  }
}
