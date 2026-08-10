import 'package:flutter_test/flutter_test.dart';
import 'package:indirimbo/utils/lyrics_clipboard_formatter.dart';

void main() {
  test('formats copied lyrics into readable sections', () {
    final result = formatLyricsForClipboard(
      id: '3',
      title: ' 1.Urukundo ruhebuje ',
      lyrics: '1.Urukundo ruhebuje\r\n\r\nref:Urukundo!\r\n\r\n2.Icya kabiri  ',
    );

    expect(
      result,
      '3. Urukundo ruhebuje\n\n'
      '1. Urukundo ruhebuje\n\n'
      'CHORUS\n'
      'Urukundo!\n\n'
      '2. Icya kabiri',
    );
  });

  test('removes a duplicated heading from the lyrics', () {
    final result = formatLyricsForClipboard(
      id: '2',
      title: 'UMVA, WA JURU WE',
      lyrics: '2. UMVA, WA JURU WE\n1. First line',
    );

    expect(result, '2. UMVA, WA JURU WE\n\n1. First line');
  });
}
