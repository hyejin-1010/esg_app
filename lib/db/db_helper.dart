import 'package:esg_app/models/feed_model.dart';
import 'package:esg_app/models/mission_model.dart';
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
            icon_name TEXT,
            co2 INTEGER
          )
        ''');

        // 초기 미션 데이터 삽입
        final missionCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Mission'),
        );
        if (missionCount == 0) {
          for (var mission in mockupMissionData) {
            await db.insert('Mission', mission.toMap());
          }
        }

        // 초기 피드 데이터 삽입
        final feedCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Feed'),
        );
        if (feedCount == 0) {
          for (var feed in mockupFeedData) {
            await db.insert('Feed', feed.toMap());
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
    co2: 20,
  ),
  Mission(
    id: 2,
    title: '플로깅 활동',
    description: 'CO2 절감량 10g',
    reward: 3,
    iconName: 'mission2.png',
    co2: 10,
  ),
  Mission(
    id: 3,
    title: '분리수거 하기',
    description: 'CO2 절감량 1,500g',
    reward: 5,
    iconName: 'mission3.png',
    co2: 1500,
  ),
  Mission(
    id: 4,
    title: '장바구니(에코백) 사용',
    description: 'CO2 절감량 6g',
    reward: 3,
    iconName: 'mission4.png',
    co2: 6,
  ),
  Mission(
    id: 5,
    title: '자전거 타기',
    description: 'CO2 절감량 8,000g',
    reward: 3,
    iconName: 'mission5.png',
    co2: 8000,
  ),
  Mission(
    id: 6,
    title: '만보 걷기',
    description: 'CO2 절감량 1,500g',
    reward: 3,
    iconName: 'mission6.png',
    co2: 1500,
  ),
  Mission(
    id: 7,
    title: '플러그 뽑기',
    description: 'CO2 절감량 30g',
    reward: 2,
    iconName: 'mission7.png',
    co2: 30,
  ),
  Mission(
    id: 8,
    title: '대중교통 이용하기',
    description: 'CO2 절감량 1,200g',
    reward: 2,
    iconName: 'mission8.png',
    co2: 1200,
  ),
  Mission(
    id: 9,
    title: '불필요한 메일 정리',
    description: 'CO2 절감량 40g',
    reward: 2,
    iconName: 'mission9.png',
    co2: 40,
  ),
  Mission(
    id: 10,
    title: '비치코밍 동참',
    description: 'CO2 절감량 10g',
    reward: 10,
    iconName: 'mission10.png',
    co2: 10,
  ),
  Mission(
    id: 11,
    title: '채식하기',
    description: 'CO2 절감량 3,250g',
    reward: 5,
    iconName: 'mission11.png',
    co2: 3250,
  ),
  Mission(
    id: 12,
    title: '양치컵 사용하기',
    description: 'CO2 절감량 10g',
    reward: 2,
    iconName: 'mission12.png',
    co2: 10,
  ),
  Mission(
    id: 13,
    title: '식물 키우기',
    description: 'CO2 절감량 9g',
    reward: 3,
    iconName: 'mission13.png',
    co2: 9,
  ),
  Mission(
    id: 14,
    title: '잔반 남기지 않기',
    description: 'CO2 절감량 500g',
    reward: 2,
    iconName: 'mission14.png',
    co2: 500,
  ),
  // TODO: 업사이클링 미션 추가 필요
];

List<Feed> mockupFeedData = [
  Feed(
    id: 1,
    content: '''플로깅 후 정크아트! 버려진 쓰레기로 작품 만들고 뿌듯한 하루였당

#그린지구 #플로깅 #정크아트 #지구를지키는작은실천 #환경보호 #탄소중립 #쓰레기도예술이된다''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_1_1.jpg',
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_1_2.png',
    ],
    missionId: 2,
  ),
  Feed(
    id: 2,
    content: '''망상해변에서 수거한 쓰레기들 ! 

깨끗해진 바다 보니까 속까지 시원~

#그린지구 #비치코밍 #해양쓰레기수거 #환경보호''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_2_1.png',
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_2_2.png',
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_2_3.png',
    ],
    missionId: 10,
  ),
  Feed(
    id: 3,
    content: '''오늘도 나의 친환경 루틴~
일회용 컵 대신, 텀블러와 함께 시작하는 하루!

#그린지구 #텀블러사용하기 #탄소중립 #환경보호''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_3_1.png',
    ],
    missionId: 1,
  ),
  Feed(
    id: 4,
    content: '''오늘은 단지 분리수거 하는 날~ 
분리수거 완료!

#그린지구 #분리수거하기 #환경보호 #지구를위한작은실천''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_4_1.png',
    ],
    missionId: 3,
  ),
  Feed(
    id: 5,
    content: '''친구들과 다육이를 구매했다 
열심히 키워봐야지!

#그린지구 #식물키우기 #환경보호''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_5_1.png',
    ],
    missionId: 13,
  ),
  Feed(
    id: 6,
    content: '''오늘도 열심히 걸었당! 
24,624보 달성

#그린지구 #만보걷기''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_6_1.png',
    ],
    missionId: 6,
  ),
  Feed(
    id: 7,
    content: '''오늘 점심은 크럼블두부 비빔밥 정식!
애호박, 당근, 시금치, 콩나물, 버섯까지채소 듬뿍 들어가서 영양은 더하고 부담은 줄였어요.든든하고 건강한 한 끼 완성~

#그린지구 #채식한끼 #크럼블두부''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_7_1.png',
    ],
    missionId: 11,
  ),
  Feed(
    id: 8,
    content: '''모아둔 병뚜껑을 녹이고, 찍고, 다듬고…
하나하나 정성껏 만든 세상에 하나뿐인 그립톡!
예쁘게 포장해서 친구들에게 선물할 예정이에요 :)''',
    userId: 1,
    userName: '사용자',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imagePathList: [
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_8_1.png',
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_8_2.png',
      'https://dzmhxwhowtjnioxjzzlb.supabase.co/storage/v1/object/public/esg/sample/feed_8_3.png',
    ],
    missionId: 15,
  ),
];
