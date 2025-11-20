import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../page/bride_lyrics.dart';
import '../page/unified_lyrics.dart';
class GridViewScreen extends StatefulWidget {
  const GridViewScreen({
    super.key,
    required this.songs,
  });

  final dynamic songs;

  @override
  State<GridViewScreen> createState() => _GridViewScreenState();
}

class _GridViewScreenState extends State<GridViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: widget.songs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio: 1.5),
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.all(2),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
              onPressed: () => _getSongLyrics(widget.songs[index]),
              // onPressed: () => null,
              child: Center(
                child: Text(
                  '${index +1}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          )),
    );
  }

  void _getSongLyrics(song) {
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
}
