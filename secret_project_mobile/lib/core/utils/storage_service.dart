import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // Save JWT
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Get JWT
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Clear everything on Logout
  Future<void> clearAuth() async {
    await _storage.delete(key: 'jwt_token');
  }
}