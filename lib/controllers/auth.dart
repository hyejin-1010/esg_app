import 'package:esg_app/db/model_auth_dao.dart';
import 'package:esg_app/models/auth.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password); // 문자열 → 바이트
  final digest = sha256.convert(bytes); // SHA-256 해시 적용
  return digest.toString(); // 해시 결과 문자열로 반환
}

class AuthController extends GetxController {
  AuthUser? _user;

  init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('user');
      if (user != null) _user = AuthUser.deserialize(user);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> authJoin({
    required String nickname,
    required String email,
    required String password,
  }) async {
    AuthUser newUser = AuthUser(
      nickname: nickname,
      email: email,
      password: hashPassword(password),
    );

    // DB에 저장
    AuthDao authDao = AuthDao();
    final isDuplicateNickname = await authDao.checkDuplicateNickname(nickname);
    if (isDuplicateNickname) {
      throw Exception('이미 사용중인 닉네임입니다.');
    }
    final isDuplicateUser = await authDao.checkDuplicateUser(email);
    if (isDuplicateUser) {
      throw Exception('이미 사용중인 이메일입니다.');
    }
    final newUserId = await authDao.insertUser(newUser);

    _user = AuthUser(
      id: newUserId,
      nickname: newUser.nickname,
      email: newUser.email,
    );

    // 2초 대기
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> authLogin({
    required String email,
    required String password,
  }) async {
    AuthDao authDao = AuthDao();
    final user = await authDao.login(email, hashPassword(password));
    if (user == null) throw Exception('존재하지 않는 유저입니다.');
    _user = user;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user', AuthUser.serialize(_user!));
    });
  }

  Future<bool> authLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('user');
      _user = null;
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> authCheckDuplicateNickname({required String nickname}) async {
    AuthDao authDao = AuthDao();
    final isDuplicateNickname = await authDao.checkDuplicateNickname(nickname);

    return isDuplicateNickname;
  }

  get user => _user;
  get userId => _user?.id;
}
