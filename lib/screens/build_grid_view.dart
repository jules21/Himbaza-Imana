import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../page/bride_lyrics.dart';
import '../page/unified_lyrics.dart';
class BuildGridView extends StatelessWidget {
  BuildGridView({
    super.key,
    required this.songs,
    this.crossAxisCount = 4

  });

  final dynamic songs;
  int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        itemCount: songs.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) => _buildGridItem(index, context),
      ),
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
  Widget _buildGridItem(int index, context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => _getSongLyrics(songs[index], context),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueGrey[700]!,
                Colors.blueGrey[900]!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
