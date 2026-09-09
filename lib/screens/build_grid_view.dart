import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../page/bride_lyrics.dart';
import '../page/unified_lyrics.dart';
import '../models/searchable_song.dart';

class BuildGridView extends StatelessWidget {
  BuildGridView({
    super.key,
    required this.songs,
    this.crossAxisCount = 4,
    this.showSongMetadata = false,
  });

  final dynamic songs;
  final int crossAxisCount;
  final bool showSongMetadata;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        crossAxisCount == 6 ? 96 : 12,
      ),
      itemCount: songs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) => _buildGridItem(index, context),
    );
  }

  void _getSongLyrics(song, int index, context) {
    final arguments = {
      'songs': List<SearchableSong>.from(songs),
      'index': index
    };
    if (song is BrideSong && song.usesBrideLyrics) {
      //pass song to another page;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const BrideLyrics(),
            settings: RouteSettings(arguments: arguments)),
      );
    } else {
      //pass song to another page;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const UnifiedLyrics(),
            settings: RouteSettings(arguments: arguments)),
      );
    }
  }

  Widget _buildGridItem(int index, context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => _getSongLyrics(songs[index], index, context),
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
                  showSongMetadata
                      ? songCatalogNumber(songs[index])
                      : '${index + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (showSongMetadata) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      songCategoryLabel(songs[index]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
