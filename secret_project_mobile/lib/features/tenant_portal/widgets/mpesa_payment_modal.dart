import 'package:flutter/material.dart';
import '../services/tenant_service.dart';

class MpesaPaymentModal extends StatefulWidget {
  final String invoiceId;
  final double amountDue;
  final String defaultPhone;

  const MpesaPaymentModal({
    super.key,
    required this.invoiceId,
    required this.amountDue,
    required this.defaultPhone,
  });

  @override
  State<MpesaPaymentModal> createState() => _MpesaPaymentModalState();
}

class _MpesaPaymentModalState extends State<MpesaPaymentModal> {
  late TextEditingController _phoneController;
  final TenantService _tenantService = TenantService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController =
        TextEditingController(text: widget.defaultPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // 💰 PAYMENT LOGIC (CONSOLIDATED + SAFE)
  Future<void> _processPayment() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🧾 STEP 1: Resolve invoice ID
      String invoiceId = widget.invoiceId;

      if (invoiceId.isEmpty) {
        print("🔍 No invoiceId provided. Fetching...");
        invoiceId = await _tenantService.getFirstUnpaidInvoiceId();
        print("🎯 Resolved invoiceId: $invoiceId");
      }

      print("🚀 STK PUSH → KES ${widget.amountDue} → $phone");

      // 💳 STEP 2: Trigger STK Push
      await _tenantService.initiateMpesaPayment(
        invoiceId: invoiceId,
        phoneNumber: phone,
        amount: widget.amountDue,
      );

      print("✅ STK PUSH SUCCESS");

      if (!mounted) return;

      // 🚪 Close modal first
      Navigator.pop(context);

      // 📣 Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('M-Pesa prompt sent! Check your phone.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print("🚨 STK PUSH ERROR: $e");

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🧾 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pay with M-Pesa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.phone_android,
                color: Colors.green.shade600,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 💰 AMOUNT
          Text(
            'Amount Due: KES ${widget.amountDue.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // 📱 PHONE INPUT
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'M-Pesa Phone Number',
              hintText: 'e.g. 2547XXXXXXXX',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),

          const SizedBox(height: 24),

          // 🚀 BUTTON
          ElevatedButton(
            onPressed: _isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Send STK Prompt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}