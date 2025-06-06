import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/store_model.dart';

class StoreDao {
  Future<List<Store>> getAllItems() async {
    final db = await DBHelper.database;
    final res = await db.query('Store');
    return res.map((e) => Store.fromMap(e)).toList();
  }

  Future<int> insertItem(Store item) async {
    final db = await DBHelper.database;
    return await db.insert('Store', item.toMap());
  }

  Future<Store?> getStore(int id) async {
    final db = await DBHelper.database;
    final res = await db.query('Store', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? Store.fromMap(res.first) : null;
  }
}
