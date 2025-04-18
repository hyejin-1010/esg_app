import 'package:esg_app/models/mission_model.dart';
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
      onOpen: (Database db) async {
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Mission (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            reward INTEGER,
            icon_name TEXT
          )
        ''');

        // 초기 미션 데이터 삽입
        final missionCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Mission'),
        );
        if (missionCount == 0) {
          for (var mission in mockupMissionData) {
            await db.insert('Mission', mission.toMap());
          }
        }
      },
    );
  }
}

// TODO: 초기 미션 데이터
List<Mission> mockupMissionData = [
  Mission(
    id: 1,
    title: '텀블러 사용하기',
    description: 'CO2 절감량 20g',
    reward: 3,
    iconName: 'mission1.png',
  ),
  Mission(
    id: 2,
    title: '플로깅 활동',
    description: 'CO2 절감량 10g',
    reward: 3,
    iconName: 'mission2.png',
  ),
];
