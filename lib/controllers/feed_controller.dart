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

  void loadItems() async {
    items.value = await _dao.getAllItems();
  }

  Future<void> addItem(Feed item) async {
    await _dao.insertItem(item);
    loadItems(); // 갱신
  }
}
