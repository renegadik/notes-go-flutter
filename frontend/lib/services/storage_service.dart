import 'dart:ffi';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = FlutterSecureStorage();

  // token

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // user data

  Future<void> saveUserData({required String id, required String login}) async {
    await _storage.write(key: 'user_id', value: id);
    await _storage.write(key: 'user_login', value: login);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<int?> getUserIdInt() async {
    final idStr = await _storage.read(key: 'user_id');
    return idStr != null ? int.tryParse(idStr) : null;
  }

  Future<String?> getUserLogin() async {
    return await _storage.read(key: 'user_login');
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_login');
  }

  // ------------

  Future<void> deleteAllData() async {
    await deleteToken();
    await deleteUserData();
  }
}
