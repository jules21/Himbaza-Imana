import 'package:flutter/material.dart';
import 'package:indirimbo/models/bride_song.dart';
import 'package:indirimbo/page/unified_lyrics.dart';
import 'package:provider/provider.dart';

import '../models/search_song_result.dart';
import '../models/searchable_song.dart';
import '../providers/songs_provider.dart';
import '../providers/theme_provider.dart';
import 'bride_lyrics.dart';


class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  @override
  void initState() {
    super.initState();
    // Load songs when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongCollectionProvider>().loadAllSongs(context);
    });
  }

  List<SongSearchResult> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  TextStyle _previewTextStyle() => TextStyle(
    fontSize: 14,
    color: Colors.grey[800],
    fontStyle: FontStyle.italic,
  );

  TextStyle _highlightedTextStyle() => TextStyle(
    fontSize: 14,
    color: Colors.grey[800],
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    backgroundColor: Colors.yellow[100],
  );

  // Get a contextual preview around the search term
  SongSearchResult _getUnifiedContextualPreview(SearchableSong song, String searchTerm) {
    final searchTermLower = searchTerm.toLowerCase();
    final titleLower = song.title.toLowerCase();
    final lyricsLower = song.lyrics.toLowerCase();

    if (titleLower.contains(searchTermLower)) {
      final previewText = song.lyrics.length > 60
          ? '${song.lyrics.substring(0, 60)}...'
          : song.lyrics;

      final highlightedPreview = [
        TextSpan(
          text: previewText,
          style: _previewTextStyle(),
        ),
      ];

      return SongSearchResult(
        song: song, // assuming `SongSearchResult` accepts `SearchableSong`
        previewText: previewText,
        highlightedPreview: highlightedPreview,
      );
    } else {
      final matchIndex = lyricsLower.indexOf(searchTermLower);

      int startIndex = matchIndex - 25;
      int endIndex = matchIndex + searchTermLower.length + 25;

      if (startIndex < 0) startIndex = 0;
      if (endIndex > song.lyrics.length) endIndex = song.lyrics.length;

      final previewText = (startIndex > 0 ? '...' : '') +
          song.lyrics.substring(startIndex, endIndex) +
          (endIndex < song.lyrics.length ? '...' : '');

      final highlightedPreview = [
        if (startIndex > 0) TextSpan(text: '...', style: _previewTextStyle()),
        TextSpan(text: song.lyrics.substring(startIndex, matchIndex), style: _previewTextStyle()),
        TextSpan(
          text: song.lyrics.substring(matchIndex, matchIndex + searchTermLower.length),
          style: _highlightedTextStyle(),
        ),
        TextSpan(text: song.lyrics.substring(matchIndex + searchTermLower.length, endIndex), style: _previewTextStyle()),
        if (endIndex < song.lyrics.length) TextSpan(text: '...', style: _previewTextStyle()),
      ];

      return SongSearchResult(
        song: song,
        previewText: previewText,
        highlightedPreview: highlightedPreview,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearching ? Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (query) => _performUnifiedSearch(query),
                  autofocus: true,
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: 'Gushaka...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      hintStyle: TextStyle(color: Colors.blueGrey[800])
                  ),
                ),
              ),
              IconButton(
                  onPressed: () => _performUnifiedSearch,
                  icon: const Icon(Icons.search)
              )
            ],
          ),
        ) :
        const Text("Indirimbo z' umugeni", style: TextStyle(
            color: Colors.white
        ),),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
              onPressed: () => {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    _searchResults = [];
                  } else {
                    _isSearching = true;
                  }
                })
              },
              icon: Icon((_isSearching ? Icons.clear: Icons.search), color: Colors.white,size: 30,)),
          Visibility(
            visible: !_isSearching,
            child: IconButton(
                onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                icon: Icon((Provider.of<ThemeProvider>(context).isDark ? Icons.dark_mode : Icons.light_mode), color: Colors.white,size: 30,)),
          )
        ],
      ),
      body: SafeArea(
          child: _isSearching ? _buildSearchResults() : _buildDefaultContent()

      ),

    );
  }

  songGridSection(songs) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
            itemCount: songs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                childAspectRatio: 1.5
            ),
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.all(2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                    )
                ),
                onPressed: ()=> _getSongLyrics(songs[index]),
                child: Center(
                  child: Text('${songs[index].id}', style: const TextStyle(
                      fontSize: 16
                  ),),
                ),),
            )
        ),
      ),
    );
  }

  _buildDefaultContent() {
    final songsProvider = Provider.of<SongCollectionProvider>(context);
    if (songsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (songsProvider.error.isNotEmpty) {
      return Center(child: Text("Error: ${songsProvider.error}"));
    }
    final songs = songsProvider.brideSongs;

    return
      Column(
        children: [
          //song category
          // categorySection(),

          //first category songs in gridview
          songGridSection(songs)
        ],
      );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No songs found',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    } else if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Type to search for songs',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final song = result.song;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate to the lyrics page with the selected song
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder:(context) => const UnifiedLyrics(),
                    settings: RouteSettings(
                        arguments: song
                    )
                ),
              );


              // Close search when navigating
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchResults = [];
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${song.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '#${song.parent != '554' ? (song.parent == "21" ? "Umugeni": "Gushimisha"):"Agakiza"}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: result.highlightedPreview,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _performUnifiedSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final provider = context.read<SongCollectionProvider>();

    // Combine all searchable songs regardless of original type
    final List<SearchableSong> allSongs = [
      ...provider.hymnPraiseSongs.where((element) => element.parent != "-1"),
      ...provider.brideSongs,
      // Add more sources here if needed
    ];


    
    final searchLower = query.toLowerCase();

    final matchingSongs = allSongs.where((song) {
      return song.title.toLowerCase().contains(searchLower) ||
          song.lyrics.toLowerCase().contains(searchLower);
    }).toList();

    setState(() {
      _searchResults = matchingSongs
          .map((song) => _getUnifiedContextualPreview(song, query))
          .toList();
    });
  }

  void _getSongLyrics(BrideSong song) {
    //pass song to another page;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder:(context) => const BrideLyrics(),
          settings: RouteSettings(
              arguments: song
          )
      ),
    );
  }

  
  
}