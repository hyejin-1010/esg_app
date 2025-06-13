import 'package:esg_app/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/auth.dart';

class AuthDao {
  static final AuthDao _instance = AuthDao._internal();
  factory AuthDao() => _instance;
  AuthDao._internal();

  Future<Database> get _db async => await DBHelper.database;

  // 같은 닉네임이 있으면 true, 없으면 false
  Future<bool> checkDuplicateNickname(String nickname) async {
    final db = await _db;
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

  // 같은 이메일이 있으면 true, 없으면 false
  Future<bool> checkDuplicateEmail(String email) async {
    final db = await _db;
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

  // 같은 유저가 있으면 true, 없으면 false
  Future<bool> checkDuplicateUser(String email) async {
    final db = await _db;
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
    final db = await _db;
    return await db.insert('Auth', AuthUser.toMap(user));
  }

  Future<AuthUser?> login(String email, String password) async {
    final db = await _db;
    final res = await db.rawQuery(
      '''
      SELECT * FROM Auth WHERE email = ? AND password = ?
    ''',
      [email, password],
    );
    if (res.isNotEmpty) return AuthUser.fromJson(res.first);
    return null;
  }

  Future<String?> getNicknameByUserId(int userId) async {
    final db = await _db;
    final res = await db.rawQuery(
      '''
      SELECT nickname FROM Auth WHERE id = ?
    ''',
      [userId],
    );
    if (res.isNotEmpty) return res.first['nickname'] as String;
    return null;
  }

  Future<void> updateNickname(String email, String newNickname) async {
    final db = await _db;
    await db.update(
      'Auth',
      {'nickname': newNickname},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> getReward(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'Auth',
      columns: ['reward'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return 0;
    return maps.first['reward'] as int;
  }
}
