import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_templates/ui_widgets/page.dart';
import 'package:music_player/models/album_model.dart';
import 'package:music_player/pages/album_page.dart';
import 'package:music_player/pages/my_page.dart';

class MusicListPage extends Page {
  @override
  _MusicListPageState createState() => _MusicListPageState();
}

class _MusicListPageState extends State<MusicListPage> {
  List<Album> albums = [
    Album(
        artist: "Gorillaz",
        title: 'Song Machine',
        imageUrl:
            "https://images.genius.com/fb93904f2f5ba3f96713b3901da74106.1000x1000x1.jpg",
        tracks: [
          MediaItem(
            id: "https://firebasestorage.googleapis.com/v0/b/doers-app.appspot.com/o/Gorillaz%20-%20De%CC%81sole%CC%81%20ft.%20Fatoumata%20Diawara%20(Episode%20Two).mp3?alt=media&token=da47fb49-8484-40fe-bdbc-2da11adfc28a",
            album: "Song Machine",
            title: "Désolé ft. Fatoumata Diawara",
            artist: "Gorillaz",
            duration: 361000,
            artUri:
                "https://images.genius.com/fb93904f2f5ba3f96713b3901da74106.1000x1000x1.jpg",
          ),
        ]),
    Album(
        artist: "Science Friday",
        title: 'Science Friday',
        imageUrl:
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
        tracks: <MediaItem>[
          MediaItem(
            id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
            album: "Science Friday",
            title: "A Salute To Head-Scratching Science",
            artist: "Science Friday and WNYC Studios",
            duration: 5739820,
            artUri:
                "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
          ),
          MediaItem(
            id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
            album: "Science Friday",
            title: "From Cat Rheology To Operatic Incompetence",
            artist: "Science Friday and WNYC Studios",
            duration: 2856950,
            artUri:
                "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
          ),
        ])
  ];
  @override
  Widget build(BuildContext context) {
    return MyPage(
      canPop: false,
      title: 'Albums',
      child: Column(
        children: <Widget>[
          GridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              crossAxisCount: 2,
              childAspectRatio: .8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: albums
                  .map((album) => Material(
                        borderRadius: BorderRadius.circular(10),
                        elevation: 5,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AlbumPage(album)));
                          },
                          child: Column(
                            children: <Widget>[
                              Image.network(album.imageUrl),
                              Text(album.title),
                              Text(album.artist)
                            ],
                          ),
                        ),
                      ))
                  .toList()),
        ],
      ),
    );
  }
}
