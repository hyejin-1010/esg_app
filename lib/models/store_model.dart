class Store {
  final int id;
  final String nameEn;
  final String nameKo;
  final String description;
  final String tag;
  final String thumbnail;
  final List<String> imageList;
  final String link;

  Store({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.description,
    required this.tag,
    required this.thumbnail,
    required this.imageList,
    required this.link,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      nameEn: map['name_en'],
      nameKo: map['name_ko'],
      description: map['description'],
      tag: map['tag'],
      thumbnail: map['thumbnail'],
      imageList: map['image_list']?.split(',') ?? [],
      link: map['link'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ko': nameKo,
      'description': description,
      'tag': tag,
      'thumbnail': thumbnail,
      'image_list': imageList.join(','),
      'link': link,
    };
  }
}
