import 'package:sqflite/sqflite.dart';
import 'model_plant_item.dart';

class PlantItemDao {
  final Database db;
  static const String tableName = 'plant_items';

  PlantItemDao(this.db);

  Future<List<PlantItem>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => PlantItem.fromMap(map)).toList();
  }

  Future<PlantItem?> getById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PlantItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(PlantItem item) async {
    return await db.insert(tableName, item.toMap());
  }

  Future<int> update(PlantItem item) async {
    return await db.update(
      tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 