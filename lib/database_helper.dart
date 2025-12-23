import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mind_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Version 1: Simple and clean
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // We ONLY create the 'favorites' table for offline articles.
    // 'users' and 'articles' are stored in Supabase (Cloud), not here.
    await db.execute('''
    CREATE TABLE favorites (
      id TEXT PRIMARY KEY,
      title TEXT,
      subtitle TEXT,
      image TEXT,
      full_content TEXT,
      url TEXT,
      colorValue INTEGER
    )
    ''');
  }

  // =======================================================================
  // FAVORITES (Saved Articles)
  // =======================================================================

  Future<int> addFavorite(Map<String, dynamic> article) async {
    final db = await instance.database;
    final data = Map<String, dynamic>.from(article);

    // Store the color as an integer so SQLite can save it
    if (data['color'] != null) {
      data['colorValue'] = (data['color']).value;
      data.remove('color');
    }

    // Use 'replace' so if we save the same article twice, it updates it instead of crashing
    return await db.insert(
      'favorites',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavorite(String id) async {
    final db = await instance.database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(String id) async {
    final db = await instance.database;
    final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;
    return await db.query('favorites');
  }
}
