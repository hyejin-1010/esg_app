import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:get/get.dart';

class FeedDao {
  Future<List<Feed>> getAllItems() async {
    final authController = Get.find<AuthController>();
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      '''
      SELECT f.*, 
        CASE WHEN fav.user_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite,
        (SELECT COUNT(*) FROM Favorite WHERE feed_id = f.id) as favorite_count
      FROM Feed f
      LEFT JOIN Favorite fav ON f.id = fav.feed_id AND fav.user_id = ?
      ORDER BY f.created_at DESC
    ''',
      [authController.userId],
    );
    return res.map((e) => Feed.fromMap(e)).toList();
  }

  Future<int> insertItem(Feed item) async {
    final db = await DBHelper.database;
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
}
