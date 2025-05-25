import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import providers, models, screens
import '../providers/bookmark_provider.dart'; // Path might need adjustment
// import '../models/bookmark_container_model.dart'; // Path might need adjustment
import 'add_edit_bookmark_container_screen.dart'; // Path might need adjustment
import 'bookmark_detail_screen.dart'; // Path might need adjustment

class BookmarksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wadah Bookmark Saya'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.containers.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty && provider.containers.isEmpty) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          if (provider.containers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey[600]),
                  SizedBox(height: 16),
                  Text('Anda belum memiliki wadah bookmark.', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
                  SizedBox(height: 8),
                  Text('Buat satu dengan menekan tombol "+".', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.containers.length,
            itemBuilder: (context, index) {
              final container = provider.containers[index];
              final bookmarkedAnimeCount = provider.bookmarkedAnimeMap[container.id]?.length ?? 0;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: container.logoPath != null && container.logoPath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(container.logoPath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[700],
                                child: Icon(Icons.broken_image, color: Colors.grey[400]),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(Icons.bookmark_rounded, color: Colors.deepPurpleAccent[100]),
                        ),
                  title: Text(container.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('$bookmarkedAnimeCount anime', style: TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditBookmarkContainerScreen(container: container),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_rounded, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteContainer(context, provider, container.id!),
                      ),
                    ],
                  ),
                  onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookmarkDetailScreen(container: container),
                        ),
                      );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditBookmarkContainerScreen()),
          );
        },
        tooltip: 'Buat Wadah Bookmark Baru',
      ),
    );
  }

  void _confirmDeleteContainer(BuildContext context, BookmarkProvider provider, int containerId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Hapus Wadah?'),
          content: Text('Apakah Anda yakin ingin menghapus wadah bookmark ini beserta semua isinya?'),
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
                provider.deleteContainer(containerId);
                Navigator.of(dialogContext).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wadah bookmark dihapus.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}