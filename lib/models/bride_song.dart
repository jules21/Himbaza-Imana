import 'package:indirimbo/models/searchable_song.dart';

class BrideSong implements SearchableSong {
  static const String umugeniCategoryId = '21';
  static const String wokovuCategoryId = 'wokovu';

  @override
  late String id;
  @override
  late String title;
  @override
  late String lyrics;
  late int? page;
  final String categoryId;

  BrideSong({
    required this.id,
    required this.title,
    required this.lyrics,
    this.categoryId = umugeniCategoryId,
  });

  BrideSong.fromJson(
    Map<String, dynamic> json, {
    this.categoryId = umugeniCategoryId,
  }) {
    id = json['id'].toString();
    lyrics = json['lyrics'];
    page = json['page'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lyrics': lyrics,
      'page': page,
    };
  }

  @override
  String get parent => categoryId;

  bool get usesBrideLyrics => categoryId == umugeniCategoryId;
}
