import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/caretaker_service.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  Map<String, dynamic>? _extractedData;

  final ImagePicker _picker = ImagePicker();
  final CaretakerService _caretakerService = CaretakerService();

  // Open the device camera
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 80, // High quality needed for OCR
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _extractedData = null; // Clear previous results
      });
    }
  }

  // Send to backend for OCR
  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _caretakerService.scanDocument(_imageFile!);
      setState(() {
        _extractedData = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document scanned successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scan Tenant ID or KRA PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Image Preview Area
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade900, width: 2),
                image: _imageFile != null
                    ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                    : null,
              ),
              child: _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.scanLine, size: 60, color: Colors.blue.shade900),
                        const SizedBox(height: 16),
                        const Text('No document selected', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _takePhoto,
                    icon: const Icon(LucideIcons.camera),
                    label: const Text('Retake'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_imageFile == null || _isProcessing) ? null : _processImage,
                    icon: _isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(LucideIcons.cpu),
                    label: Text(_isProcessing ? 'Extracting...' : 'Extract Text'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // OCR Results Area
            if (_extractedData != null) ...[
              const Text('Extracted Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assuming your backend returns parsed keys like 'id_number' or 'raw_text'
                    _buildResultRow('Extracted Text', _extractedData?['raw_text'] ?? 'N/A'),
                    const Divider(),
                    // You can map these to the actual keys returned by your ocrService.js
                    _buildResultRow('Detected ID', _extractedData?['id_number'] ?? 'Not found'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Pass this data to the "Invite Tenant Form"
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        child: const Text('Use this Data'),
                      ),
                    )
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
      // Floating Action Button for quick access
      floatingActionButton: _imageFile == null ? FloatingActionButton.extended(
        onPressed: _takePhoto,
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(LucideIcons.camera),
        label: const Text('Open Camera'),
      ) : null,
    );
  }

  // Helper for displaying result rows
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}