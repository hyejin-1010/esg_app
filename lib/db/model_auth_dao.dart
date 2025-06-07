import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/favorite_model.dart';

class AuthDao {
  // 같은 닉네임이 있으면 true, 없으면 false
  Future<bool> checkDuplicateNickname(String nickname) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      '''
      SELECT nickname
      FROM Auth
      WHERE nickname = ?
    ''',
      [nickname],
    );
    return res.isNotEmpty;
  }

  Future<int> insertItem(Favorite item) async {
    final db = await DBHelper.database;
    return await db.insert('Favorite', item.toMap());
  }
}
