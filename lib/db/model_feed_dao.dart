import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/db/model_auth_dao.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:get/get.dart';

class FeedDao {
  Future<List<Feed>> getAllItems() async {
    final authController = Get.find<AuthController>();
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      '''
      SELECT f.*, 
        au.nickname as user_name,
        CASE WHEN fav.user_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite,
        (SELECT COUNT(*) FROM Favorite WHERE feed_id = f.id) as favorite_count
      FROM Feed f
      LEFT JOIN Auth au ON f.user_id = au.id
      LEFT JOIN Favorite fav ON f.id = fav.feed_id AND fav.user_id = ?
      ORDER BY f.created_at DESC
    ''',
      [authController.userId],
    );
    return res.map((e) => Feed.fromMap(e)).toList();
  }

  Future<List<Feed>> getUserItems(int userId) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      '''
      SELECT f.*, 
        CASE WHEN fav.user_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite,
        (SELECT COUNT(*) FROM Favorite WHERE feed_id = f.id) as favorite_count
      FROM Feed f
      LEFT JOIN Favorite fav ON f.id = fav.feed_id AND fav.user_id = ?
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''',
      [userId, userId],
    );
    return res.map((e) => Feed.fromMap(e)).toList();
  }

  Future<int> insertItem(Feed item, int reward) async {
    final db = await DBHelper.database;
    final authDao = AuthDao();
    await authDao.updateUserPoints(item.userId, reward);
    return await db.insert('Feed', item.toMap());
  }

  Future<void> toggleFavorite(int feedId, int userId) async {
    final db = await DBHelper.database;
    final favorite = await db.query(
      'Favorite',
      where: 'feed_id = ? AND user_id = ?',
      whereArgs: [feedId, userId],
    );

    if (favorite.isEmpty) {
      await db.insert('Favorite', {'feed_id': feedId, 'user_id': userId});
    } else {
      await db.delete(
        'Favorite',
        where: 'feed_id = ? AND user_id = ?',
        whereArgs: [feedId, userId],
      );
    }
  }

  Future<Feed> getItem(int id) async {
    final db = await DBHelper.database;
    final res = await db.query('Feed', where: 'id = ?', whereArgs: [id]);
    return Feed.fromMap(res.first);
  }

  Future<bool> deleteItem(int feedId) async {
    final db = await DBHelper.database;
    final res = await db.delete('Feed', where: 'id = ?', whereArgs: [feedId]);
    return res > 0;
  }
}
