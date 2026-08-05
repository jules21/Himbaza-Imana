// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Add this to pubspec.yaml
//
// // Home Page with Enhanced AppBar and View Options
// class _HomeState extends State<Home> {
//   ViewType _currentViewType = ViewType.grid;
//   bool _isSearching = false;
//   final TextEditingController _searchController = TextEditingController();
//   List<Song> _searchResults = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<SongCollectionProvider>().loadAllSongs(context);
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: _isSearching
//               ? Container(
//             height: 45,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(25),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextField(
//               onChanged: (query) => _performUnifiedSearch(query),
//               autofocus: true,
//               controller: _searchController,
//               style: GoogleFonts.inter(
//                 fontSize: 16,
//                 color: Colors.blueGrey[900],
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Gushaka indirimbo...',
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//                 hintStyle: GoogleFonts.inter(
//                   color: Colors.blueGrey[400],
//                   fontSize: 15,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.search,
//                   color: Colors.blueGrey[600],
//                   size: 22,
//                 ),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                   icon: Icon(
//                     Icons.clear,
//                     color: Colors.blueGrey[600],
//                     size: 20,
//                   ),
//                   onPressed: () {
//                     _searchController.clear();
//                     _performUnifiedSearch('');
//                   },
//                 )
//                     : null,
//               ),
//             ),
//           )
//               : Text(
//             "Himbaza Imana",
//             style: GoogleFonts.poppins(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//           backgroundColor: Colors.blueGrey[800],
//           actions: [
//             // Search Toggle Button
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               decoration: BoxDecoration(
//                 color: _isSearching
//                     ? Colors.white.withOpacity(0.2)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: IconButton(
//                 onPressed: () {
//                   setState(() {
//                     if (_isSearching) {
//                       _isSearching = false;
//                       _searchController.clear();
//                       _searchResults = [];
//                     } else {
//                       _isSearching = true;
//                     }
//                   });
//                 },
//                 icon: Icon(
//                   _isSearching ? Icons.close : Icons.search,
//                   color: Colors.white,
//                   size: 26,
//                 ),
//                 tooltip: _isSearching ? 'Close search' : 'Search songs',
//               ),
//             ),
//
//             // View Type Selector
//             if (!_isSearching)
//               Container(
//                 margin: const EdgeInsets.only(right: 8, left: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.transparent,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: PopupMenuButton<ViewType>(
//                   icon: Icon(
//                     _getViewIcon(),
//                     color: Colors.white,
//                     size: 26,
//                   ),
//                   tooltip: 'Change view',
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   offset: const Offset(0, 50),
//                   elevation: 8,
//                   onSelected: (ViewType type) {
//                     setState(() {
//                       _currentViewType = type;
//                     });
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: ViewType.grid,
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: _currentViewType == ViewType.grid
//                                   ? Colors.blueGrey[100]
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.grid_view_rounded,
//                               color: Colors.blueGrey[800],
//                               size: 22,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Text(
//                             'Grid View',
//                             style: GoogleFonts.inter(
//                               fontSize: 15,
//                               fontWeight: _currentViewType == ViewType.grid
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                             ),
//                           ),
//                           if (_currentViewType == ViewType.grid) ...[
//                             const Spacer(),
//                             Icon(
//                               Icons.check,
//                               color: Colors.blueGrey[800],
//                               size: 20,
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: ViewType.list,
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: _currentViewType == ViewType.list
//                                   ? Colors.blueGrey[100]
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.list_rounded,
//                               color: Colors.blueGrey[800],
//                               size: 22,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Text(
//                             'List View',
//                             style: GoogleFonts.inter(
//                               fontSize: 15,
//                               fontWeight: _currentViewType == ViewType.list
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                             ),
//                           ),
//                           if (_currentViewType == ViewType.list) ...[
//                             const Spacer(),
//                             Icon(
//                               Icons.check,
//                               color: Colors.blueGrey[800],
//                               size: 20,
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: ViewType.compactGrid,
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: _currentViewType == ViewType.compactGrid
//                                   ? Colors.blueGrey[100]
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.apps_rounded,
//                               color: Colors.blueGrey[800],
//                               size: 22,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Text(
//                             'Compact',
//                             style: GoogleFonts.inter(
//                               fontSize: 15,
//                               fontWeight: _currentViewType == ViewType.compactGrid
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                             ),
//                           ),
//                           if (_currentViewType == ViewType.compactGrid) ...[
//                             const Spacer(),
//                             Icon(
//                               Icons.check,
//                               color: Colors.blueGrey[800],
//                               size: 20,
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//         body: SafeArea(
//           child: _buildDefaultContent(),
//         ),
//       ),
//     );
//   }
//
//   IconData _getViewIcon() {
//     switch (_currentViewType) {
//       case ViewType.grid:
//         return Icons.grid_view_rounded;
//       case ViewType.compactGrid:
//         return Icons.apps_rounded;
//       case ViewType.list:
//         return Icons.list_rounded;
//       case ViewType.card:
//         return Icons.view_agenda_rounded;
//     }
//   }
//
//   void _performUnifiedSearch(String query) {
//     // Your search implementation
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = [];
//       });
//       return;
//     }
//     // Add your search logic here
//   }
//
//   Widget _buildDefaultContent() {
//     final songsProvider = Provider.of<SongCollectionProvider>(context);
//
//     if (songsProvider.isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               color: Colors.blueGrey[800],
//               strokeWidth: 3,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Loading songs...',
//               style: GoogleFonts.inter(
//                 color: Colors.blueGrey[600],
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (songsProvider.error.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               "Error: ${songsProvider.error}",
//               textAlign: TextAlign.center,
//               style: GoogleFonts.inter(fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final brideSongs = songsProvider.brideSongs;
//     final ugushimishaSongs = songsProvider.ugushimishaSongs();
//     final agakizaSongs = songsProvider.agakizaSongs();
//
//     // Show search results if searching
//     if (_isSearching && _searchResults.isNotEmpty) {
//       return SongViewScreen(
//         songs: _searchResults,
//         viewType: _currentViewType,
//       );
//     }
//
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.blueGrey[800],
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: TabBar(
//             indicatorColor: Colors.white,
//             indicatorWeight: 3,
//             indicatorSize: TabBarIndicatorSize.tab,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white60,
//             labelStyle: GoogleFonts.inter(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.3,
//             ),
//             unselectedLabelStyle: GoogleFonts.inter(
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//             ),
//             tabs: [
//               Tab(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Umugeni"),
//                     const SizedBox(width: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '${brideSongs.length}',
//                         style: GoogleFonts.inter(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Tab(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Ugushimisha"),
//                     const SizedBox(width: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '${ugushimishaSongs.length}',
//                         style: GoogleFonts.inter(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Tab(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Agakiza"),
//                     const SizedBox(width: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '${agakizaSongs.length}',
//                         style: GoogleFonts.inter(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             children: [
//               SongViewScreen(songs: brideSongs, viewType: _currentViewType),
//               SongViewScreen(songs: ugushimishaSongs, viewType: _currentViewType),
//               SongViewScreen(songs: agakizaSongs, viewType: _currentViewType),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // View Type Enum
// enum ViewType {
//   grid,
//   compactGrid,
//   list,
//   card,
// }
//
// // Enhanced Song View Screen
// class SongViewScreen extends StatefulWidget {
//   final List<Song> songs;
//   final ViewType viewType;
//
//   const SongViewScreen({
//     Key? key,
//     required this.songs,
//     required this.viewType,
//   }) : super(key: key);
//
//   @override
//   State<SongViewScreen> createState() => _SongViewScreenState();
// }
//
// class _SongViewScreenState extends State<SongViewScreen>
//     with AutomaticKeepAliveClientMixin {
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     if (widget.songs.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.music_note_rounded, size: 80, color: Colors.grey[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Nta ndirimbo zibonetse',
//               style: GoogleFonts.inter(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     switch (widget.viewType) {
//       case ViewType.grid:
//         return _buildGridView(crossAxisCount: 4);
//       case ViewType.compactGrid:
//         return _buildGridView(crossAxisCount: 6);
//       case ViewType.list:
//         return _buildListView();
//       case ViewType.card:
//         return _buildCardView();
//     }
//   }
//
//   Widget _buildGridView({required int crossAxisCount}) {
//     return Container(
//       color: Colors.grey[50],
//       padding: const EdgeInsets.all(16.0),
//       child: GridView.builder(
//         itemCount: widget.songs.length,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           mainAxisSpacing: 12.0,
//           crossAxisSpacing: 12.0,
//           childAspectRatio: 1.1,
//         ),
//         itemBuilder: (context, index) => _buildGridItem(index),
//       ),
//     );
//   }
//
//   Widget _buildGridItem(int index) {
//     return Material(
//       color: Colors.white,
//       elevation: 2,
//       shadowColor: Colors.blueGrey.withOpacity(0.3),
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: () => _getSongLyrics(widget.songs[index]),
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blueGrey[600]!,
//                 Colors.blueGrey[800]!,
//               ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Background pattern
//               Positioned(
//                 right: -10,
//                 bottom: -10,
//                 child: Icon(
//                   Icons.music_note_rounded,
//                   size: 60,
//                   color: Colors.white.withOpacity(0.1),
//                 ),
//               ),
//               // Content
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       '${index + 1}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 32,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         height: 1,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.music_note_rounded,
//                             color: Colors.white,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Indirimbo',
//                             style: GoogleFonts.inter(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildListView() {
//     return Container(
//       color: Colors.grey[50],
//       child: ListView.builder(
//         padding: const EdgeInsets.all(12.0),
//         itemCount: widget.songs.length,
//         itemBuilder: (context, index) => _buildListItem(index),
//       ),
//     );
//   }
//
//   Widget _buildListItem(int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blueGrey.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 8,
//         ),
//         leading: Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blueGrey[600]!, Colors.blueGrey[800]!],
//             ),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Center(
//             child: Text(
//               '${index + 1}',
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 20,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           'Indirimbo ${index + 1}',
//           style: GoogleFonts.inter(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             color: Colors.blueGrey[900],
//           ),
//         ),
//         subtitle: Text(
//           widget.songs[index].category ?? 'Category',
//           style: GoogleFonts.inter(
//             color: Colors.blueGrey[500],
//             fontSize: 13,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.blueGrey[50],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             Icons.chevron_right_rounded,
//             color: Colors.blueGrey[800],
//             size: 24,
//           ),
//         ),
//         onTap: () => _getSongLyrics(widget.songs[index]),
//       ),
//     );
//   }
//
//   Widget _buildCardView() {
//     return Container(
//       color: Colors.grey[50],
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         itemCount: widget.songs.length,
//         itemBuilder: (context, index) => _buildCardItem(index),
//       ),
//     );
//   }
//
//   Widget _buildCardItem(int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blueGrey.withOpacity(0.15),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _getSongLyrics(widget.songs[index]),
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blueGrey[600]!, Colors.blueGrey[800]!],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blueGrey.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${index + 1}',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 32,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Indirimbo ${index + 1}',
//                         style: GoogleFonts.inter(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blueGrey[900],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.music_note_rounded,
//                             size: 16,
//                             color: Colors.blueGrey[500],
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             widget.songs[index].category ?? 'Category',
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               color: Colors.blueGrey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blueGrey[50],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.play_arrow_rounded,
//                     size: 32,
//                     color: Colors.blueGrey[700],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _getSongLyrics(Song song) {
//     // Your existing navigation logic
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SongLyricsScreen(song: song),
//       ),
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }