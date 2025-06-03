import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/models/feed_model.dart';

class FeedDao {
  Future<List<Feed>> getAllItems() async {
    final db = await DBHelper.database;
    final res = await db.query('Feed');
    // TODO: 추후 User Model join 필요
    return res.map((e) => Feed.fromMap(e)).toList();
  }

  Future<int> insertItem(Feed item) async {
    final db = await DBHelper.database;
    return await db.insert('Feed', item.toMap());
  }
}
