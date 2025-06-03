class Feed {
  final int? id;
  final String content;
  final int userId;
  final String userName;
  final String createdAt;
  final String updatedAt;
  final List<String> imagePathList; // 이미지 Path List
  final int missionId;

  Feed({
    this.id,
    required this.content,
    required this.userId,
    required this.userName,
    String? createdAt,
    String? updatedAt,
    List<String>? imagePathList,
    required this.missionId,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String(),
       imagePathList = imagePathList ?? [];

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'],
      content: map['content'],
      userId: map['user_id'],
      userName: map['user_name'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      imagePathList:
          map['image_path_list']?.split(',') ??
          [], // Convert string back to list
      missionId: map['mission_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_path_list': imagePathList.join(
        ',',
      ), // Convert list to comma-separated string
      'mission_id': missionId,
    };
  }
}
