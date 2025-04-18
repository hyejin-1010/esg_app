import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/mission_model.dart';

class MissionDao {
  Future<List<Mission>> getAllItems() async {
    final db = await DBHelper.database;
    final res = await db.query('Mission');
    return res.map((e) => Mission.fromMap(e)).toList();
  }

  Future<int> insertItem(Mission item) async {
    final db = await DBHelper.database;
    return await db.insert('Mission', item.toMap());
  }
}
