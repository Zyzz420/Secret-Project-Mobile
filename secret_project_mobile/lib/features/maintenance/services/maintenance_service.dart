import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class MaintenanceService {
  final DioClient _dioClient = DioClient();

  Future<void> submitIssue({
    required String unitId,
    required String title,
    required String description,
    required String category,
    required String priority,
    File? imageFile,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'unit_id': unitId,
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      };

      // Attach image if exists
      if (imageFile != null) {
        dataMap['issue_image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(dataMap);

      // ✅ FIX: use real Dio instance
      await _dioClient.dio.post(
        '/maintenance/maintenance-requests',
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to submit request',
      );
    }
  }
}