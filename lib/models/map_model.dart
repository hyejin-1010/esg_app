class PoiCategory {
  final int id;
  final String name;

  PoiCategory({required this.id, required this.name});
}

class PoiItem {
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String address;
  final String roadAddress;
  final String category;
  final String? tel;
  final String? url;
  final String? imageUrl;

  PoiItem({
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.roadAddress,
    required this.category,
    this.tel,
    this.url,
    this.imageUrl,
  });

  factory PoiItem.fromJson(Map<String, dynamic> json) {
    return PoiItem(
      title: json['title'].toString(),
      description: json['description'].toString(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'].toString(),
      roadAddress: json['roadAddress'].toString(),
      category: json['category'].toString(),
      tel: json['tel']?.toString(),
      url: json['url']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}
