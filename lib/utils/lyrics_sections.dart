class LyricsSection {
  const LyricsSection(this.label, this.text, {this.isChorus = false});
  final String label;
  final String text;
  final bool isChorus;
}

String markUnnumberedParagraphsAsChorus(String lyrics) {
  final paragraphs = lyrics
      .replaceAll('\r', '')
      .split(RegExp(r'\n\s*\n'))
      .map((paragraph) => paragraph.trim())
      .where((paragraph) => paragraph.isNotEmpty);
  final verseNumber = RegExp(r'^\d+\.\s*');
  final chorusMarker = RegExp(
    r'^(?:ref\s*:|r\s*/|chorus\s*:)',
    caseSensitive: false,
  );

  return paragraphs.map((paragraph) {
    if (verseNumber.hasMatch(paragraph) || chorusMarker.hasMatch(paragraph)) {
      return paragraph;
    }
    return 'R/$paragraph';
  }).join('\n\n');
}

List<LyricsSection> parseLyrics(String lyrics) {
  final lines = lyrics.replaceAll('\r', '').split('\n');
  final sections = <LyricsSection>[];
  final buffer = <String>[];
  var chorus = false;
  var verse = 0;
  void flush() {
    if (buffer.isEmpty) return;
    if (!chorus) verse++;
    sections.add(LyricsSection(chorus ? 'Chorus' : 'Verse $verse',
        buffer.join('\n').trim(), isChorus: chorus));
    buffer.clear();
  }
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) {
      if (chorus) { flush(); chorus = false; }
      continue;
    }
    final refrain = RegExp(r'^(?:ref\s*:|r\s*/|chorus\s*:)\s*(.*)$',
        caseSensitive: false).firstMatch(line);
    final numbered = RegExp(r'^\d+\.\s*(.*)$').firstMatch(line);
    if (refrain != null) {
      flush(); chorus = true;
      if (refrain.group(1)!.isNotEmpty) buffer.add(refrain.group(1)!);
    } else if (numbered != null) {
      flush(); chorus = false;
      if (numbered.group(1)!.isNotEmpty) buffer.add(numbered.group(1)!);
    } else if (buffer.isEmpty && sections.isEmpty && RegExp(r'^\d+$').hasMatch(line)) {
      continue; // Standalone catalogue number, not lyrics.
    } else {
      buffer.add(line);
    }
  }
  flush();
  return sections;
}

List<LyricsSection> presentationSections(List<LyricsSection> sections) {
  final choruses = sections.where((section) => section.isChorus);
  if (choruses.isEmpty) return sections;
  final result = <LyricsSection>[];
  var chorus = choruses.first;
  for (var i = 0; i < sections.length; i++) {
    final section = sections[i];
    if (section.isChorus) { chorus = section; continue; }
    result.add(section);
    if (i + 1 < sections.length && sections[i + 1].isChorus) {
      chorus = sections[i + 1];
    }
    result.add(chorus);
  }
  return result.isEmpty ? sections : result;
}
