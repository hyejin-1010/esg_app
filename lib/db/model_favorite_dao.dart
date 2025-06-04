import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/favorite_model.dart';

class FavoriteDao {
  Future<List<Favorite>> getAllItems() async {
    final db = await DBHelper.database;
    final res = await db.query('Favorite');
    // TODO: 추후 User Model join 필요
    return res.map((e) => Favorite.fromMap(e)).toList();
  }

  Future<int> insertItem(Favorite item) async {
    final db = await DBHelper.database;
    return await db.insert('Favorite', item.toMap());
  }
}
