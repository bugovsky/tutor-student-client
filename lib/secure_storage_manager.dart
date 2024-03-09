import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  SecureStorageManager._privateConstructor();

  static final SecureStorageManager _instance =
      SecureStorageManager._privateConstructor();

  static SecureStorageManager get instance => _instance;

  final _storage = const FlutterSecureStorage();

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> storeRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<void> deleteRole() async {
    await _storage.delete(key: 'role');
  }

  Future<void> storeSubjects(String userId, Map<String, bool> subjects) async {
    await _storage.write(key: userId, value: jsonEncode(subjects));
  }

  Future<Map<String, bool>> getSubjects(String userId) async {
    final rawSubjects = await _storage.read(key: userId);
    if (rawSubjects == null) {
      return <String, bool>{};
    }
    Map<String, dynamic> rawMap = jsonDecode(rawSubjects);
    Map<String, bool> subjects =
        rawMap.map((key, value) => MapEntry(key, value as bool));
    return subjects;
  }

  Future<void> storeUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: 'userId');
  }
}
