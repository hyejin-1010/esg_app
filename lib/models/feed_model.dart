class Feed {
  final int id;
  final String conten;
  final int userId;
  final String userName;
  final String createdAt;
  final String updatedAt;
  final List<String> imagePathList;
  final int missionId;
  final String missionName;

  Feed({
    required this.id,
    required this.conten,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.updatedAt,
    this.imagePathList = const [],
    required this.missionId,
    required this.missionName,
  });

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'],
      conten: map['conten'],
      userId: map['user_id'],
      userName: map['user_name'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      imagePathList: map['image_path_list'],
      missionId: map['mission_id'],
      missionName: map['mission_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conten': conten,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_path_list': imagePathList,
      'mission_id': missionId,
      'mission_name': missionName,
    };
  }
}
