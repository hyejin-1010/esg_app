import 'package:esg_app/models/mission_model.dart';
import '../db/model_plant_item.dart';
import '../db/model_plant_item_dao.dart';
import '../db/model_purchase_history.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!; 
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    return await openDatabase(
      'assets/esg_app.db',
      version: 1,
      onOpen: (Database db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Feed (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT,
            user_id INTEGER,
            user_name TEXT,
            created_at TEXT,
            updated_at TEXT,
            image_path_list TEXT,
            mission_id INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Favorite (
            user_id INTEGER,
            feed_id INTEGER,
            PRIMARY KEY (user_id, feed_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Mission (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            reward INTEGER,
            icon_name TEXT
          )
        ''');

        // plant_items 테이블 생성
        await db.execute('''
          CREATE TABLE IF NOT EXISTS plant_items (
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            imageAsset TEXT,
            price INTEGER
          )
        ''');
        
        // purchase_history 테이블 생성 (초기 버전용)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS purchase_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plantItemId INTEGER,
            plantName TEXT,
            plantImage TEXT,
            price INTEGER,
            purchaseDate TEXT,
            postCode TEXT,
            address TEXT,
            detailAddress TEXT,
            iconDescription TEXT
          )
        ''');

        // 초기 식물 데이터 삽입
        final plantCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM plant_items'),
        );
        if (plantCount == 0) {
          final plants = [
            {
              'id': 1,
              'name': '바질',
              'description': '초보자도 키우기 쉬운 허브 식물',
              'imageAsset': '../assets/images/mypage/pic_sample.jpg',
              'price': 500,
            },
            {
              'id': 2,
              'name': '라일락',
              'description': '에케베리아 계열의 다육식물',
              'imageAsset': '../assets/images/mypage/pic_sample.jpg',
              'price': 500,
            },
            {
              'id': 3,
              'name': '미니알로에',
              'description': '소형종으로 관리가 수월한 다육이',
              'imageAsset': '../assets/images/mypage/pic_sample.jpg',
              'price': 500,
            },
            {
              'id': 4,
              'name': '방울복랑',
              'description': '국민 다육이',
              'imageAsset': '../assets/images/mypage/pic_sample.jpg',
              'price': 500,
            },
            {
              'id': 5,
              'name': '랜덤',
              'description': '어떤 미니다육이가 올까? 랜덤으로 만나보세요 🎁',
              'imageAsset': '../assets/images/mypage/pic_sample.jpg',
              'price': 500,
            },
          ];
          for (var plant in plants) {
            await db.insert('plant_items', plant);
          }
        }

        // 기존 미션 데이터 삽입
        final missionCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Mission'),
        );
        if (missionCount == 0) {
          for (var mission in mockupMissionData) {
            await db.insert('Mission', mission.toMap());
          }
        }
      },
    );
  }

  // DB 초기화
  static Future<void> clearAllData() async {
    await deleteDatabase('assets/esg_app.db');
  }
}

// 초기 미션 데이터
List<Mission> mockupMissionData = [
  Mission(
    id: 1,
    title: '텀블러 사용하기',
    description: 'CO2 절감량 20g',
    reward: 3,
    iconName: 'mission1.png',
  ),
  Mission(
    id: 2,
    title: '플로깅 활동',
    description: 'CO2 절감량 10g',
    reward: 3,
    iconName: 'mission2.png',
  ),
  Mission(
    id: 3,
    title: '분리수거 하기',
    description: 'CO2 절감량 1,500g',
    reward: 5,
    iconName: 'mission3.png',
  ),
  Mission(
    id: 4,
    title: '장바구니(에코백) 사용',
    description: 'CO2 절감량 6g',
    reward: 3,
    iconName: 'mission4.png',
  ),
  Mission(
    id: 5,
    title: '자전거 타기',
    description: 'CO2 절감량 8,000g',
    reward: 3,
    iconName: 'mission5.png',
  ),
  Mission(
    id: 6,
    title: '만보 걷기',
    description: 'CO2 절감량 1,500g',
    reward: 3,
    iconName: 'mission6.png',
  ),
  Mission(
    id: 7,
    title: '플러그 뽑기',
    description: 'CO2 절감량 30g',
    reward: 2,
    iconName: 'mission7.png',
  ),
  Mission(
    id: 8,
    title: '대중교통 이용하기',
    description: 'CO2 절감량 1,200g',
    reward: 2,
    iconName: 'mission8.png',
  ),
  Mission(
    id: 9,
    title: '불필요한 메일 정리',
    description: 'CO2 절감량 40g',
    reward: 2,
    iconName: 'mission9.png',
  ),
  Mission(
    id: 10,
    title: '비치코밍 동참',
    description: 'CO2 절감량 10g',
    reward: 10,
    iconName: 'mission10.png',
  ),
  Mission(
    id: 11,
    title: '채식하기',
    description: 'CO2 절감량 3,250g',
    reward: 5,
    iconName: 'mission11.png',
  ),
  Mission(
    id: 12,
    title: '양치컵 사용하기',
    description: 'CO2 절감량 10g',
    reward: 2,
    iconName: 'mission12.png',
  ),
  Mission(
    id: 13,
    title: '식물 키우기',
    description: 'CO2 절감량 9g',
    reward: 3,
    iconName: 'mission13.png',
  ),
  Mission(
    id: 14,
    title: '잔반 남기지 않기',
    description: 'CO2 절감량 500g',
    reward: 2,
    iconName: 'mission14.png',
  ),
];

List<PlantItem> _plants = [];
bool _isLoading = true;
