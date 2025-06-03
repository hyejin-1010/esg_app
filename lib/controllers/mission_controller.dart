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
    // TODO: 현재 로그인한 사용자 ID 가져오기
    const userId = 1;
    items.value = await _dao.getAvailableMissions(userId);
  }
}
