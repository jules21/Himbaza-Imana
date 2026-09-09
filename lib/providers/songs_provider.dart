import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bride_song.dart';
import '../models/hymn_praise_song.dart';
import '../models/searchable_song.dart';

class SongCollectionProvider extends ChangeNotifier {
  static const _favoritesKey = 'favorite_song_keys';
  List<BrideSong> brideSongs = [];
  List<BrideSong> wokovuSongs = [];
  List<hymnPraiseSong> hymnPraiseSongs = [];
  bool isLoading = true;
  String error = '';

  // Cache for loaded lyrics
  final Map<String, String> _lyricsCache = {};
  final Set<String> _favoriteKeys = {};

  SongCollectionProvider() {
    _loadFavorites();
  }

  String _songKey(SearchableSong song) => '${song.parent}:${song.id}';

  bool isFavorite(SearchableSong song) =>
      _favoriteKeys.contains(_songKey(song));

  Iterable<hymnPraiseSong> get _searchableHymnPraiseSongs =>
      hymnPraiseSongs.where((song) => !song.isCategory());

  List<SearchableSong> get searchableSongs => [
        ..._searchableHymnPraiseSongs,
        ...brideSongs,
        ...wokovuSongs,
      ];

  List<SearchableSong> get favoriteSongs => [
        ...brideSongs,
        ..._searchableHymnPraiseSongs,
        ...wokovuSongs,
      ].where(isFavorite).toList();

  List<SearchableSong> searchSongs(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return [];

    final isSongNumber = RegExp(r'^\d+$').hasMatch(normalizedQuery);
    return searchableSongs.where((song) {
      if (isSongNumber) return song.id == normalizedQuery;
      return songTitleWithNumber(song)
              .toLowerCase()
              .contains(normalizedQuery) ||
          song.lyrics.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  String categoryLabel(SearchableSong song) {
    switch (song.parent) {
      case BrideSong.umugeniCategoryId:
        return 'Umugeni';
      case BrideSong.wokovuCategoryId:
        return 'Nyimbo za Wokovu';
      case '554':
        return 'Agakiza';
      default:
        return 'Gushimisha';
    }
  }

  Future<void> _loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    _favoriteKeys
      ..clear()
      ..addAll(preferences.getStringList(_favoritesKey) ?? const []);
    notifyListeners();
  }

  Future<void> toggleFavorite(SearchableSong song) async {
    final key = _songKey(song);
    if (!_favoriteKeys.add(key)) {
      _favoriteKeys.remove(key);
    }
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_favoritesKey, _favoriteKeys.toList());
  }

  Future<void> loadAllSongs(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final assetBundle = DefaultAssetBundle.of(context);
      final songCollectionsJson = await Future.wait([
        assetBundle.loadString('assets/Bride_songs.json'),
        assetBundle.loadString('assets/nyimbo_za_wokovu.json'),
        assetBundle.loadString('assets/hymns_praise_songs.json'),
      ]);

      final brideSongsJson = songCollectionsJson[0];
      brideSongs = (json.decode(brideSongsJson) as List)
          .map((json) => BrideSong.fromJson(json))
          .toList();

      // This collection has the same structure and lyrics format as Bride songs.
      final wokovuSongsJson = songCollectionsJson[1];
      wokovuSongs = (json.decode(wokovuSongsJson) as List)
          .map((json) => BrideSong.fromJson(
                json,
                categoryId: BrideSong.wokovuCategoryId,
              ))
          .toList();

      final hymnsPraiseSongsJson = songCollectionsJson[2];
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
    return hymnPraiseSongs.where((song) => song.parent == '0').toList();
  }

  // Get all categories
  List<hymnPraiseSong> agakizaSongs() {
    return hymnPraiseSongs.where((song) => song.parent == '554').toList();
  }
}
