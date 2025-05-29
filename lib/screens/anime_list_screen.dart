import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/anime_providers.dart';
import '../providers/bookmark_provider.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import '../widgets/filter_options_widget.dart';
import '../utils/shared_prefs_util.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'anime_detail_screen.dart';

class AnimeListScreen extends StatefulWidget {
  @override
  _AnimeListScreenState createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _lastOpenedText;

  @override
  void initState() {
    super.initState();

    print('AnimeListScreen loaded');

    (() async {
      await initializeDateFormatting('id_ID');

      final isoString = await SharedPrefsUtil.getLastOpened();
      print('Dari SharedPreferences: $isoString');

      if (isoString != null) {
        final date = DateTime.tryParse(isoString);
        final formatted =
            date != null
                ? DateFormat("d MMMM yyyy, HH:mm", 'id_ID').format(date)
                : "Tidak diketahui";

        setState(() {
          _lastOpenedText = "Terakhir dibuka: $formatted";
        });

        print('Formatted: $_lastOpenedText');
      } else {
        print('Data kosong dari SharedPreferences');
      }
    })();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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
        return FilterOptionsWidget();
      },
    );
  }

  void _showAddToBookmarkDialog(BuildContext context, Anime anime) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(
      context,
      listen: false,
    );
    if (bookmarkProvider.containers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada wadah bookmark. Buat satu terlebih dahulu!'),
        ),
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
                    bool success = await bookmarkProvider.addAnimeToContainer(
                      container.id!,
                      anime,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${anime.title} ditambahkan ke ${container.name}'
                              : '${anime.title} sudah ada di ${container.name} atau gagal ditambahkan.',
                        ),
                      ),
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
    print(">>> AnimeListScreen build dijalankan"); // DEBUG

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              _lastOpenedText ?? 'Sedang memuat waktu terakhir dibuka...',
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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
                    Provider.of<AnimeProvider>(
                      context,
                      listen: false,
                    ).applySearchQuery('');
                  },
                ),
              ),
              onSubmitted: (query) {
                Provider.of<AnimeProvider>(
                  context,
                  listen: false,
                ).applySearchQuery(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<AnimeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.animeList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage.isNotEmpty &&
                    provider.animeList.isEmpty) {
                  return Center(
                    child: Text(
                      'Error: ${provider.errorMessage}\nCoba lagi nanti.',
                    ),
                  );
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimeDetailScreen(anime: anime),
                          ),
                        );
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
