import 'package:flutter/material.dart';
import 'package:indirimbo/models/searchable_song.dart';

class UnifiedLyrics extends StatelessWidget {
  const UnifiedLyrics({super.key});
  @override
  Widget build(BuildContext context) {
    final song  = ModalRoute.of(context)!.settings.arguments as SearchableSong;
    return  Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white,),
        backgroundColor: Colors.blueGrey[800],
        title: Text('${song.title}', style:
        const TextStyle(
            color: Colors.white,
            fontSize: 14
        ),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Centered Song Title
                Text(
                  song.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Formatted Lyrics
                ..._formatLyrics(song.lyrics),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to format lyrics
// Function to format lyrics correctly
  List<Widget> _formatLyrics(String lyrics) {
    List<String> lines = lyrics.split("\n");

    List<Widget> formattedLines = [];
    bool isChorus = false; // Flag to track chorus lines

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim(); // Remove extra spaces

      if (line.isEmpty) {
        formattedLines.add(const SizedBox(height: 10)); // Add spacing
      } else if (RegExp(r"^\d+\..*").hasMatch(line)) {
        // Verse Numbers (e.g., "1. First Line")
        isChorus = false; // Reset chorus flag
        formattedLines.add(
          Text(
            textAlign: TextAlign.center,
            "\n$line",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
        );
      } else if (line.toLowerCase().startsWith("ref:")) {
        // Start of Chorus
        isChorus = true;
        formattedLines.add(
          Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              line.replaceFirst("R/", "Chorus:\n"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
                letterSpacing: 1, height: 1.4,
              ),
            ),
          ),
        );
      } else if (isChorus && (i + 1 >= lines.length || RegExp(r"^\d+\..*").hasMatch(lines[i + 1].trim()))) {
        // Last line of Chorus (before next verse)
        formattedLines.add(
          Text(
            line,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
              letterSpacing: 1, height: 1.4,
            ),
          ),
        );
        isChorus = false; // Stop styling as chorus
      } else if (isChorus) {
        // Middle lines of Chorus
        formattedLines.add(
          Text(
            line,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
              letterSpacing: 1, height: 1.4,
            ),
          ),
        );
      } else {
        // Regular Lines
        formattedLines.add(
          Text(
            textAlign: TextAlign.center,
            line,
            style: const TextStyle(fontSize: 16, letterSpacing: 1, height: 1.4),
          ),
        );
      }
    }

    return formattedLines;
  }
}
