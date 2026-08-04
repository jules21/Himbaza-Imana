import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indirimbo/models/searchable_song.dart';
import 'package:indirimbo/providers/songs_provider.dart';
import 'package:indirimbo/widgets/song_navigation_bar.dart';
import 'package:provider/provider.dart';

class BrideLyrics extends StatefulWidget {
  const BrideLyrics({super.key});

  @override
  State<BrideLyrics> createState() => _BrideLyricsState();
}

class _BrideLyricsState extends State<BrideLyrics> {
  double _fontSize = 15.0;
  late List<SearchableSong> _songs;
  late int _currentIndex;
  bool _initialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map) {
      _songs = List<SearchableSong>.from(args['songs'] as List);
      _currentIndex = args['index'] as int;
    } else {
      _songs = [args as SearchableSong];
      _currentIndex = 0;
    }
    _initialized = true;
  }

  SearchableSong get _currentSong => _songs[_currentIndex];

  void _goTo(int index) {
    setState(() => _currentIndex = index);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Future<void> _copyLyrics() async {
    await Clipboard.setData(ClipboardData(
      text: '${_currentSong.title}\n\n${_currentSong.lyrics}',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lyrics copied to clipboard')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = _currentSong;
    final songsProvider = context.watch<SongCollectionProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Icon(Icons.music_note_rounded,
            color: Colors.blueGrey, size: 20),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Copy lyrics',
            onPressed: _copyLyrics,
            icon: const Icon(Icons.copy, color: Colors.white),
          ),
          IconButton(
            tooltip: songsProvider.isFavorite(song)
                ? 'Remove favorite'
                : 'Save favorite',
            onPressed: () =>
                context.read<SongCollectionProvider>().toggleFavorite(song),
            icon: Icon(
                songsProvider.isFavorite(song)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.white),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _fontButton(Icons.remove, () {
                  setState(() {
                    if (_fontSize > 12) _fontSize -= 1;
                  });
                }),
                Text('${_fontSize.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                _fontButton(Icons.add, () {
                  setState(() {
                    if (_fontSize < 32) _fontSize += 1;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _songs.length > 1
          ? SafeArea(
              child: Material(
                elevation: 8,
                color: Theme.of(context).colorScheme.surface,
                child: SongNavigationBar(
                  currentIndex: _currentIndex,
                  songCount: _songs.length,
                  onNavigate: _goTo,
                ),
              ),
            )
          : null,
      body: SelectionArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: const BorderRadius.only(
                      // bottomLeft: Radius.circular(28),
                      // bottomRight: Radius.circular(28),
                      ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '${song.id} ${song.title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 50,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _formatLyrics(song.lyrics),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fontButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );

  List<Widget> _formatLyrics(String lyrics) {
    final colors = Theme.of(context).colorScheme;
    List<String> lines = lyrics.split("\n");

    // Original BrideLyrics pre-processing — preserved exactly
    if (lines.isNotEmpty) {
      if (!lines.first.startsWith(RegExp(r'^\d'))) lines.remove(lines.first);
      if (lines.isNotEmpty) lines.remove(lines.first);
      if (lines.isNotEmpty) lines.removeLast();
    }

    final widgets = <Widget>[];
    bool isChorus = false;
    List<String> chorusBuffer = [];

    void flushChorus() {
      if (chorusBuffer.isEmpty) return;
      widgets.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey[200]!, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                      child:
                          Divider(color: Colors.blueGrey[300], thickness: 0.8)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("CHORUS",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey[400],
                            letterSpacing: 2.5)),
                  ),
                  Expanded(
                      child:
                          Divider(color: Colors.blueGrey[300], thickness: 0.8)),
                ],
              ),
              const SizedBox(height: 8),
              ...chorusBuffer.map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(line,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: _fontSize,
                            color: colors.onSurface,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            height: 1.65)),
                  )),
            ],
          ),
        ),
      );
      chorusBuffer = [];
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        if (!isChorus) widgets.add(const SizedBox(height: 10));
        continue;
      }

      if (RegExp(r"^\d+\.").hasMatch(line)) {
        flushChorus();
        isChorus = false;
        // Number without dot
        final number = RegExp(r"^\d+").firstMatch(line)?.group(0) ?? '';
        widgets.add(const SizedBox(height: 16));
        widgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(number,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(line.replaceFirst(RegExp(r"^\d+\.\s*"), ''),
                    style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                        height: 1.65))),
          ],
        ));
        continue;
      }

      if (line.startsWith("R/")) {
        flushChorus();
        isChorus = true;
        final after = line.replaceFirst(RegExp(r"^R/\s*"), "");
        if (after.isNotEmpty) chorusBuffer.add(after);
        continue;
      }

      final isLast = i == lines.length - 1;
      final nextIsVerse =
          !isLast && RegExp(r"^\d+\.").hasMatch(lines[i + 1].trim());

      if (isChorus) {
        chorusBuffer.add(line);
        if (isLast || nextIsVerse) {
          flushChorus();
          isChorus = false;
        }
        continue;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(line,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: _fontSize,
                color: colors.onSurface,
                height: 1.65,
                letterSpacing: 0.2)),
      ));
    }

    flushChorus();
    return widgets;
  }
}
