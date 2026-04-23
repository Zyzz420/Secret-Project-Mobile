import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class TenantService {
  final Dio dioClient = DioClient().dio;

  // ─────────────────────────────────────────────
  // 📊 DASHBOARD + INVOICE ENRICHMENT
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      print("🔄 Fetching dashboard + invoices...");

      final dashResponse =
          await dioClient.get('/tenants/me/dashboard');

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(dashResponse.data);

      final invResponse =
          await dioClient.get('/rent/invoices');

      final List invoices =
          (invResponse.data as List?) ?? [];

      print("📦 INVOICES FOUND: ${invoices.length}");

      double exactAmount = 0.0;
      String exactInvoiceId = "";

      for (final inv in invoices) {
        final status =
            (inv['status'] ?? '').toString().toLowerCase();

        if (status == 'unpaid' || status == 'partial') {
          exactAmount =
              double.tryParse(inv['amount_due'].toString()) ?? 0.0;

          final rawId = inv['_id'];

          exactInvoiceId = rawId is Map
              ? (rawId['\$oid'] ?? '')
              : (rawId?.toString() ?? '');

          print("🎯 FOUND INVOICE: $exactInvoiceId");
          print("💰 AMOUNT: $exactAmount");
          break;
        }
      }

      data['real_invoice_amount'] = exactAmount;
      data['real_invoice_id'] = exactInvoiceId;

      print("✅ DASHBOARD ENRICHED");

      return data;
    } on DioException catch (e) {
      print("🚨 DASHBOARD ERROR: ${e.response?.data}");
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Unexpected error loading dashboard.');
    }
  }

  // ─────────────────────────────────────────────
  // 💳 M-PESA STK PUSH (BULLETPROOF)
  // ─────────────────────────────────────────────
  Future<void> initiateMpesaPayment({
    required String invoiceId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final cleanInvoiceId = invoiceId.trim();
      final cleanPhone = phoneNumber.trim();

      print("==================================");
      print("💳 STK PUSH INITIATED");
      print("Invoice: $cleanInvoiceId");
      print("Phone: $cleanPhone");
      print("Amount: $amount");
      print("==================================");

      await dioClient.post(
        '/rent/mpesa/stkpush',
        data: {
          // 🔥 double-key safety (backend mismatch protection)
          'invoiceId': cleanInvoiceId,
          'invoice_id': cleanInvoiceId,

          'phoneNumber': cleanPhone,
          'phone_number': cleanPhone,

          'amount': amount,
        },
      );

      print("✅ STK PUSH SENT SUCCESSFULLY");
    } on DioException catch (e) {
      print("🚨 MPESA ERROR: ${e.response?.data}");
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Unexpected payment error occurred.');
    }
  }

  // ─────────────────────────────────────────────
  // 🧾 FALLBACK INVOICE FETCH
  // ─────────────────────────────────────────────
  Future<String> getFirstUnpaidInvoiceId() async {
    try {
      final response =
          await dioClient.get('/rent/invoices');

      if (response.data is List) {
        for (final inv in response.data) {
          final status =
              (inv['status'] ?? '').toString().toLowerCase();

          if (status == 'unpaid' || status == 'partial') {
            final id = inv['_id']?.toString();
            if (id != null && id.isNotEmpty) {
              return id;
            }
          }
        }
      }

      throw Exception('No unpaid invoices found.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch invoices.');
    }
  }

  // ─────────────────────────────────────────────
  // 🧠 ERROR PARSER
  // ─────────────────────────────────────────────
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'];
    }

    if (data is Map &&
        data['errors'] is List &&
        (data['errors'] as List).isNotEmpty) {
      return data['errors'][0].toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server.';
      default:
        return 'Network error occurred.';
    }
  }
}