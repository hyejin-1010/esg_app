import 'package:esg_app/db/model_feed_dao.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:get/get.dart';

class FeedController extends GetxController {
  final items = <Feed>[].obs;
  final FeedDao _dao = FeedDao();

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    items.value = await _dao.getAllItems();
  }

  Future<void> addItem(Feed item) async {
    // TODO: 현재 로그인 되어있는 유저 ID 가져와야 함
    item.userId = 1;
    await _dao.insertItem(item);
    loadItems(); // 갱신
  }
}
