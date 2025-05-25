import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import providers, models, services, widgets
import '../providers/anime_providers.dart'; // Path might need adjustment
import '../providers/bookmark_provider.dart'; // Path might need adjustment
import '../models/anime_model.dart'; // Path might need adjustment
// import '../models/bookmark_container_model.dart'; // Path might need adjustment
import '../widgets/anime_card.dart'; // Path might need adjustment
import '../widgets/filter_options_widget.dart'; // Path might need adjustment

class AnimeListScreen extends StatefulWidget {
  @override
  _AnimeListScreenState createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial fetch is handled by provider constructor
    // final animeProvider = Provider.of<AnimeProvider>(context, listen: false);
    // animeProvider.fetchInitialAnime(); // if not in constructor

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        Provider.of<AnimeProvider>(context, listen: false).fetchMoreAnime();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterOptionsWidget(); // Defined in widgets/filter_options_widget.dart
      },
    );
  }
  
  void _showAddToBookmarkDialog(BuildContext context, Anime anime) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    if (bookmarkProvider.containers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada wadah bookmark. Buat satu terlebih dahulu!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Tambah ke Wadah Bookmark'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bookmarkProvider.containers.length,
              itemBuilder: (context, index) {
                final container = bookmarkProvider.containers[index];
                return ListTile(
                  title: Text(container.name),
                  onTap: () async {
                    bool success = await bookmarkProvider.addAnimeToContainer(container.id!, anime);
                    Navigator.of(dialogContext).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? '${anime.title} ditambahkan ke ${container.name}' : '${anime.title} sudah ada di ${container.name} atau gagal ditambahkan.')),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Anime'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari anime...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<AnimeProvider>(context, listen: false).applySearchQuery('');
                  },
                ),
              ),
              onSubmitted: (query) {
                Provider.of<AnimeProvider>(context, listen: false).applySearchQuery(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<AnimeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.animeList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage.isNotEmpty && provider.animeList.isEmpty) {
                  return Center(child: Text('Error: ${provider.errorMessage}\nCoba lagi nanti.'));
                }
                if (provider.animeList.isEmpty) {
                  return Center(child: Text('Tidak ada anime ditemukan.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.animeList.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.animeList.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final anime = provider.animeList[index];
                    return AnimeCard(
                      anime: anime,
                      onTap: () {
                        // Navigate to anime detail screen (not implemented in this scope)
                        print('Tapped on ${anime.title}');
                      },
                      onBookmarkTap: () => _showAddToBookmarkDialog(context, anime),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}