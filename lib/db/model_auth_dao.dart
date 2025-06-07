import 'package:esg_app/db/db_helper.dart';

import '../models/auth.dart';

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

  // 같은 유저가 있으면 true, 없으면 false
  Future<bool> checkDuplicateUser(String email) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      '''
      SELECT email
      FROM Auth
      WHERE email = ?
    ''',
      [email],
    );
    return res.isNotEmpty;
  }

  Future<int> insertUser(AuthUser user) async {
    final db = await DBHelper.database;
    return await db.insert('Auth', AuthUser.toMap(user));
  }
}
