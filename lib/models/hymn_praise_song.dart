import 'package:indirimbo/models/searchable_song.dart';

class hymnPraiseSong implements SearchableSong{
  final String id;
  final String parent;
  final String title;
  String lyrics; // Changed to non-final to allow updating after loading
  final String contentFile;

  hymnPraiseSong({
    required this.id,
    required this.parent,
    required this.title,
    this.lyrics = '', // Default empty lyrics
    required this.contentFile,
  });

  factory hymnPraiseSong.fromJson(Map<String, dynamic> json) {
    return hymnPraiseSong(
      id: json['id'],
      parent: json['parent'],
      title: json['title'],
      contentFile: json['content'] ?? '',
      lyrics: json['lyrics'],
    );
  }

  Map toJson() {

    return {
      'id': id,
      'title': title,
      'parent': parent,
      'lyrics': lyrics,
      'contentFile': contentFile,
    };
  }

  bool isCategory() => parent == "-1";//-1: (agakiza & gushimisha), 0:gushimisha, 554: agakiza
}