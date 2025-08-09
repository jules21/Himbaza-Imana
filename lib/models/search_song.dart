

import 'package:flutter/cupertino.dart';
import 'package:indirimbo/models/bride_song.dart';

import 'hymn_praise_song.dart';

class SongSearchResult {
  final BrideSong? song;
  final String previewText;
  final List<TextSpan> highlightedPreview;
  final hymnPraiseSong? categorySong;

  SongSearchResult({
     this.song,
    required this.previewText,
    required this.highlightedPreview,
    this.categorySong,
  });
}