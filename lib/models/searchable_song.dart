abstract class SearchableSong {
  String get id;
  String get title;
  String get lyrics;
  String get parent;

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

String songTitleWithNumber(SearchableSong song) {
  final title = song.title.trim();
  if (RegExp(r'^\d+\.\s*').hasMatch(title)) return title;
  return '${song.id}. $title';
}

String songCatalogNumber(SearchableSong song) {
  final match = RegExp(r'^(\d+)\.').firstMatch(songTitleWithNumber(song));
  return match?.group(1) ?? song.id;
}

String songTitleWithoutNumber(SearchableSong song) =>
    songTitleWithNumber(song).replaceFirst(RegExp(r'^\d+\.\s*'), '');

String songCategoryLabel(SearchableSong song) {
  switch (song.parent) {
    case '21':
      return 'Umugeni';
    case 'wokovu':
      return 'Nyimbo za Wokovu';
    case '554':
      return 'Agakiza';
    default:
      return 'Gushimisha';
  }
}
