import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indirimbo/models/searchable_song.dart';
import 'package:indirimbo/providers/songs_provider.dart';
import 'package:indirimbo/widgets/song_navigation_bar.dart';
import 'package:provider/provider.dart';

class UnifiedLyrics extends StatefulWidget {
  const UnifiedLyrics({super.key});

  @override
  State<UnifiedLyrics> createState() => _UnifiedLyricsState();
}

class _UnifiedLyricsState extends State<UnifiedLyrics> {
  double _fontSize = 15.0;
  late int _currentIndex;
  late List<SearchableSong> _songs;
  bool _hasList = false;
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
      _hasList = true;
    } else if (args is SearchableSong) {
      _songs = [args];
      _currentIndex = 0;
      _hasList = false;
    }
    _initialized = true;
  }

  SearchableSong get _currentSong => _songs[_currentIndex];

  void _goTo(int index) {
    setState(() {
      _currentIndex = index;
    });
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
            tooltip: songsProvider.isFavorite(_currentSong)
                ? 'Remove favorite'
                : 'Save favorite',
            onPressed: () => context
                .read<SongCollectionProvider>()
                .toggleFavorite(_currentSong),
            icon: Icon(
                songsProvider.isFavorite(_currentSong)
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
      bottomNavigationBar: _hasList && _songs.length > 1
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
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                color: Colors.blueGrey[800],
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      _currentSong.title,
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

              const SizedBox(height: 8),

              // ── Lyrics card ─────────────────────────────────────────
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _formatLyrics(_currentSong.lyrics),
                  ),
                ),
              ),

              // ── Pagination ──────────────────────────────────────────
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
    lyrics = lyrics.replaceFirstMapped(
      RegExp(r'^(\d+)\.'),
      (m) => m.group(1) == '1' ? m.group(0)! : '1.',
    );

    // FIX: Use a clean list copy so repeated calls never share state
    var lines = List<String>.from(lyrics.split('\n'));

    // Strip a leading line that is ONLY a standalone number (the song's own
    // catalogue number stored as the first line, e.g. "5" or "5.").
    // Without this the first verse badge shows the song number instead of "1".
    if (lines.isNotEmpty) {
      final firstNonEmpty = lines.indexWhere((l) => l.trim().isNotEmpty);
      if (firstNonEmpty != -1) {
        final candidate = lines[firstNonEmpty].trim();
        // Matches lines that are ONLY a number, optionally followed by a dot —
        // no extra text after it (those are real "1. First line of verse" lines).
        final soloNumber = RegExp(r'^\d+\.?\s*$');
        if (soloNumber.hasMatch(candidate)) {
          lines = List<String>.from(lines)..removeAt(firstNonEmpty);
        }
      }
    }

    final widgets = <Widget>[];

    // State machine — avoids look-ahead index bugs
    bool isChorus = false;
    final chorusBuffer = <String>[];

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
                    child: Text(
                      'CHORUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey[400],
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  Expanded(
                      child:
                          Divider(color: Colors.blueGrey[300], thickness: 0.8)),
                ],
              ),
              const SizedBox(height: 8),
              ...chorusBuffer.map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _fontSize,
                        color: colors.onSurface,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1.65,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      );
      chorusBuffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();

      // ── Blank line ──────────────────────────────────────────────
      if (line.isEmpty) {
        if (isChorus) {
          // blank line ends chorus
          flushChorus();
          isChorus = false;
        } else {
          widgets.add(const SizedBox(height: 10));
        }
        continue;
      }

      // ── Verse number line  (e.g. "1. …" or "2.") ───────────────
      final verseMatch = RegExp(r'^(\d+)\.\s*(.*)$').firstMatch(line);
      if (verseMatch != null) {
        flushChorus();
        isChorus = false;

        final number = verseMatch.group(1)!; // e.g. "1"
        final rest = verseMatch.group(2)!.trim(); // text after "1."

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
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (rest.isNotEmpty)
              Expanded(
                child: Text(
                  rest,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold, // jules21
                    color: colors.onSurface,
                    height: 1.65,
                  ),
                ),
              ),
          ],
        ));
        continue;
      }

      // ── Chorus marker  ("ref:" or "R/") ─────────────────────────
      final chorusMarker = RegExp(r'^(?:ref:\s*|R/\s*)', caseSensitive: false);
      if (chorusMarker.hasMatch(line)) {
        flushChorus();
        isChorus = true;
        final after = line.replaceFirst(chorusMarker, '');
        if (after.isNotEmpty) chorusBuffer.add(after);
        continue;
      }

      // ── Inside chorus ────────────────────────────────────────────
      if (isChorus) {
        chorusBuffer.add(line);
        continue;
      }

      // ── Plain verse line ─────────────────────────────────────────
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          line,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _fontSize,
            color: colors.onSurface,
            height: 1.65,
            letterSpacing: 0.2,
          ),
        ),
      ));
    }

    // Flush any trailing chorus
    flushChorus();
    return widgets;
  }
}
