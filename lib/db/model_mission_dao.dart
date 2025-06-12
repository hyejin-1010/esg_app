import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/mission_model.dart';

class MissionDao {
  Future<List<Mission>> getAllItems() async {
    final db = await DBHelper.database;
    final res = await db.query('Mission');
    return res.map((e) => Mission.fromMap(e)).toList();
  }

  Future<List<Mission>> getAvailableMissions(int? userId) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      '''
      SELECT m.* FROM Mission m
      WHERE m.id NOT IN (
        SELECT f.mission_id FROM Feed f
        WHERE f.user_id = ?
      )
    ''',
      [userId ?? 0],
    );
    return res.map((e) => Mission.fromMap(e)).toList();
  }

  Future<int> insertItem(Mission item) async {
    final db = await DBHelper.database;
    return await db.insert('Mission', item.toMap());
  }

  Future<Mission?> getMission(int id) async {
    final db = await DBHelper.database;
    final res = await db.query('Mission', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? Mission.fromMap(res.first) : null;
  }
}
