

import 'package:flutter/cupertino.dart';
import 'package:indirimbo/models/searchable_song.dart';

import 'hymn_praise_song.dart';

class SongSearchResult {
  final SearchableSong song;
  final String previewText;
  final List<TextSpan> highlightedPreview;

  SongSearchResult({
    required this.song,
    required this.previewText,
    required this.highlightedPreview,
  });
}