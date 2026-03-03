import 'package:flutter/material.dart';
import 'package:indirimbo/models/searchable_song.dart';

class UnifiedLyrics extends StatefulWidget {
  const UnifiedLyrics({super.key});

  @override
  State<UnifiedLyrics> createState() => _UnifiedLyricsState();
}

class _UnifiedLyricsState extends State<UnifiedLyrics> {
  double _fontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final song = ModalRoute.of(context)!.settings.arguments as SearchableSong;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title:   const Icon(Icons.music_note_rounded, color: Colors.blueGrey, size: 20),

        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _fontButton(Icons.remove, () { setState(() { if (_fontSize > 12) _fontSize -= 1; }); }),
                Text('${_fontSize.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                _fontButton(Icons.add, () { setState(() { if (_fontSize < 32) _fontSize += 1; }); }),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
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
                    song.title,
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
                    width: 50, height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 10),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
    final lines = lyrics.split("\n");
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
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey[200]!, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.blueGrey[300], thickness: 0.8)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("CHORUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.blueGrey[400], letterSpacing: 2.5)),
                  ),
                  Expanded(child: Divider(color: Colors.blueGrey[300], thickness: 0.8)),
                ],
              ),
              const SizedBox(height: 8),
              ...chorusBuffer.map((line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(line, textAlign: TextAlign.center, style: TextStyle(fontSize: _fontSize, color: Colors.blueGrey[700], fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, height: 1.65)),
              )),
            ],
          ),
        ),
      );
      chorusBuffer = [];
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) { if (!isChorus) widgets.add(const SizedBox(height: 10)); continue; }

      if (RegExp(r"^\d+\.").hasMatch(line)) {
        flushChorus(); isChorus = false;
        widgets.add(const SizedBox(height: 16));
        widgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(RegExp(r"^\d+\.").firstMatch(line)?.group(0) ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(line.replaceFirst(RegExp(r"^\d+\.\s*"), ''), style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w500, color: Colors.blueGrey[900], height: 1.65))),
          ],
        ));
        continue;
      }

      if (line.toLowerCase().startsWith("ref:") || RegExp(r"^R/").hasMatch(line)) {
        flushChorus(); isChorus = true;
        final after = line.replaceFirst(RegExp(r"^ref:\s*", caseSensitive: false), "").replaceFirst(RegExp(r"^R/\s*"), "");
        if (after.isNotEmpty) chorusBuffer.add(after);
        continue;
      }

      final isLast = i == lines.length - 1;
      final nextIsVerse = !isLast && RegExp(r"^\d+\.").hasMatch(lines[i + 1].trim());

      if (isChorus) {
        chorusBuffer.add(line);
        if (isLast || nextIsVerse) { flushChorus(); isChorus = false; }
        continue;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(line, textAlign: TextAlign.center, style: TextStyle(fontSize: _fontSize, color: Colors.blueGrey[800], height: 1.65, letterSpacing: 0.2)),
      ));
    }

    flushChorus();
    return widgets;
  }
}