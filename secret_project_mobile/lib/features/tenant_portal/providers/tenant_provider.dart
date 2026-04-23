import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tenant_service.dart';

// 1. Provide the service instance
final tenantServiceProvider = Provider((ref) => TenantService());

// 2. Create a FutureProvider. 
// This automatically handles Loading, Error, and Success states!
final tenantDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(tenantServiceProvider);
  return await service.getDashboardData(); 
  // This calls your Node.js GET /api/tenants/me/dashboard
});