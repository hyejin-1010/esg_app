import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/db/model_mission_dao.dart';
import 'package:esg_app/models/mission_model.dart';
import 'package:get/get.dart';

class MissionController extends GetxController {
  final items = <Mission>[].obs;
  final MissionDao _dao = MissionDao();

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    final authController = Get.find<AuthController>();
    items.value = await _dao.getAvailableMissions(authController.userId);
  }

  Future<Mission?> getMission(int id) async {
    return await _dao.getMission(id);
  }
}
