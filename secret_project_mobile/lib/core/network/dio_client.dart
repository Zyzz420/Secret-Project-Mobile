import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';
import '../utils/storage_service.dart';

class DioClient {
  late final Dio dio;
  final StorageService _storage = StorageService();

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print("🚨 Token expired. Handle refresh here");
            // TODO: silent refresh logic
          }

          return handler.next(e);
        },
      ),
    );
  }
}