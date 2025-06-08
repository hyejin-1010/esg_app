import 'package:esg_app/models/map_model.dart';
import 'package:get/get.dart';

class MapController extends GetxController {
  final poiCategories = <PoiCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPoiCategories();
  }

  Future<void> loadPoiCategories() async {
    poiCategories.value = [
      PoiCategory(id: 1, name: '카페'),
      PoiCategory(id: 2, name: '음식점'),
      PoiCategory(id: 3, name: '쇼핑'),
      PoiCategory(id: 4, name: '관광지'),
      PoiCategory(id: 5, name: '문화시설'),
      PoiCategory(id: 6, name: '베이커리'),
      PoiCategory(id: 7, name: '주유소'),
      PoiCategory(id: 8, name: '주차장'),
      PoiCategory(id: 9, name: '병원'),
      PoiCategory(id: 10, name: '보건소'),
      PoiCategory(id: 11, name: '약국'),
      PoiCategory(id: 12, name: '치과'),
      PoiCategory(id: 13, name: '치킨'),
    ];
  }
}
