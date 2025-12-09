import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jejak_sehat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE steps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      step_count INTEGER NOT NULL
    )
    ''');
  }

  Future<void> insertOrUpdateStep(String date, int steps) async {
    final db = await instance.database;
    final result = await db.query('steps', where: 'date = ?', whereArgs: [date]);

    if (result.isNotEmpty) {
      await db.update('steps', {'step_count': steps}, where: 'date = ?', whereArgs: [date]);
    } else {
      await db.insert('steps', {'date': date, 'step_count': steps});
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('steps', orderBy: "date DESC");
  }
}