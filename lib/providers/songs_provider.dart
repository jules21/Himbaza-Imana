import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/bride_song.dart';
import '../models/hymn_praise_song.dart';

class SongCollectionProvider extends ChangeNotifier{
  List<BrideSong> brideSongs = [];
  List<hymnPraiseSong> hymnPraiseSongs = [];
  bool isLoading = true;
  String error = '';

  // Cache for loaded lyrics
  final Map<String, String> _lyricsCache = {};

  Future<void> loadAllSongs(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Load bride songs collection
      final brideSongsJson = await DefaultAssetBundle.of(context)
          .loadString('assets/bride_songs.json');
      brideSongs = (json.decode(brideSongsJson) as List)
          .map((json) => BrideSong.fromJson(json))
          .toList();

      // Load hymns songs collection
      final hymnsPraiseSongsJson = await DefaultAssetBundle.of(context)
          .loadString('assets/hymns_praise_songs.json');
      hymnPraiseSongs = (json.decode(hymnsPraiseSongsJson) as List)
          .map((json) => hymnPraiseSong.fromJson(json))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Get songs for a specific category
  List<hymnPraiseSong> getSongsForCategory(String categoryId) {
    return hymnPraiseSongs
        .where((song) => song.parent == categoryId && !song.isCategory())
        .toList();
  }

  // Get all categories
  List<hymnPraiseSong> getCategories() {
    return hymnPraiseSongs.where((song) => song.isCategory()).toList();
  }
  // Get all categories
  List<hymnPraiseSong> ugushimishaSongs() {
    return hymnPraiseSongs.where((song) => song.parent =='0').toList();
  }
  // Get all categories
  List<hymnPraiseSong> agakizaSongs() {
    return hymnPraiseSongs.where((song) => song.parent == '554').toList();
  }
}