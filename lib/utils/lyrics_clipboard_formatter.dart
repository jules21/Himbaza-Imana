String formatLyricsForClipboard({
  required String id,
  required String title,
  required String lyrics,
}) {
  final cleanTitle = title.trim().replaceFirst(RegExp(r'^\d+\.\s*'), '');
  final heading =
      [id.trim(), cleanTitle].where((part) => part.isNotEmpty).join('. ');
  final input = lyrics.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final output = <String>[];

  for (final rawLine in input.split('\n')) {
    var line = rawLine.trim();
    if (line.isEmpty) {
      if (output.isNotEmpty && output.last.isNotEmpty) output.add('');
      continue;
    }

    final comparable = line.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final duplicateHeadings = <String>{
      cleanTitle.toLowerCase(),
      '$id $cleanTitle'.trim().toLowerCase(),
      '$id. $cleanTitle'.trim().toLowerCase(),
    };
    if (output.length < 3 && duplicateHeadings.contains(comparable)) continue;

    final chorus = RegExp(r'^(?:ref\s*:|r\s*/)\s*(.*)$', caseSensitive: false)
        .firstMatch(line);
    if (chorus != null) {
      _addSectionBreak(output);
      output.add('CHORUS');
      final firstLine = chorus.group(1)!.trim();
      if (firstLine.isNotEmpty) output.add(firstLine);
      continue;
    }

    final verse = RegExp(r'^(\d+)\.\s*(.*)$').firstMatch(line);
    if (verse != null) {
      _addSectionBreak(output);
      final text = verse.group(2)!.trim();
      line = '${verse.group(1)}.${text.isEmpty ? '' : ' $text'}';
    }
    output.add(line);
  }

  while (output.isNotEmpty && output.last.isEmpty) {
    output.removeLast();
  }

  return '$heading\n\n${output.join('\n')}';
}

void _addSectionBreak(List<String> lines) {
  if (lines.isNotEmpty && lines.last.isNotEmpty) lines.add('');
}
