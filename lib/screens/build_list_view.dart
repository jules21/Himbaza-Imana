import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../page/bride_lyrics.dart';
import '../page/unified_lyrics.dart';
class BuildListView extends StatelessWidget {
  BuildListView({
    super.key,
    required this.songs,

  });

  final dynamic songs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: songs.length,
      itemBuilder: (context, index) => _buildListItem(index,context),
    );
  }
  void _getSongLyrics(song, context) {
    if (song is BrideSong) {
      //pass song to another page;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const BrideLyrics(),
            settings: RouteSettings(arguments: song)),
      );
    } else {
      //pass song to another page;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const UnifiedLyrics(),
            settings: RouteSettings(arguments: song)),
      );
    }
  }
  Widget _buildListItem(int index, context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            songs[index].title.contains('.')
                ? songs[index].title
                .substring(songs[index].title.indexOf('.') + 1)
                .trimLeft()
                : songs[index].title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.blueGrey[800],
        ),
        onTap: () => _getSongLyrics(songs[index],context),
      ),
    );
  }
}
