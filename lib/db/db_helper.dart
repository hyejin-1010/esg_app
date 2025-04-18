import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    return await openDatabase(
      'assets/esg_app.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Feed (
            id INTEGER PRIMARY KEY,
            conten TEXT,
            user_id INTEGER,
            user_name TEXT,
            created_at TEXT,
            updated_at TEXT,
            image_path_list TEXT,
            mission_id INTEGER,
            mission_name TEXT
          )
        ''');
      },
    );
  }
}
