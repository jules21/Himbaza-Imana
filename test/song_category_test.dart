import 'package:flutter_test/flutter_test.dart';
import 'package:indirimbo/models/bride_song.dart';
import 'package:indirimbo/models/hymn_praise_song.dart';
import 'package:indirimbo/models/searchable_song.dart';
import 'package:indirimbo/providers/songs_provider.dart';
import 'package:indirimbo/services/song_service.dart';
import 'package:indirimbo/utils/lyrics_sections.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Bride song parser can identify the Wokovu collection', () {
    final song = BrideSong.fromJson(
      {
        'id': 1,
        'title': 'Wokovu song',
        'lyrics': '1. Lyrics',
      },
      categoryId: BrideSong.wokovuCategoryId,
    );

    expect(song.id, '1');
    expect(song.parent, BrideSong.wokovuCategoryId);
    expect(song.usesBrideLyrics, isFalse);
    expect(songTitleWithNumber(song), '1. Wokovu song');
    expect(songCatalogNumber(song), '1');
    expect(songCategoryLabel(song), 'Nyimbo za Wokovu');
    expect(song.title, 'Wokovu song');
    expect(song.lyrics, '1. Lyrics');
  });

  test('Wokovu songs participate in unified collections and search input', () {
    final provider = SongCollectionProvider();
    final wokovuSong = BrideSong(
      id: '1',
      title: 'Wokovu song',
      lyrics: 'Unique Wokovu lyrics',
      categoryId: BrideSong.wokovuCategoryId,
    );
    provider.wokovuSongs = [wokovuSong];

    expect(provider.searchableSongs, contains(wokovuSong));
    expect(provider.categoryLabel(wokovuSong), 'Nyimbo za Wokovu');
    expect(
      provider.searchableSongs.where(
        (song) => song.lyrics.toLowerCase().contains('unique wokovu'),
      ),
      contains(wokovuSong),
    );
  });

  test('catalog number uses the visible Hymn Praise number instead of its id',
      () {
    final song = hymnPraiseSong(
      id: '27',
      parent: '554',
      title: '4.Niboney\' urukundo rw\'Umukiza',
      contentFile: '',
    );

    expect(songCatalogNumber(song), '4');
    expect(songCategoryLabel(song), 'Agakiza');
  });

  test('numeric search finds the matching song number without scanning lyrics',
      () {
    final provider = SongCollectionProvider();
    final numberedSong = BrideSong(
      id: '27',
      title: 'Numbered song',
      lyrics: '1. First verse',
      categoryId: BrideSong.wokovuCategoryId,
    );
    final lyricsOnlyMatch = BrideSong(
      id: '28',
      title: 'Another song',
      lyrics: '1. This lyric contains 27',
      categoryId: BrideSong.wokovuCategoryId,
    );
    provider.wokovuSongs = [numberedSong, lyricsOnlyMatch];

    expect(provider.searchSongs(' 27 '), [numberedSong]);
    expect(
      SongService().getUnifiedContextualPreview(numberedSong, '27').song,
      numberedSong,
    );
  });

  test('unnumbered Wokovu paragraphs are marked as choruses', () {
    const lyrics = '1. First verse\n\nSing the chorus\nTogether\n\n2. Second verse';

    expect(
      markUnnumberedParagraphsAsChorus(lyrics),
      '1. First verse\n\nR/Sing the chorus\nTogether\n\n2. Second verse',
    );
  });

  test('Wokovu presentation repeats its chorus after every verse', () {
    const lyrics = '1. First verse\n\nSing the chorus\n\n2. Second verse';
    final slides = presentationSections(
      parseLyrics(markUnnumberedParagraphsAsChorus(lyrics)),
    );

    expect(
      slides.map((section) => section.label),
      ['Verse 1', 'Chorus', 'Verse 2', 'Chorus'],
    );
  });
}
