import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// Import models
import '../models/bookmark_container_model.dart'; // Path might need adjustment
import '../models/bookmarked_anime_model.dart'; // Path might need adjustment

class DatabaseHelper {
  static const _databaseName = "MyAnimeList.db";
  static const _databaseVersion = 1;

  static const tableBookmarkContainers = 'bookmark_containers';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnLogoPath = 'logoPath';

  static const tableBookmarkedAnime = 'bookmarked_anime';
  static const columnAnimeId = 'id'; // Primary key for this table
  static const columnContainerId = 'containerId'; // Foreign key to bookmark_containers
  static const columnAnimeMalId = 'animeMalId'; // MAL ID of the anime
  static const columnAnimeTitle = 'animeTitle';
  static const columnAnimeImageUrl = 'animeImageUrl';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // This opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableBookmarkContainers (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnLogoPath TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableBookmarkedAnime (
            $columnAnimeId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnContainerId INTEGER NOT NULL,
            $columnAnimeMalId INTEGER NOT NULL,
            $columnAnimeTitle TEXT NOT NULL,
            $columnAnimeImageUrl TEXT NOT NULL,
            FOREIGN KEY ($columnContainerId) REFERENCES $tableBookmarkContainers ($columnId) ON DELETE CASCADE
          )
          ''');
  }

  // Helper methods for Bookmark Containers
  Future<int> insertContainer(BookmarkContainerModel container) async {
    Database db = await instance.database;
    return await db.insert(tableBookmarkContainers, container.toMap());
  }

  Future<List<BookmarkContainerModel>> queryAllContainers() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableBookmarkContainers);
    return List.generate(maps.length, (i) {
      return BookmarkContainerModel.fromMap(maps[i]);
    });
  }

  Future<int> updateContainer(BookmarkContainerModel container) async {
    Database db = await instance.database;
    return await db.update(tableBookmarkContainers, container.toMap(),
        where: '$columnId = ?', whereArgs: [container.id]);
  }

  Future<int> deleteContainer(int id) async {
    Database db = await instance.database;
    // Also delete associated bookmarked anime
    await db.delete(tableBookmarkedAnime, where: '$columnContainerId = ?', whereArgs: [id]);
    return await db.delete(tableBookmarkContainers, where: '$columnId = ?', whereArgs: [id]);
  }

  // Helper methods for Bookmarked Anime
  Future<int> insertBookmarkedAnime(BookmarkedAnimeModel bookmarkedAnime) async {
    Database db = await instance.database;
    // Check if anime already exists in this container
    List<Map<String, dynamic>> existing = await db.query(
      tableBookmarkedAnime,
      where: '$columnContainerId = ? AND $columnAnimeMalId = ?',
      whereArgs: [bookmarkedAnime.containerId, bookmarkedAnime.animeMalId],
    );
    if (existing.isNotEmpty) {
      return 0; // Indicate that it was not inserted because it already exists
    }
    return await db.insert(tableBookmarkedAnime, bookmarkedAnime.toMap());
  }

  Future<List<BookmarkedAnimeModel>> queryBookmarkedAnime(int containerId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBookmarkedAnime,
      where: '$columnContainerId = ?',
      whereArgs: [containerId],
    );
    return List.generate(maps.length, (i) {
      return BookmarkedAnimeModel.fromMap(maps[i]);
    });
  }
  
  Future<int> deleteBookmarkedAnime(int bookmarkedAnimeId) async {
    Database db = await instance.database;
    return await db.delete(tableBookmarkedAnime, where: '$columnAnimeId = ?', whereArgs: [bookmarkedAnimeId]);
  }

  Future<bool> isAnimeBookmarked(int animeMalId, int containerId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBookmarkedAnime,
      where: '$columnContainerId = ? AND $columnAnimeMalId = ?',
      whereArgs: [containerId, animeMalId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }
}