import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../page/bride_lyrics.dart';
import '../page/unified_lyrics.dart';
class BuildCardView extends StatelessWidget {
  BuildCardView({
    super.key,
    required this.songs,
  });

  final dynamic songs;

  @override
  Widget build(BuildContext context) {
    print(songs[1]);
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: songs.length,
      itemBuilder: (context, index) => _buildCardItem(index, context),
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
  Widget _buildCardItem(int index, context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _getSongLyrics(songs[index], context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueGrey[50]!,
                Colors.blueGrey[100]!,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      songs[index].title ?? 'Song ${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 16,
                          color: Colors.blueGrey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Himbaza Imana',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_filled,
                size: 40,
                color: Colors.blueGrey[700],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
