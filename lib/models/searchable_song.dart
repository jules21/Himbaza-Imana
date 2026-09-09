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
