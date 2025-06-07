import 'dart:convert';

class User {
  final String accessToken;
  final String nickname;
  final String email;

  User({
    required this.accessToken,
    required this.nickname,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accessToken: json['accessToken'],
      nickname: json['nickname'],
      email: json['email'],
    );
  }

  static Map<String, dynamic> toMap(User model) => <String, dynamic>{
    'accessToken': model.accessToken,
    'nickname': model.nickname,
    'email': model.email,
  };

  static String serialize(User model) => json.encode(User.toMap(model));

  static User deserialize(String json) => User.fromJson(jsonDecode(json));
}
