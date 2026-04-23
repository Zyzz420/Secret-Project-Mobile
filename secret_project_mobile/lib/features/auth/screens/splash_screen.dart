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
    // Add a tiny delay so the splash screen doesn't just flash aggressively
    await Future.delayed(const Duration(seconds: 1)); 
    
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');

    if (!mounted) return;

    if (token != null) {
      // User is logged in. Route based on role
      if (role == 'tenant') {
        context.go('/tenant-dashboard');
      } else {
        // We'll handle caretaker/admin later, fallback to login for now
        context.go('/login'); 
      }
    } else {
      // No token, go to login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue, // Match your brand color
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