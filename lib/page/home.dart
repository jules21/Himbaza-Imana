import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/search_song.dart';
import '../providers/songs_provider.dart';
import '../providers/theme_provider.dart';


class Home extends StatefulWidget{
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
  TextEditingController _searchController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
          child: _isSearching ? _buildSearchResults() : _buildDefaultContent()

      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
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
                  onChanged: (query) => null,
                  // onChanged: (query) => _performSearch(query, context),
                  autofocus: true,
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: 'Gushaka...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                      hintStyle: TextStyle(color: Colors.blueGrey[800])
                  ),
                ),
              ),
              IconButton(
                  onPressed: () => null,
                  // onPressed: () => _performSearch,
                  icon: Icon(Icons.search)
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
                onPressed: ()=> null,
                // onPressed: ()=> _getSongLyrics(songs[index]),
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
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
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
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Type to search for songs',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final song = result.song;

        return Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate to the lyrics page with the selected song
              Navigator.pushNamed(
                context,
                '/lyrics',
                arguments: song,
              );

              // Close search when navigating
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchResults = [];
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${song?.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song!.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
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
}