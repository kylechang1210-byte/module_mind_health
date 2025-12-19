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

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Mind Track Module
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

    // Therapy Module
    // Music Table
    await db.execute(
      ''
          'CREATE TABLE music('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'title TEXT NOT NULL,'
          'description TEXT NOT BULL,'
          'iconCode INTEGER NOT NULL,'
          'audioPath TEXT NOT NULL'
          ')',
    );

    // Mindful Movement Table
    await db.execute(
      ''
          'CREATE TABLE exercises('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'category TEXT NOT NULL,'
          'title TEXT NOT NULL,'
          'description TEXT NOT NULL,'
          'iconCode INTEGER NOT NULL'
          ')',
    );

    // Insert default data of Therapy Module
    await _defaultData(db);
  }

  // Helper of insert default data in Therapy Module
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
        'audioPath': 'assets/audio/white_noise.mp3',
      },
      {
        'title': 'Ocean Waves',
        'description': 'Gentle beach tides',
        'iconCode': 0xe6c3,
        //'audioPath': 'assets/audio/ocean.mp3',
      },
    ];

    for (var song in musicList) {
      await db.insert('music', song);
    }

    // Default Exercise
    final List<Map<String, dynamic>> exerciseList = [
      // Yoga
      {
        'category': 'Yoga',
        'title': 'Child\'s Pose',
        'description': 'Kneel and fold forward.',
        'iconCode': 0xf5f3,
      }, // Icons.baby_changing_station
      {
        'category': 'Yoga',
        'title': 'Cat-Cow Flow',
        'description': 'Arch back up, dip belly down.',
        'iconCode': 0xe6c3,
      }, // Icons.waves
      {
        'category': 'Yoga',
        'title': 'Tree Pose',
        'description': 'Stand on one leg, hands at heart.',
        'iconCode': 0xe406,
      }, // Icons.nature_people

      // Pilates
      {
        'category': 'Pilates',
        'title': 'The Hundred',
        'description': 'Lie back, pump arms by sides.',
        'iconCode': 0xe65e,
      }, // Icons.timer
      {
        'category': 'Pilates',
        'title': 'Leg Circles',
        'description': 'Lie flat, circle one leg in air.',
        'iconCode': 0xe3a9,
      }, // Icons.loop
      {
        'category': 'Pilates',
        'title': 'Spine Stretch',
        'description': 'Sit tall, reach forward.',
        'iconCode': 0xe03d,
      }, // Icons.accessibility_new

      // Walking
      {
        'category': 'Walking',
        'title': 'Warm Up',
        'description': 'Slow pace for 2 mins.',
        'iconCode': 0xe1d2,
      }, // Icons.directions_walk
      {
        'category': 'Walking',
        'title': 'Power Walk',
        'description': 'Walk fast, swing arms.',
        'iconCode': 0xe5ce,
      }, // Icons.speed
      {
        'category': 'Walking',
        'title': 'Mindful Cool Down',
        'description': 'Slow stroll, breathe deeply.',
        'iconCode': 0xe404,
      }, // Icons.nature

      // Tai Chi
      {
        'category': 'Tai Chi',
        'title': 'Opening the Gate',
        'description': 'Float arms up and down.',
        'iconCode': 0xe23f,
      }, // Icons.expand
      {
        'category': 'Tai Chi',
        'title': 'Brush Knee',
        'description': 'Push palm, brush knee.',
        'iconCode': 0xe62c,
      }, // Icons.swipe
      {
        'category': 'Tai Chi',
        'title': 'Cloud Hands',
        'description': 'Wave hands like clouds.',
        'iconCode': 0xe16d,
      }, // Icons.cloud
    ];

    for (var ex in exerciseList) {
      await db.insert('exercises', ex);
    }
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

  // =====================Therapy CRUD Method======================
  // ----------------------Healing Music--------------------
  Future<List<Map<String, dynamic>>> getAllMusic() async {
    final database = await db;
    return database.query('music');
  }

  Future<int> insertMusic(Map<String, dynamic> row) async {
    final database = await db;
    return database.insert('music', row);
  }

  Future<int> updateMusic(Map<String, dynamic> row) async {
    final database = await db;
    int id = row['id'];
    return database.update('music', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMusic(int id) async {
    final database = await db;
    return database.delete('music', where: 'id = ?', whereArgs: [id]);
  }

  // -----------------------------Exercise---------------------------------
  Future<List<Map<String, dynamic>>> getExercises(String? category) async {
    final database = await db;
    if (category == null) {
      return database.query('exercises');
    } else {
      return database.query(
        'exercises',
        where: 'category = ?',
        whereArgs: [category],
      );
    }
  }

  Future<int> insertExercise(Map<String, dynamic> row) async {
    final database = await db;
    return database.insert('exercises', row);
  }

  Future<int> updateExercise(Map<String, dynamic> row) async {
    final database = await db;
    int id = row['id'];
    return database.update('exercises', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteExercise(int id) async {
    final database = await db;
    return database.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }
}