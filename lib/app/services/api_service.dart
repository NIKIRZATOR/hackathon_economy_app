import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/browser.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient I = ApiClient._();

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE',
          defaultValue: 'http://62.109.26.183/data',
        ),
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (kIsWeb) {
      d.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = false;
    }

    d.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
    return d;
  }
}
