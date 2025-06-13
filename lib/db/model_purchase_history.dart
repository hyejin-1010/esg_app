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
  final int userId;  // 사용자 ID 필드 추가

  PurchaseHistory({
    required this.id,
    required this.plantItemId,
    required this.price,
    required this.purchaseDate,
    required this.postCode,
    required this.address,
    required this.detailAddress,
    required this.iconDescription,
    required this.userId,  // 생성자에 userId 추가
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
      userId: map['userId'] as int,  // fromMap에 userId 추가
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantItemId': plantItemId,
      'price': price,
      'purchaseDate': purchaseDate,
      'postCode': postCode,
      'address': address,
      'detailAddress': detailAddress,
      'iconDescription': iconDescription,
      'userId': userId,
    };
  }
}

class PurchaseHistoryDao {
  final Database db;
  static const String tableName = 'purchase_history';

  PurchaseHistoryDao(this.db);

  Future<List<Map<String, dynamic>>> getAllWithPlantName() async {
    return await db.rawQuery('''
      SELECT ph.*, pi.name as plantName, pi.imageAsset as plantImage
      FROM purchase_history ph
      LEFT JOIN plant_items pi ON ph.plantItemId = pi.id
      ORDER BY ph.purchaseDate DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getByUserId(int userId) async {
    return await db.rawQuery('''
      SELECT ph.*, pi.name as plantName, pi.imageAsset as plantImage
      FROM purchase_history ph
      LEFT JOIN plant_items pi ON ph.plantItemId = pi.id
      WHERE ph.userId = ?
      ORDER BY ph.purchaseDate DESC
    ''', [userId]);
  }

  Future<int> insert(PurchaseHistory history) async {
    return await db.insert('purchase_history', history.toMap());
  }
} 