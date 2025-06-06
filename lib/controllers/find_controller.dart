import 'package:esg_app/db/model_store_dao.dart';
import 'package:esg_app/models/store_model.dart';
import 'package:get/get.dart';

class FindController extends GetxController {
  final storeList = <Store>[].obs;
  final StoreDao _dao = StoreDao();

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    storeList.value = await _dao.getAllItems();
  }

  Future<Store?> getStore(int id) async {
    return await _dao.getStore(id);
  }
}
