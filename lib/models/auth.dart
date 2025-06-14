import 'dart:convert';

class AuthUser {
  final int? id;
  final String nickname;
  final String email;
  final String? password;
  int reward;

  AuthUser({
    this.id,
    required this.nickname,
    required this.email,
    this.password,
    this.reward = 0,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      nickname: json['nickname'],
      email: json['email'],
      password: json['password'],
      reward: json['reward'] ?? 0,
    );
  }

  static Map<String, dynamic> toMap(AuthUser model) => <String, dynamic>{
    'id': model.id,
    'nickname': model.nickname,
    'email': model.email,
    'password': model.password,
    'reward': model.reward,
  };

  static String serialize(AuthUser model) => json.encode(AuthUser.toMap(model));

  static AuthUser deserialize(String json) =>
      AuthUser.fromJson(jsonDecode(json));
}
