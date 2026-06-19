import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('ecotips.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE progreso (
      id INTEGER PRIMARY KEY,
      puntos INTEGER,
      nivel INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE retos (
      id INTEGER PRIMARY KEY,
      completado INTEGER
    )
  ''');

  await db.insert(
    'progreso',
    {
      'id': 1,
      'puntos': 0,
      'nivel': 1,
    },
  );
}

  Future<void> updateProgress(
    int puntos,
    int nivel,
  ) async {
    final db = await instance.database;

    await db.update(
      'progreso',
      {
        'puntos': puntos,
        'nivel': nivel,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<Map<String, dynamic>> getProgress() async {
    final db = await instance.database;

    final result = await db.query(
      'progreso',
      where: 'id = ?',
      whereArgs: [1],
    );

    return result.first;
  }
  Future<void> saveChallenge(
  int id,
  bool completed,
) async {
  final db = await instance.database;

  await db.insert(
    'retos',
    {
      'id': id,
      'completado': completed ? 1 : 0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<bool>> loadChallenges(
  int totalChallenges,
) async {
  final db = await instance.database;

  final result = await db.query('retos');

  List<bool> completed =
      List.generate(totalChallenges, (_) => false);

  for (final row in result) {
    int id = row['id'] as int;

    if (id < totalChallenges) {
      completed[id] =
          (row['completado'] as int) == 1;
    }
  }

  return completed;
}
}