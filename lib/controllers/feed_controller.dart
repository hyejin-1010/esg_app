import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/db/model_feed_dao.dart';
import 'package:esg_app/models/feed_model.dart';
import 'package:get/get.dart';

class FeedController extends GetxController {
  final items = <Feed>[].obs;
  final userItems = <Feed>[].obs;
  final FeedDao _dao = FeedDao();

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    items.value = await _dao.getAllItems();
  }

  Future<void> loadUserItems() async {
    final authController = Get.find<AuthController>();
    userItems.value = await _dao.getUserItems(authController.userId);
  }

  Future<void> addItem(Feed item) async {
    final authController = Get.find<AuthController>();
    item.userId = authController.userId;
    await _dao.insertItem(item);
    loadItems(); // 갱신
    loadUserItems(); // 사용자 게시물도 갱신
  }

  Future<void> toggleFavorite(int feedId) async {
    final authController = Get.find<AuthController>();
    await _dao.toggleFavorite(feedId, authController.userId);
    await loadItems();
    await loadUserItems(); // 사용자 게시물도 갱신
  }
}
