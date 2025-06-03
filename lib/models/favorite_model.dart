class Favorite {
  final int? id;
  final int userId;
  final int feedId;

  Favorite({this.id, required this.userId, required this.feedId});

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      userId: map['user_id'],
      feedId: map['feed_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'user_id': userId, 'feed_id': feedId};
  }
}
