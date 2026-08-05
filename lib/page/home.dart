import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indirimbo/services/song_service.dart';
import 'package:indirimbo/page/unified_lyrics.dart';
import 'package:provider/provider.dart';
import '../models/search_song_result.dart';
import '../models/searchable_song.dart';
import '../models/view_type.dart';
import '../providers/songs_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/song_view_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ViewType _currentViewType = ViewType.list;
  List<SongSearchResult> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load songs when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongCollectionProvider>().loadAllSongs(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: _isSearching
              ? Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (query) => _performUnifiedSearch(query),
                    autofocus: true,
                    controller: _searchController,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.blueGrey[900],
                    ),
                    decoration: InputDecoration(
                      hintText: 'Gushaka indirimbo...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      hintStyle: GoogleFonts.inter(
                        color: Colors.blueGrey[400],
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blueGrey[600],
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.blueGrey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _performUnifiedSearch('');
                              },
                            )
                          : null,
                    ),
                  ),
                )
              : Text(
                  "Himbaza Imana",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
          backgroundColor: Colors.blueGrey[800],
          actions: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    _searchResults = [];
                  } else {
                    _isSearching = true;
                  }
                });
              },
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.white,
                size: 25,
              ),
              tooltip: _isSearching ? 'Close search' : 'Search songs',
            ),
          ],
        ),
        floatingActionButton: _isSearching
            ? null
            : FloatingActionButton.small(
                onPressed: _showDisplayOptions,
                tooltip: 'Display options',
                child: const Icon(Icons.tune_rounded),
              ),
        body: SafeArea(
            child:
                _isSearching ? _buildSearchResults() : _buildDefaultContent()),
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
    final brideSongs = songsProvider.brideSongs;
    final ugushimishaSongs = songsProvider.ugushimishaSongs();
    final agakizaSongs = songsProvider.agakizaSongs();

    return Column(
      children: [
        Container(
          color: Colors.blueGrey[800],
          child: LayoutBuilder(
            builder: (context, constraints) => TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                SizedBox(
                    width: constraints.maxWidth * .29,
                    child: const Tab(text: 'Umugeni')),
                SizedBox(
                    width: constraints.maxWidth * .29,
                    child: const Tab(text: 'Ugushimisha')),
                SizedBox(
                    width: constraints.maxWidth * .29,
                    child: const Tab(text: 'Agakiza')),
                SizedBox(
                    width: constraints.maxWidth * .13,
                    child: const Tab(icon: Icon(Icons.favorite))),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              SongViewScreen(songs: brideSongs, viewType: _currentViewType),
              SongViewScreen(
                  songs: ugushimishaSongs, viewType: _currentViewType),
              SongViewScreen(songs: agakizaSongs, viewType: _currentViewType),
              SongViewScreen(
                songs: songsProvider.favoriteSongs,
                viewType: _currentViewType,
                emptyMessage: 'No favorite songs yet',
              ),
            ],
          ),
        ),
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
              final resultSongs = _searchResults
                  .map((searchResult) => searchResult.song)
                  .toList();
              // Navigate to the lyrics page with the selected song
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const UnifiedLyrics(),
                    settings: RouteSettings(arguments: {
                      'songs': resultSongs,
                      'index': index,
                    })),
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: Theme.of(context).primaryColor,
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
                              '#${song.parent != '554' ? (song.parent == "21" ? "Umugeni" : "Gushimisha") : "Agakiza"}',
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

    SongService songService = SongService();
    setState(() {
      _searchResults = matchingSongs
          .map((song) => songService.getUnifiedContextualPreview(song, query))
          .toList();
    });
  }

  void _showDisplayOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(_currentViewType == ViewType.compactGrid
                    ? Icons.view_list_rounded
                    : Icons.view_compact_alt_rounded),
                title: Text(_currentViewType == ViewType.compactGrid
                    ? 'Use list layout'
                    : 'Use compact layout'),
                onTap: () {
                  setState(() {
                    _currentViewType = _currentViewType == ViewType.compactGrid
                        ? ViewType.list
                        : ViewType.compactGrid;
                  });
                  Navigator.pop(sheetContext);
                },
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) => SwitchListTile(
                  secondary: Icon(themeProvider.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
                  title: const Text('Dark mode'),
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
