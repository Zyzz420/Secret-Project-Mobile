import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay for smoother UX
    await Future.delayed(const Duration(seconds: 1));

    final token = await _storage.read(key: 'jwt_token');
    final role =
        (await _storage.read(key: 'user_role'))?.toLowerCase();

    if (!mounted) return;

    if (token != null) {
      // ✅ Role-based routing (consistent with login screen)
      final roleRoutes = {
        'tenant': '/tenant-dashboard',
        'landlord': '/caretaker-dashboard',
        'admin': '/caretaker-dashboard',
        'caretaker': '/caretaker-dashboard',
      };

      final route = roleRoutes[role] ?? '/tenant-dashboard';
      context.go(route);
    } else {
      // ❌ Not logged in
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.real_estate_agent, size: 80, color: Colors.white),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}