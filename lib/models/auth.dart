import 'dart:convert';

class AuthUser {
  final String nickname;
  final String email;
  final String password;

  AuthUser({
    required this.nickname,
    required this.email,
    required this.password,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      nickname: json['nickname'],
      email: json['email'],
      password: json['password'],
    );
  }

  static Map<String, dynamic> toMap(AuthUser model) => <String, dynamic>{
    'nickname': model.nickname,
    'email': model.email,
    'password': model.password,
  };

  static String serialize(AuthUser model) => json.encode(AuthUser.toMap(model));

  static AuthUser deserialize(String json) =>
      AuthUser.fromJson(jsonDecode(json));
}

class User {
  final int userId;
  final String nickname;
  final String email;

  User({required this.userId, required this.nickname, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      nickname: json['nickname'],
      email: json['email'],
    );
  }

  static Map<String, dynamic> toMap(User model) => <String, dynamic>{
    'userId': model.userId,
    'nickname': model.nickname,
    'email': model.email,
  };

  static String serialize(User model) => json.encode(User.toMap(model));

  static User deserialize(String json) => User.fromJson(jsonDecode(json));
}
