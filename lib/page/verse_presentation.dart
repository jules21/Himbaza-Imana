import 'package:flutter/material.dart';
import '../models/searchable_song.dart';
import '../utils/lyrics_sections.dart';

class VersePresentation extends StatefulWidget {
  const VersePresentation({super.key, required this.song});
  final SearchableSong song;
  @override
  State<VersePresentation> createState() => _VersePresentationState();
}

class _VersePresentationState extends State<VersePresentation> {
  final _pages = PageController();
  late final _sections = presentationSections(parseLyrics(widget.song.lyrics));
  int _index = 0;
  bool _whiteBackground = false;
  @override
  void dispose() { _pages.dispose(); super.dispose(); }
  void _next() {
    if (_index == _sections.length - 1) { Navigator.pop(context); return; }
    _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }
  @override
  Widget build(BuildContext context) {
    final foreground = _whiteBackground ? Colors.black : Colors.white;
    final background = _whiteBackground ? Colors.white : Colors.black;
    return Theme(
      data: ThemeData(brightness: _whiteBackground ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: background, colorSchemeSeed: Colors.grey),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(child: Column(children: [
          Row(children: [
            IconButton(tooltip: 'Close presentation', onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: foreground)),
            Expanded(
                child: Text(songTitleWithNumber(widget.song),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: foreground, fontSize: 14),
                    textAlign: TextAlign.center)),
            IconButton(tooltip: 'Invert black and white',
                onPressed: () => setState(() => _whiteBackground = !_whiteBackground),
                icon: Icon(Icons.contrast, color: foreground)),
          ]),
          if (_sections.isEmpty) const Expanded(child: Center(child: Text('No lyrics available')))
          else ...[
            Padding(padding: const EdgeInsets.all(8), child: Text(
              '${_sections[_index].label} · ${_index + 1} / ${_sections.length}',
              style: TextStyle(color: foreground, fontSize: 16),
              semanticsLabel: '${_sections[_index].label}, slide ${_index + 1} of ${_sections.length}',
            )),
            Expanded(child: PageView.builder(
              controller: _pages, itemCount: _sections.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => LayoutBuilder(builder: (context, constraints) {
                final width = (constraints.maxWidth - 40).clamp(1.0, 960.0);
                var size = 40.0;
                final scaler = MediaQuery.textScalerOf(context);
                final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: scaler);
                while (size > 22) {
                  painter.text = TextSpan(text: _sections[index].text,
                      style: TextStyle(fontSize: size, height: 1.4));
                  painter.layout(maxWidth: width);
                  if (painter.height <= constraints.maxHeight - 40) break;
                  size -= 1;
                }
                painter.dispose();
                return SingleChildScrollView(key: ValueKey(index), padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(constraints: BoxConstraints(minHeight: (constraints.maxHeight - 40).clamp(0.0, double.infinity)),
                    child: Center(child: SizedBox(width: width, child: Text(_sections[index].text,
                      textAlign: TextAlign.center, style: TextStyle(color: foreground, fontSize: size, height: 1.4)))),
                  ),
                );
              }),
            )),
            LinearProgressIndicator(value: (_index + 1) / _sections.length,
                color: foreground, backgroundColor: foreground.withValues(alpha: 0.2)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                IconButton(tooltip: 'Previous verse or chorus',
                  onPressed: _index == 0 ? null : () => _pages.previousPage(
                    duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic),
                  icon: Icon(Icons.chevron_left, color: _index == 0 ? Colors.grey : foreground)),
                Expanded(child: Text(_index == _sections.length - 1 ? 'End of song' : 'Swipe for next verse or chorus',
                    textAlign: TextAlign.center, style: TextStyle(color: foreground, fontSize: 13))),
                TextButton(onPressed: _next, child: Text(_index == _sections.length - 1 ? 'Finish' : 'Next',
                    style: TextStyle(color: foreground))),
              ])),
          ],
        ])),
      ),
    );
  }
}
