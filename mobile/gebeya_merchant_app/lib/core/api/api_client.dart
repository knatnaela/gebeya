import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_interceptors.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  // Default: local API (Android emulator → host machine; use 127.0.0.1 on iOS simulator / desktop if needed).
  // Production: flutter build apk --dart-define=API_BASE_URL=https://gebeya-kappa.vercel.app/api
  return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:5000/api');
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(apiBaseUrlProvider),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthHeaderInterceptor(ref),
    GlobalErrorInterceptor(ref),
    LogInterceptor(requestBody: false, responseBody: false),
  ]);

  return dio;
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get dio => _dio;
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
