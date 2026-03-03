import 'package:flutter/material.dart';

import '../models/view_type.dart';
import 'build_card_view.dart';
import 'build_grid_view.dart';
import 'build_list_view.dart';
// Enhanced Song View Screen
class SongViewScreen extends StatefulWidget {
  final dynamic songs;
  final ViewType viewType;

  const SongViewScreen({
    Key? key,
    required this.songs,
    required this.viewType,
  }) : super(key: key);

  @override
  State<SongViewScreen> createState() => _SongViewScreenState();
}

class _SongViewScreenState extends State<SongViewScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No songs available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    switch (widget.viewType) {
      case ViewType.grid:
        return BuildGridView(songs: widget.songs);
      case ViewType.compactGrid:
        return BuildGridView(songs: widget.songs, crossAxisCount: 6);
      case ViewType.list:
        return BuildListView(songs: widget.songs);
      case ViewType.card:
        return BuildCardView(songs: widget.songs);
    }
  }

}