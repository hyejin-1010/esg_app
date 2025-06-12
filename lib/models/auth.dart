import 'dart:convert';

class AuthUser {
  final int? id;
  final String nickname;
  final String email;
  final String? password;

  AuthUser({
    this.id,
    required this.nickname,
    required this.email,
    this.password,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      nickname: json['nickname'],
      email: json['email'],
      password: json['password'],
    );
  }

  static Map<String, dynamic> toMap(AuthUser model) => <String, dynamic>{
    'id': model.id,
    'nickname': model.nickname,
    'email': model.email,
    'password': model.password,
  };

  static String serialize(AuthUser model) => json.encode(AuthUser.toMap(model));

  static AuthUser deserialize(String json) =>
      AuthUser.fromJson(jsonDecode(json));
}
