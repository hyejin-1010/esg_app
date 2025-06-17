import 'package:get/get.dart';
import 'package:esg_app/db/db_helper.dart';
import 'package:esg_app/db/model_purchase_history.dart';
import 'package:esg_app/controllers/auth.dart';
import 'package:esg_app/db/model_auth_dao.dart';

class MyPageController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final AuthDao _authDao = AuthDao();
  
  final RxList<Map<String, dynamic>> purchaseHistory = <Map<String, dynamic>>[].obs;
  final RxInt points = 0.obs;
  final RxString nickname = ''.obs;
  final RxInt co2 = 0.obs;

  Future<void> refreshData() async {
    await _loadPurchaseHistory();
    await _loadUserData();
    await _loadNickname();
    await _loadCo2();
  }

  Future<void> updateNickname(String email, String newNickname) async {
    await _authDao.updateNickname(email, newNickname);
    await refreshData();
  }

  Future<void> _loadPurchaseHistory() async {
    final userId = _authController.userId;
    if (userId == null) return;

    final db = await DBHelper.database;
    final dao = PurchaseHistoryDao(db);
    final history = await dao.getByUserId(userId);
    purchaseHistory.value = history;
  }

  Future<void> _loadUserData() async {
    if (_authController.user != null) {
      final points = await _authDao.getReward(_authController.user!.id);
      this.points.value = points;
    }
  }

  Future<void> _loadCo2() async {
    final userId = _authController.userId;
    if (userId == null) return;
    
    final co2Value = await _authDao.getCo2(userId);
    this.co2.value = co2Value;
  }

  Future<void> _loadNickname() async {
    final userId = _authController.userId;
    if (userId == null) return;
    
    final dbNickname = await _authDao.getNicknameByUserId(userId);
    final defaultNickname = _authController.user.email.split('@').first;
    
    nickname.value = dbNickname ?? defaultNickname;
  }
} 