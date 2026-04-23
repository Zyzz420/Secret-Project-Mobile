import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/utils/storage_service.dart';

// 🔹 STATE
class AuthState {
  final UserModel? user;
  final bool isLoading;

  const AuthState({
    this.user,
    this.isLoading = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 🔹 PROVIDER
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// 🔹 NOTIFIER
class AuthNotifier extends Notifier<AuthState> {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  @override
  AuthState build() {
    return const AuthState();
  }

  // 🔑 LOGIN
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final data = await _authService.login(email, password);

      final token = data['token'];
      if (token == null) {
        throw Exception("Token missing from response");
      }

      final user = UserModel.fromJson(data);

      await _storage.saveToken(token);

      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _storage.clearAuth();
    state = const AuthState();
  }
}