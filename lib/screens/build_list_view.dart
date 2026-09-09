import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../page/bride_lyrics.dart';
import '../page/unified_lyrics.dart';
import '../models/searchable_song.dart';
class BuildListView extends StatelessWidget {
  BuildListView({
    super.key,
    required this.songs,
    this.showSongMetadata = false,
  });

  final dynamic songs;
  final bool showSongMetadata;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: songs.length,
      itemBuilder: (context, index) => _buildListItem(index,context),
    );
  }
  void _getSongLyrics(song, int index, context) {
    final arguments = {'songs': List<SearchableSong>.from(songs), 'index': index};
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
              showSongMetadata
                  ? songCatalogNumber(songs[index])
                  : '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(
            vertical: showSongMetadata ? 12 : 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                songTitleWithoutNumber(songs[index]),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (showSongMetadata) ...[
                const SizedBox(height: 3),
                Text(
                  songCategoryLabel(songs[index]),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.blueGrey[800],
        ),
        onTap: () => _getSongLyrics(songs[index], index, context),
      ),
    );
  }
}
