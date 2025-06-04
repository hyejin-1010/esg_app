class PlantItem {
  final int id;
  final String name;
  final String description;
  final String imageAsset;
  final int price;

  PlantItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.price,
  });

  // DB에서 읽어올 때 사용
  factory PlantItem.fromMap(Map<String, dynamic> map) {
    return PlantItem(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imageAsset: map['imageAsset'] as String,
      price: map['price'] as int,
    );
  }

  // DB에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageAsset': imageAsset,
      'price': price,
    };
  }
} 