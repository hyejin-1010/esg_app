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

  Future<bool> deductReward(int userId, int amount) async {
    final db = await _db;
    final currentReward = await getReward(userId);

    if (currentReward < amount) {
      return false; // 보유 포인트가 부족
    }

    await db.update(
      'Auth',
      {'reward': currentReward - amount},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return true; // 차감 성공
  }

  Future<void> updateUserPoints(int userId, int points) async {
    final db = await DBHelper.database;
    await db.update(
      'Auth',
      {'reward': points},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateProfileImageUrl(int userId, String imageUrl) async {
    final db = await _db;
    await db.update(
      'Auth',
      {'profile_image_url': imageUrl},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<String?> getProfileImageUrl(int userId) async {
    final db = await _db;
    final res = await db.rawQuery(
      '''
      SELECT profile_image_url FROM Auth WHERE id = ?
    ''',
      [userId],
    );
    if (res.isNotEmpty) return res.first['profile_image_url'] as String?;
    return null;
  }

  Future<int> getCo2(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'Auth',
      columns: ['co2'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return 0;
    return maps.first['co2'] as int;
  }

  Future<void> updateCo2(int userId, int co2) async {
    final db = await _db;
    await db.update(
      'Auth',
      {'co2': co2},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> addCo2(int userId, int additionalCo2) async {
    final db = await _db;
    final currentCo2 = await getCo2(userId);
    final newCo2 = currentCo2 + additionalCo2;
    
    await db.update(
      'Auth',
      {'co2': newCo2},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
