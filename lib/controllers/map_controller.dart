import 'dart:developer';

import 'package:esg_app/models/map_model.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class MapController extends GetxController {
  final poiCategories = <PoiCategory>[].obs;
  List<PoiItem> poiItems = [];
  List<PoiItem> nearbyPoiItems = <PoiItem>[].obs;
  int? selectedCategoryId;

  @override
  void onInit() {
    super.onInit();
    loadStoreData();
  }

  Future<void> loadStoreData() async {
    try {
      // store.json 파싱
      final String storeJsonString = await rootBundle.loadString(
        'assets/json/store.json',
      );
      final Map<String, dynamic> storeData = json.decode(storeJsonString);
      final List<dynamic> storeRecords = storeData['records'];

      // 카테고리 추출 및 중복 제거 (store.json)
      final Set<String> uniqueCategories =
          storeRecords
              .map(
                (record) =>
                    record['properties']['sub_cate_name'] as String? ?? '',
              )
              .where((category) => category.isNotEmpty)
              .toSet();

      // store.json의 POI 아이템 변환
      final List<PoiItem> storeItems =
          storeRecords.map((record) {
            final properties = record['properties'];
            return PoiItem(
              id: Uuid().v4(),
              title: properties['cot_conts_name'] ?? '',
              description: properties['cot_value_02'] ?? '',
              lat: (properties['cot_coord_y'] as num?)?.toDouble() ?? 0.0,
              lng: (properties['cot_coord_x'] as num?)?.toDouble() ?? 0.0,
              address: properties['cot_addr_full_old'] ?? '',
              roadAddress: properties['cot_addr_full_new'] ?? '',
              category: properties['sub_cate_name'] ?? '',
              tel: properties['cot_tel_no'] ?? '',
              url:
                  'https://map.naver.com/v5/search/${properties['cot_addr_full_new'] ?? ''}',
              imageUrl: faker.image.loremPicsum(
                random: faker.randomGenerator.integer(100),
              ),
            );
          }).toList();

      // trash.json 파싱
      final String trashJsonString = await rootBundle.loadString(
        'assets/json/trash.json',
      );
      final Map<String, dynamic> trashData = json.decode(trashJsonString);
      final List<dynamic> trashRecords = trashData['records'];

      // trash.json의 카테고리 추가
      final Set<String> trashCategories =
          trashRecords
              .map((record) => record['휴지통종류'] as String? ?? '')
              .where((category) => category.isNotEmpty)
              .toSet();
      uniqueCategories.addAll(trashCategories);

      // 카테고리 목록 업데이트
      poiCategories.value =
          uniqueCategories
              .toList()
              .asMap()
              .entries
              .map((entry) => PoiCategory(id: entry.key + 1, name: entry.value))
              .toList();

      // trash.json의 POI 아이템 변환
      final List<PoiItem> trashItems =
          trashRecords.map((record) {
            return PoiItem(
              id: Uuid().v4(),
              title: record['휴지통종류'] ?? '',
              description: record['관리기관명'] ?? '',
              lat: double.tryParse(record['위도'] ?? '0.0') ?? 0.0,
              lng: double.tryParse(record['경도'] ?? '0.0') ?? 0.0,
              address: record['소재지지번주소'] ?? '',
              roadAddress: record['소재지도로명주소'] ?? '',
              category: record['휴지통종류'] ?? '',
              tel: record['관리기관전화번호'] ?? '',
              url:
                  'https://map.naver.com/v5/search/${record['소재지도로명주소'] ?? ''}',
              imageUrl: '',
            );
          }).toList();

      // 모든 아이템 합치기
      poiItems = [...storeItems, ...trashItems];
      poiItems.shuffle(); // 랜덤 섞기
      poiItems = poiItems.toList();

      update();
      log(
        'Loaded ${poiItems.length} POI items (${storeItems.length} stores, ${trashItems.length} trash bins) and ${poiCategories.length} categories',
      );
    } catch (e) {
      log('Error loading data: $e');
    }
  }

  Future<void> filterCategory({
    required int? categoryId,
    required double lat,
    required double lng,
    double? zoom,
  }) async {
    if (categoryId == null) {
      final distance = _getDistanceByZoom(zoom ?? 11.0);

      final filteredItems =
          poiItems.where((item) {
            final itemDistance = Geolocator.distanceBetween(
              lat,
              lng,
              item.lat,
              item.lng,
            );
            return itemDistance <= distance;
          }).toList();

      filteredItems.shuffle();
      nearbyPoiItems = filteredItems.take(100).toList();
      update();
    } else {
      final distance = _getDistanceByZoom(zoom ?? 11.0);
      final categoryName =
          poiCategories.firstWhere((c) => c.id == categoryId).name;

      final filteredItems =
          poiItems.where((item) {
            final itemDistance = Geolocator.distanceBetween(
              lat,
              lng,
              item.lat,
              item.lng,
            );
            return itemDistance <= distance && item.category == categoryName;
          }).toList();

      nearbyPoiItems = filteredItems.toList();
      selectedCategoryId = categoryId;
      update();
    }
  }

  Future<void> updateNearbyPoiItemsByPosition(
    double lat,
    double lng, {
    double? zoom,
  }) async {
    final distance = _getDistanceByZoom(zoom ?? 11.0);

    final categoryName =
        selectedCategoryId != null
            ? poiCategories.firstWhere((c) => c.id == selectedCategoryId).name
            : null;

    final filteredItems =
        poiItems.where((item) {
          final itemDistance = Geolocator.distanceBetween(
            lat,
            lng,
            item.lat,
            item.lng,
          );
          return categoryName != null
              ? itemDistance <= distance && item.category == categoryName
              : itemDistance <= distance;
        }).toList();

    filteredItems.shuffle();
    nearbyPoiItems = filteredItems.take(100).toList();
    update();
  }

  double _getDistanceByZoom(double zoom) {
    if (zoom >= 13) return 1000; // 1km
    if (zoom >= 11 && zoom < 13) return 3000; // 3km
    if (zoom == 10) return 5000; // 5km
    return 10000; // 10km (zoom <= 9)
  }

  Future<void> updateNearbyPoiItems({
    required double lat,
    required double lng,
    double? zoom,
  }) async {
    await updateNearbyPoiItemsByPosition(lat, lng, zoom: zoom);
  }

  Future<void> searchPoiItems({
    required String query,
    required double lat,
    required double lng,
    double? zoom,
  }) async {
    selectedCategoryId = null;

    if (query.isEmpty) {
      // 검색어가 비어있으면 현재 위치 기준으로 다시 로드
      await updateNearbyPoiItems(lat: lat, lng: lng, zoom: zoom);
      return;
    }

    // 검색어가 포함된 아이템만 필터링
    nearbyPoiItems =
        poiItems
            .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    update();
  }

  // Future<void> loadPoiCategories() async {
  //   poiCategories.value = [
  //     PoiCategory(id: 1, name: '카페'),
  //     PoiCategory(id: 2, name: '음식점'),
  //     PoiCategory(id: 3, name: '쇼핑'),
  //     PoiCategory(id: 4, name: '관광지'),
  //     PoiCategory(id: 5, name: '문화시설'),
  //     PoiCategory(id: 6, name: '베이커리'),
  //     PoiCategory(id: 7, name: '주유소'),
  //     PoiCategory(id: 8, name: '주차장'),
  //     PoiCategory(id: 9, name: '병원'),
  //     PoiCategory(id: 10, name: '보건소'),
  //     PoiCategory(id: 11, name: '약국'),
  //     PoiCategory(id: 12, name: '치과'),
  //     PoiCategory(id: 13, name: '치킨'),
  //   ];
  // }

  // Future<void> loadPoiItems() async {
  //   // 임시 데이터
  //   poiItems = [
  //     PoiItem(
  //       title: '테스트 장소 1',
  //       description: '테스트 설명입니다.',
  //       lat: 37.5665,
  //       lng: 126.9780,
  //       address: '서울특별시 중구 세종대로 110',
  //       roadAddress: '서울특별시 중구 세종대로 110',
  //       category: '카페',
  //       tel: '02-1234-5678',
  //       url: 'https://map.naver.com/v5/search/서울특별시 중구 세종대로 110',
  //       imageUrl: 'https://picsum.photos/1000/1000',
  //     ),
  //     // 더 많은 아이템 추가 가능
  //   ];
  //   update();
  // }
}
