import 'package:esg_app/db/model_auth_dao.dart';
import 'package:esg_app/models/auth.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password); // 문자열 → 바이트
  final digest = sha256.convert(bytes); // SHA-256 해시 적용
  return digest.toString(); // 해시 결과 문자열로 반환
}

class AuthController extends GetxController {
  late final User _user;

  Future<void> authJoin({
    required String nickname,
    required String email,
    required String password,
  }) async {
    String uuid = const Uuid().v4();
    User newUser = User(accessToken: uuid, nickname: nickname, email: email);

    // 스토리지에 저장
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'user', value: User.serialize(newUser));

    _user = newUser;

    // 2초 대기
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> authLogin({
    required String email,
    required String password,
  }) async {
    // 스토리지에 저장
    final storage = const FlutterSecureStorage();
    final storageUser = await storage.read(key: 'user');

    if (storageUser != null) {
      User deserializedUser = User.deserialize(storageUser);
      if (deserializedUser.email == email) {
        _user = deserializedUser;
      } else {
        throw Exception('존재하지 않는 유저입니다.');
      }
    } else {
      throw Exception('존재하지 않는 유저입니다.');
    }

    // 2초 대기
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<bool> authCheckDuplicateNickname({required String nickname}) async {
    AuthDao authDao = AuthDao();
    final isDuplicateNickname = await authDao.checkDuplicateNickname(nickname);

    return isDuplicateNickname;
  }

  get user => _user;

  // TODO: 추후 DB 아이디로 변경 필요
  get userId => 1;
}
