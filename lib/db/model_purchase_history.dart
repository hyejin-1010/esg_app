import 'package:sqflite/sqflite.dart';

class PurchaseHistory {
  final int id;
  final int plantItemId; // 구매한 식물의 ID
  final int price; // 구매 가격
  final String purchaseDate; // 구매 날짜 (ISO 8601 string)
  final String postCode; // 우편번호
  final String address; // 주소
  final String detailAddress; // 상세 주소
  final String iconDescription; // 아이콘 설명

  PurchaseHistory({
    required this.id,
    required this.plantItemId,
    required this.price,
    required this.purchaseDate,
    required this.postCode,
    required this.address,
    required this.detailAddress,
    required this.iconDescription, 
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
      iconDescription: map['iconDescription'] as String,
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
      'iconDescription': iconDescription, 
    };
  }
}

class PurchaseHistoryDao {
  final Database db;
  static const String tableName = 'purchase_history';

  PurchaseHistoryDao(this.db);

  Future<List<Map<String, dynamic>>> getAllWithPlantName() async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        ph.id,
        ph.plantItemId,
        pi.name AS plantName,
        pi.imageAsset AS plantImage,
        ph.price,
        ph.purchaseDate,
        ph.postCode,
        ph.address,
        ph.detailAddress,
        ph.iconDescription
      FROM purchase_history ph
      INNER JOIN plant_items pi ON ph.plantItemId = pi.id
      ORDER BY ph.purchaseDate DESC -- 최신 구매 내역부터 표시
    ''');
    return maps;
  }

  Future<int> insert(PurchaseHistory history) async {
    final map = history.toMap();
    map.remove('id'); 
    return await db.insert(tableName, map);
  }
} 