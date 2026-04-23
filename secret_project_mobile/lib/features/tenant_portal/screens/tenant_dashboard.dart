import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/mpesa_payment_modal.dart';
import '../providers/tenant_provider.dart';

class TenantDashboard extends ConsumerStatefulWidget {
  const TenantDashboard({super.key});

  @override
  ConsumerState<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends ConsumerState<TenantDashboard> {
  final currencyFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

  // ─────────────────────────────────────────────
  // 💳 M-PESA MODAL
  // ─────────────────────────────────────────────
  void _showMpesaModal(
    String invoiceId,
    double amountDue,
    String tenantPhone,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MpesaPaymentModal(
        invoiceId: invoiceId,
        amountDue: amountDue,
        defaultPhone: tenantPhone,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 🚪 LOGOUT
  // ─────────────────────────────────────────────
  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    if (mounted) context.go('/login');
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(tenantDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text('Tenant Portal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: _logout,
          ),
        ],
      ),

      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading data:\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(tenantDashboardProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),

        // ─────────────────────────────────────────────
        // 🚀 SUCCESS STATE (CLEAN + CONSOLIDATED)
        // ─────────────────────────────────────────────
        data: (data) {
          final personal = data['personal'] ?? {};
          final lease = personal['lease'] ?? {};

          final tenantName =
              data['first_name'] ??
              personal['first_name'] ??
              'Tenant';

          final phone =
              data['phone_number'] ??
              personal['phone_number'] ??
              '';

          final unitId =
              lease['unit_id']?['_id']?.toString() ??
              'unknown';

          // 💰 REAL BACKEND TRUTH (NO MORE GUESSING)
          final double amountDue =
              (data['real_invoice_amount'] ?? 0.0).toDouble();

          final String realInvoiceId =
              data['real_invoice_id'] ?? '';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tenantDashboardProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, $tenantName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─────────────────────────────────────────
                  // 💳 BALANCE CARD
                  // ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Outstanding Balance',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(amountDue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: amountDue > 0 &&
                                    realInvoiceId.isNotEmpty
                                ? () => _showMpesaModal(
                                      realInvoiceId,
                                      amountDue,
                                      phone,
                                    )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.greenAccent.shade400,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              amountDue > 0
                                  ? 'Pay via M-Pesa'
                                  : 'All Settled 🎉',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─────────────────────────────────────────
                  // ⚡ QUICK ACTIONS
                  // ─────────────────────────────────────────
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildActionCard(
                        icon: LucideIcons.wrench,
                        title: 'Maintenance',
                        color: Colors.orange,
                        onTap: () {
                          context.push(
                            '/report-issue',
                            extra: unitId,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildActionCard(
                        icon: LucideIcons.home,
                        title: 'Marketplace',
                        color: Colors.teal,
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _buildActionCard(
                        icon: LucideIcons.scanLine,
                        title: 'OCR',
                        color: Colors.red,
                        onTap: () {
                          context.push('/ocr-scanner');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 🧱 ACTION CARD WIDGET
  // ─────────────────────────────────────────────
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}