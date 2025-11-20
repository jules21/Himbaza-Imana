import 'package:flutter/material.dart';

import '../models/search_song_result.dart';
import '../models/searchable_song.dart';

 class SongService {
  TextStyle _previewTextStyle() => TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        fontStyle: FontStyle.italic,
      );

  TextStyle _highlightedTextStyle() => TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        backgroundColor: Colors.yellow[100],
      );

  // Get a contextual preview around the search term
  SongSearchResult getUnifiedContextualPreview(
      SearchableSong song, String searchTerm) {
    final searchTermLower = searchTerm.toLowerCase();
    final titleLower = song.title.toLowerCase();
    final lyricsLower = song.lyrics.toLowerCase();

    if (titleLower.contains(searchTermLower)) {
      final previewText = song.lyrics.length > 60
          ? '${song.lyrics.substring(0, 60)}...'
          : song.lyrics;

      final highlightedPreview = [
        TextSpan(
          text: previewText,
          style: _previewTextStyle(),
        ),
      ];

      return SongSearchResult(
        song: song, // assuming `SongSearchResult` accepts `SearchableSong`
        previewText: previewText,
        highlightedPreview: highlightedPreview,
      );
    } else {
      final matchIndex = lyricsLower.indexOf(searchTermLower);

      int startIndex = matchIndex - 25;
      int endIndex = matchIndex + searchTermLower.length + 25;

      if (startIndex < 0) startIndex = 0;
      if (endIndex > song.lyrics.length) endIndex = song.lyrics.length;

      final previewText = (startIndex > 0 ? '...' : '') +
          song.lyrics.substring(startIndex, endIndex) +
          (endIndex < song.lyrics.length ? '...' : '');

      final highlightedPreview = [
        if (startIndex > 0) TextSpan(text: '...', style: _previewTextStyle()),
        TextSpan(
            text: song.lyrics.substring(startIndex, matchIndex),
            style: _previewTextStyle()),
        TextSpan(
          text: song.lyrics
              .substring(matchIndex, matchIndex + searchTermLower.length),
          style: _highlightedTextStyle(),
        ),
        TextSpan(
            text: song.lyrics
                .substring(matchIndex + searchTermLower.length, endIndex),
            style: _previewTextStyle()),
        if (endIndex < song.lyrics.length)
          TextSpan(text: '...', style: _previewTextStyle()),
      ];

      return SongSearchResult(
        song: song,
        previewText: previewText,
        highlightedPreview: highlightedPreview,
      );
    }
  }


}
