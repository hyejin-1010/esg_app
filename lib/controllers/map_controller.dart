import 'dart:developer';

import 'package:esg_app/models/map_model.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';

class MapController extends GetxController {
  final poiCategories = <PoiCategory>[].obs;
  List<PoiItem> poiItems = [];

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
      poiItems = [...storeItems, ...trashItems].take(50).toList();

      update();
      log(
        'Loaded ${poiItems.length} POI items (${storeItems.length} stores, ${trashItems.length} trash bins) and ${poiCategories.length} categories',
      );
    } catch (e) {
      log('Error loading data: $e');
    }
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
