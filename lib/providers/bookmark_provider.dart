import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_anime_list_gemini/models/anime_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // Alias for path package
// Import DatabaseHelper and models
import '../services/database_helper.dart'; // Path might need adjustment
import '../models/bookmark_container_model.dart'; // Path might need adjustment
import '../models/bookmarked_anime_model.dart'; // Path might need adjustment

class BookmarkProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<BookmarkContainerModel> _containers = [];
  Map<int, List<BookmarkedAnimeModel>> _bookmarkedAnimeMap = {}; // containerId -> List<Anime>
  bool _isLoading = false;
  String _errorMessage = '';

  List<BookmarkContainerModel> get containers => _containers;
  Map<int, List<BookmarkedAnimeModel>> get bookmarkedAnimeMap => _bookmarkedAnimeMap;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  BookmarkProvider() {
    loadContainers();
  }

  Future<void> loadContainers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _containers = await _dbHelper.queryAllContainers();
      for (var container in _containers) {
        if (container.id != null) {
          await loadBookmarkedAnimeForContainer(container.id!);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContainer(String name, XFile? imageFile) async {
    _isLoading = true;
    notifyListeners();
    String? logoPath;
    if (imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imageFile.path); // Use p.basename
      final newPath = p.join(directory.path, fileName); // Use p.join
      final File newImage = await File(imageFile.path).copy(newPath);
      logoPath = newImage.path;
    }

    final newContainer = BookmarkContainerModel(name: name, logoPath: logoPath);
    try {
      await _dbHelper.insertContainer(newContainer);
      await loadContainers(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateContainer(int id, String name, XFile? imageFile, String? existingLogoPath) async {
    _isLoading = true;
    notifyListeners();
    String? logoPath = existingLogoPath;

    if (imageFile != null) {
      // Delete old image if it exists and a new one is provided
      if (existingLogoPath != null && existingLogoPath.isNotEmpty) {
        final oldFile = File(existingLogoPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imageFile.path);
      final newPath = p.join(directory.path, fileName);
      final File newImage = await File(imageFile.path).copy(newPath);
      logoPath = newImage.path;
    }

    final updatedContainer = BookmarkContainerModel(id: id, name: name, logoPath: logoPath);
    try {
      await _dbHelper.updateContainer(updatedContainer);
      await loadContainers(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContainer(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Delete logo image if it exists
      final containerToDelete = _containers.firstWhere((c) => c.id == id, orElse: () => BookmarkContainerModel(name: ''));
      if (containerToDelete.logoPath != null && containerToDelete.logoPath!.isNotEmpty) {
        final logoFile = File(containerToDelete.logoPath!);
        if (await logoFile.exists()) {
          await logoFile.delete();
        }
      }
      await _dbHelper.deleteContainer(id);
      _bookmarkedAnimeMap.remove(id); // Remove from local map
      await loadContainers(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookmarkedAnimeForContainer(int containerId) async {
    _isLoading = true;
    // notifyListeners(); // Potentially too many notifications if called in a loop
    try {
      final animeList = await _dbHelper.queryBookmarkedAnime(containerId);
      _bookmarkedAnimeMap[containerId] = animeList;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAnimeToContainer(int containerId, Anime anime) async {
    final bookmarkedAnime = BookmarkedAnimeModel(
      containerId: containerId,
      animeMalId: anime.malId,
      animeTitle: anime.title,
      animeImageUrl: anime.imageUrl,
    );
    try {
      int result = await _dbHelper.insertBookmarkedAnime(bookmarkedAnime);
      if (result != 0) { // 0 means it already existed or failed
        await loadBookmarkedAnimeForContainer(containerId); // Refresh list for this container
        notifyListeners();
        return true;
      }
      return false; // Already exists or failed
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeAnimeFromContainer(int bookmarkedAnimeId, int containerId) async {
    try {
      await _dbHelper.deleteBookmarkedAnime(bookmarkedAnimeId);
      await loadBookmarkedAnimeForContainer(containerId); // Refresh list for this container
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isAnimeInContainer(int animeMalId, int containerId) async {
    return await _dbHelper.isAnimeBookmarked(animeMalId, containerId);
  }
}