import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMindTrack {
  // Singleton instance
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

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
  }

  Future<int> insertCheckIn({
    required String date,
    required int mood,
    required int score,
    required String feelings,
    String? notes,
  }) async {
    final database = await db;
    return database.insert(
      'checkins',
      {
        'date': date,
        'mood': mood,
        'score': score,
        'feelings': feelings,
        'notes': notes ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllCheckIns() async {
    final database = await db;
    return database.query(
      'checkins',
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteCheckIn(int id) async {
    final database = await db;
    return database.delete(
      'checkins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final database = await db;
    return database.delete('checkins');
  }
}
