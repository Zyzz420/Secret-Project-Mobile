import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added this
import '../../../core/network/dio_client.dart';
import '../../../core/api/api_endpoints.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // Added this

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("🚀 Attempting login for: $email to ${ApiEndpoints.login}");

      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email, 
          'password': password
        },
      );

      print("✅ Node.js Response: ${response.data}"); // Let's see what the backend actually returns!

      // 1. Extract token and user data
      final token = response.data['token'];
      final user = response.data['user'] ?? {}; 
      
      // 2. Force role to lowercase (e.g., "Tenant" becomes "tenant" so routing works)
      final role = (user['role'] ?? 'tenant').toString().toLowerCase();

      // 3. Save to Secure Storage so the app remembers you are logged in
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_role', value: role);
        print("💾 SUCCESS: Token and Role ($role) saved securely!");
      } else {
        print("⚠️ WARNING: Login succeeded, but Node.js did not return a 'token'.");
      }

      return response.data;

    } on DioException catch (e) {
      // DEBUG: If it fails, this will tell us exactly why
      print("🚨 DIO ERROR STATUS: ${e.response?.statusCode}");
      print("🚨 DIO ERROR DATA: ${e.response?.data}");
      
      throw Exception(e.response?.data['message'] ?? "Login failed. Please check credentials.");
    } catch (e) {
      print("🚨 GENERAL ERROR: $e");
      throw Exception("An unexpected error occurred");
    }
  }

  // Handy to have for the Logout button!
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
  }
}