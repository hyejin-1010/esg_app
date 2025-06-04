import 'package:sqflite/sqflite.dart';

class PurchaseHistory {
  final int id;
  final int plantItemId; // 구매한 식물의 ID
  final int price; // 구매 가격
  final String purchaseDate; // 구매 날짜 (ISO 8601 string)
  final String postCode; // 우편번호
  final String address; // 주소
  final String detailAddress; // 상세 주소
  final String iconDescription; // 추가: 아이콘 설명

  PurchaseHistory({
    required this.id,
    required this.plantItemId,
    required this.price,
    required this.purchaseDate,
    required this.postCode,
    required this.address,
    required this.detailAddress,
    required this.iconDescription, // 추가
  });

  // DB에서 읽어올 때 사용
  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'] as int,
      plantItemId: map['plantItemId'] as int,
      price: map['price'] as int,
      purchaseDate: map['purchaseDate'] as String,
      postCode: map['postCode'] as String,
      address: map['address'] as String,
      detailAddress: map['detailAddress'] as String,
      iconDescription: map['iconDescription'] as String, // 추가
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantItemId': plantItemId,
      'price': price,
      'purchaseDate': purchaseDate,
      'postCode': postCode,
      'address': address,
      'detailAddress': detailAddress,
      'iconDescription': iconDescription, // 추가
    };
  }
}

class PurchaseHistoryDao {
  final Database db;
  static const String tableName = 'purchase_history';

  PurchaseHistoryDao(this.db);

  Future<List<PurchaseHistory>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => PurchaseHistory.fromMap(map)).toList();
  }

  Future<int> insert(PurchaseHistory history) async {
    // id는 DB에서 자동 생성되도록 제거
    final map = history.toMap();
    map.remove('id');
    return await db.insert(tableName, map);
  }


} 