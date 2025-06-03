import 'package:flutter/material.dart';
import 'package:my_anime_list_gemini/providers/anime_providers.dart';
import 'package:my_anime_list_gemini/utils/shared_prefs_util.dart';
import 'package:provider/provider.dart';
import 'anime_list_screen.dart';
import 'bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AnimeListScreen(),
    BookmarksScreen(),
  ];

  @override
void initState() {
  super.initState();
  print("[DEBUG] HomeScreen initState dipanggil");

  WidgetsBinding.instance.addPostFrameCallback((_) {
    loadFilters();
  });
}

void loadFilters() async {
  final filters = await   SharedPrefsUtil.getFilterPreferences();

  final status = filters['status'] ?? '';
  final genres = filters['genres'] != null ? Set<String>.from(filters['genres']) : <String>{};
  final rating = filters['rating'] ?? '';
  final minScore = filters['minScore'] ?? 0.0;

  print('[DEBUG] Filter yang diterapkan dari SharedPreferences:');
  print('Status: $status, Genres: $genres, Rating: $rating, MinScore: $minScore');

  await Provider.of<AnimeProvider>(context, listen: false).applyStatusFilter(
    status,
    genres,
    rating,
    minScore,
  );
}


  @override
  Widget build(BuildContext context) {
    print("[DEBUG] HomeScreen build dijalankan");

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Anime List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_rounded),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}