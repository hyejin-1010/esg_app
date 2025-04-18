import 'dart:convert';

class User {
  final String accessToken;
  final String userId;
  final String email;

  User({required this.accessToken, required this.userId, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accessToken: json['accessToken'],
      userId: json['userId'],
      email: json['email'],
    );
  }

  static Map<String, dynamic> toMap(User model) => <String, dynamic>{
    'accessToken': model.accessToken,
    'userId': model.userId,
    'email': model.email,
  };

  static String serialize(User model) => json.encode(User.toMap(model));

  static User deserialize(String json) => User.fromJson(jsonDecode(json));
}
