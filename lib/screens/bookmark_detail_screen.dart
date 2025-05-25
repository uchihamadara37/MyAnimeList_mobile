// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_anime_list_gemini/models/bookmark_container_model.dart';
import 'package:my_anime_list_gemini/models/bookmarked_anime_model.dart';
import 'package:my_anime_list_gemini/providers/bookmark_provider.dart';
import 'package:provider/provider.dart';
// Import providers, models
// import '../providers/bookmark_provider.dart'; // Path might need adjustment
// import '../models/bookmark_container_model.dart'; // Path might need adjustment
// import '../models/bookmarked_anime_model.dart'; // Path might need adjustment

class BookmarkDetailScreen extends StatefulWidget {
  final BookmarkContainerModel container;

  BookmarkDetailScreen({required this.container});

  @override
  State<BookmarkDetailScreen> createState() => _BookmarkDetailScreenState();
}

class _BookmarkDetailScreenState extends State<BookmarkDetailScreen> {

  @override
  void initState() {
    super.initState();
    // Load anime for this specific container if not already loaded or needs refresh
    // This ensures data is fresh when navigating to this screen.
    // If data is already managed well by provider upon changes, this might be optional.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.container.id != null) {
        Provider.of<BookmarkProvider>(context, listen: false)
            .loadBookmarkedAnimeForContainer(widget.container.id!);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final List<BookmarkedAnimeModel> animeInContainer =
        bookmarkProvider.bookmarkedAnimeMap[widget.container.id] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.container.name),
      ),
      body: animeInContainer.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied_rounded, size: 70, color: Colors.grey[500]),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada anime di wadah ini.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan anime dari halaman Daftar Anime.',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: animeInContainer.length,
              itemBuilder: (context, index) {
                final bookmarkedAnime = animeInContainer[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        bookmarkedAnime.animeImageUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50, height: 70, color: Colors.grey[700],
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey[400])
                        ),
                      ),
                    ),
                    title: Text(bookmarkedAnime.animeTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    // subtitle: Text('MAL ID: ${bookmarkedAnime.animeMalId}', style: TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent[100]),
                      onPressed: () {
                        _confirmDeleteAnimeFromContainer(context, bookmarkProvider, bookmarkedAnime);
                      },
                    ),
                    onTap: () {
                      // Potentially navigate to an anime detail page using MAL ID
                      print('Tapped on bookmarked anime: ${bookmarkedAnime.animeTitle}');
                    },
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeleteAnimeFromContainer(BuildContext context, BookmarkProvider provider, BookmarkedAnimeModel anime) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Hapus Anime?'),
          content: Text('Apakah Anda yakin ingin menghapus "${anime.animeTitle}" dari wadah ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text('Hapus'),
              onPressed: () {
                if (anime.id != null && widget.container.id != null) {
                  provider.removeAnimeFromContainer(anime.id!, widget.container.id!);
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${anime.animeTitle}" dihapus dari wadah.')),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}