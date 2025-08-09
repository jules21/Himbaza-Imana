import 'package:indirimbo/models/searchable_song.dart';

class BrideSong{

  late String id;
  late String title;
  late String lyrics;
  late int ?page;

  BrideSong({required this.id, required this.title, required this.lyrics});


  BrideSong.fromJson(Map<String, dynamic> json){
    id = json['id'].toString();
    lyrics = json['lyrics'];
    page = json['page'];
    title = json['title'];
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'title':title,
      'lyrics':lyrics,
      'page':page,
    };
  }


}