import 'package:audio_service/audio_service.dart';
import 'package:music_player/models/artist_model.dart';

class Album {
  String artist;
  String title;
  String imageUrl;
  List<MediaItem> tracks;
  Album({this.artist, this.title, this.imageUrl, this.tracks});
}
