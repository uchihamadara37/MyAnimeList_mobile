import 'package:flutter/material.dart';
// Import ApiService and Anime model
import '../services/api_service.dart'; // Path might need adjustment
import '../models/anime_model.dart'; // Path might need adjustment

class AnimeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Anime> _animeList = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;

  // Filter parameters
  String _currentSearchQuery = '';
  String _currentStatusFilter = ''; // e.g., 'airing', 'complete'
  Set<String> _currentGenreFilter = {}; // e.g., 'action', 'comedy'
  String _currentRatingFilter = ''; // e.g., 'g', 'pg', 'pg13', etc.
  double _currentMinScoreFilter = 0.0; // Minimum score filter
  // Add other filters as needed: rating, genre, etc.
  List<Map<String, dynamic>> _genres = []; // For genre filter
  bool _isLoadingGenres = false;


  List<Anime> get animeList => _animeList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  List<Map<String, dynamic>> get genres => _genres;
  bool get isLoadingGenres => _isLoadingGenres;
  // untuk filter
  String get currentStatusFilter => _currentStatusFilter;
  Set<String> get currentGenreFilter => _currentGenreFilter;
  String get currentRatingFilter => _currentRatingFilter;
  double get currentMinScoreFilter => _currentMinScoreFilter;
  String get currentSearchQuery => _currentSearchQuery;

  AnimeProvider() {
    fetchInitialAnime();
    fetchGenresList();
  }

  Future<void> fetchInitialAnime() async {
    _currentPage = 1;
    _animeList = [];
    _hasMore = true;
    await fetchMoreAnime();
  }

  Future<void> fetchMoreAnime() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newAnime = await _apiService.fetchAnime(
        query: _currentSearchQuery,
        status: _currentStatusFilter,
        genres: _currentGenreFilter,
        rating: _currentRatingFilter,
        min_score: _currentMinScoreFilter,
        orderBy: 'popularity', // or any other field you want to order by
        page: _currentPage,
        limit: 15, // Fetch fewer items per page for better performance
      );
      if (newAnime.isEmpty) {
        _hasMore = false;
      } else {
        _animeList.addAll(newAnime);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Error in fetchMoreAnime: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchGenresList() async {
    _isLoadingGenres = true;
    notifyListeners();
    try {
      _genres = await _apiService.fetchGenres();
    } catch (e) {
      print("Error fetching genres: $e");
      // Handle error appropriately
    } finally {
      _isLoadingGenres = false;
      notifyListeners();
    }
  }


  void applySearchQuery(String query) {
    _currentSearchQuery = query;
    fetchInitialAnime(); // Refetch with new query
  }

  void applyStatusFilter(String status, Set<String> genre, String rating, double minScore) {
    _currentStatusFilter = status;
    _currentGenreFilter = genre;
    _currentRatingFilter = rating;
    _currentMinScoreFilter = minScore;
    fetchInitialAnime(); // Refetch with new status
  }
  
  void clearFilters() {
    _currentSearchQuery = '';
    _currentStatusFilter = '';
    _currentGenreFilter = {};
    _currentRatingFilter = '';
    _currentMinScoreFilter = 0;
    fetchInitialAnime();
  }
}
