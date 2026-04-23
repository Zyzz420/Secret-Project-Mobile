import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/tenant_portal/screens/tenant_dashboard.dart';
import '../../features/maintenance/screens/report_issue_screen.dart';
import '../../features/caretaker_panel/screens/ocr_scanner_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/', // Start at the splash screen
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/tenant-dashboard',
      builder: (context, state) => const TenantDashboard(),
    ),
    GoRoute(
      path: '/ocr-scanner',
      builder: (context, state) => const OcrScannerScreen(),
    ),
    GoRoute(
      path: '/report-issue',
      builder: (context, state) {
        // We can pass data to this route (like the unitId) using state.extra
        final unitId = state.extra as String? ?? 'unknown_unit';
        return ReportIssueScreen(currentUnitId: unitId);
      },
    ),
  ],
);