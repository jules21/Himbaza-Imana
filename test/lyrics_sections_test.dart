import 'package:flutter_test/flutter_test.dart';
import 'package:indirimbo/utils/lyrics_sections.dart';

void main() {
  test('preserves first and final lines and repeats chorus after every verse',
      () {
    final sections = parseLyrics(
        '1. First line\nSecond line\nR/Sing together\nAgain\n2. Last verse\nFinal line');
    expect(sections.map((s) => s.text), [
      'First line\nSecond line',
      'Sing together\nAgain',
      'Last verse\nFinal line'
    ]);
    final slides = presentationSections(sections);
    expect(
        slides.map((s) => s.label), ['Verse 1', 'Chorus', 'Verse 2', 'Chorus']);
    expect(slides.last.text, 'Sing together\nAgain');
  });
  test('handles ref markers, catalogue numbers and blank lines', () {
    final slides = presentationSections(
        parseLyrics('35\r\n35. First\r\n\r\nref: Refrain\r\n\r\n2. Final'));
    expect(slides.map((s) => s.text), ['First', 'Refrain', 'Final', 'Refrain']);
  });
  test('songs without chorus retain all verses', () {
    final slides =
        presentationSections(parseLyrics('1. Alpha\n2. Beta\nLast line'));
    expect(slides.length, 2);
    expect(slides.last.text, 'Beta\nLast line');
    expect(parseLyrics(''), isEmpty);
    expect(parseLyrics('Unnumbered lyrics').single.text, 'Unnumbered lyrics');
  });
  test('a new chorus replaces the refrain for subsequent verses', () {
    final slides =
        presentationSections(parseLyrics('1. A\nR/One\n2. B\nR/Two\n3. C'));
    expect(slides.map((s) => s.text), ['A', 'One', 'B', 'Two', 'C', 'Two']);
  });
}
