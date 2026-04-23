import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class CaretakerService {
  get dioClient => null;

  /// Uploads an image to your Node.js backend for OCR text extraction.
  /// Replace '/utils/ocr' with your actual backend OCR route!
  Future<Map<String, dynamic>> scanDocument(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      // Assuming your backend route for OCR looks something like this
      final response = await dioClient.post('/admin/ocr-scan', data: formData);
      
      // Expected to return the extracted text and maybe parsed data (ID Number, Name)
      return response.data as Map<String, dynamic>; 
      
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to process document');
    } catch (e) {
      throw Exception('An unexpected error occurred during scanning.');
    }
  }
}