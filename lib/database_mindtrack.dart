import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseMindTrack {
  static final DatabaseMindTrack instance = DatabaseMindTrack._internal();
  DatabaseMindTrack._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mindtrack.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE checkins(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mood INTEGER NOT NULL,    
        score INTEGER NOT NULL,    
        feelings TEXT NOT NULL,     
        notes TEXT                  
      )
    ''');
    // Music
    await db.execute('''
      CREATE TABLE music(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconCode INTEGER NOT NULL,
        audioPath TEXT NOT NULL
      )
    ''');
    // Exercises
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconCode INTEGER NOT NULL
      )
    ''');
    // Therapy History
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        detail TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    await _defaultData(db);
  }

  Future<void> _defaultData(Database db) async {
    // Default Music
    final List<Map<String, dynamic>> musicList = [
      {
        'title': 'Rainy Mood',
        'description': 'Calming rain sounds',
        'iconCode': 0xe6bd,
        'audioPath': 'assets/audio/rain.mp3',
      },
      {
        'title': 'Forest Walk',
        'description': 'Birds and nature',
        'iconCode': 0xe29c,
        'audioPath': 'assets/audio/forest.mp3',
      },
      {
        'title': 'Deep Focus',
        'description': 'White noise for study',
        'iconCode': 0xf01e,
        'audioPath': 'assets/audio/focus.mp3',
      },
      {
        'title': 'Ocean Waves',
        'description': 'Gentle beach tides',
        'iconCode': 0xe6c3,
        'audioPath': 'assets/audio/ocean.mp3',
      },
    ];
    for (var song in musicList) {
      await db.insert('music', song);
    }

    // Default Exercises
    final List<Map<String, dynamic>> exerciseList = [
      {
        'category': 'Yoga',
        'title': 'Child\'s Pose',
        'description': 'Kneel and fold forward.',
        'iconCode': 0xf5f3,
      },
      {
        'category': 'Yoga',
        'title': 'Tree Pose',
        'description': 'Stand on one leg.',
        'iconCode': 0xe406,
      },
      {
        'category': 'Pilates',
        'title': 'The Hundred',
        'description': 'Lie back, pump arms.',
        'iconCode': 0xe65e,
      },
      {
        'category': 'Walking',
        'title': 'Power Walk',
        'description': 'Walk fast.',
        'iconCode': 0xe5ce,
      },
      {
        'category': 'Tai Chi',
        'title': 'Cloud Hands',
        'description': 'Wave hands like clouds.',
        'iconCode': 0xe16d,
      },
    ];
    for (var ex in exerciseList) {
      await db.insert('exercises', ex);
    }
  }

  // History
  Future<int> recordHistory(String type, String detail) async {
    final database = await db;
    final String timeString = DateTime.now().toIso8601String();

    // 1. Local SQLite
    int id = await database.insert('history', {
      'type': type,
      'detail': detail,
      'timestamp': timeString,
    });
    debugPrint("✅ Saved to Local SQLite (ID: $id)");

    // 2. Supabase Cloud
    try {
      await Supabase.instance.client.from('history').insert({
        'type': type,
        'detail': detail,
        'timestamp': timeString,
      });
      debugPrint("✅ Synced to Supabase!");
    } catch (e) {
      debugPrint("❌ Supabase Sync Failed: $e");
    }
    return id;
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final database = await db;
    return await database.query('history', orderBy: 'timestamp DESC');
  }

  Future<int> clearHistory() async {
    final database = await db;
    return await database.delete('history');
  }

  // Music
  Future<List<Map<String, dynamic>>> getAllMusic() async {
    final db = await instance.db;
    return db.query('music');
  }

  Future<int> insertMusic(Map<String, dynamic> row) async {
    final db = await instance.db;
    return db.insert('music', row);
  }

  Future<int> updateMusic(Map<String, dynamic> row) async {
    final db = await instance.db;
    return db.update('music', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteMusic(int id) async {
    final db = await instance.db;
    return db.delete('music', where: 'id = ?', whereArgs: [id]);
  }

  // Exercise
  Future<List<Map<String, dynamic>>> getExercises(String? cat) async {
    final db = await instance.db;
    return cat == null
        ? db.query('exercises')
        : db.query('exercises', where: 'category = ?', whereArgs: [cat]);
  }

  Future<int> insertExercise(Map<String, dynamic> row) async {
    final db = await instance.db;
    return db.insert('exercises', row);
  }

  Future<int> updateExercise(Map<String, dynamic> row) async {
    final db = await instance.db;
    return db.update('exercises', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteExercise(int id) async {
    final db = await instance.db;
    return db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertCheckIn({
    required String date,
    required int mood,
    required int score,
    required String feelings,
    String? notes,
  }) async {
    final database = await db;
    return database.insert('checkins', {
      'date': date,
      'mood': mood,
      'score': score,
      'feelings': feelings,
      'notes': notes ?? '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCheckIns() async {
    final database = await db;
    return database.query('checkins', orderBy: 'date DESC');
  }

  Future<int> deleteCheckIn(int id) async {
    final database = await db;
    return database.delete('checkins', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final database = await db;
    return database.delete('checkins');
  }
}
