import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

/// Resolves the API base URL at runtime so the same binary works on
/// Android emulator (10.0.2.2) and Linux/Windows/macOS desktop (127.0.0.1).
///
/// Precedence:
///   1. `API_BASE` set explicitly via --dart-define (always wins)
///   2. Android  -> http://10.0.2.2:3000/api/v1
///   3. Desktop -> http://127.0.0.1:3000/api/v1
///   4. Other   -> http://localhost:3000/api/v1
String _resolveBaseUrl() {
  const explicit = String.fromEnvironment('API_BASE', defaultValue: '');
  if (explicit.isNotEmpty) return explicit;

  // kIsWeb is the only platform branch that dart:io can't answer; default
  // to localhost which works for Chrome when the API is reverse-proxied.
  if (kIsWeb) return 'http://localhost:3000/api/v1';

  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
  } catch (_) {
    // Platform may not be available in some test harnesses; fall through.
  }
  return 'http://127.0.0.1:3000/api/v1';
}

class ApiClient {
  ApiClient({required SecureStorageService storage})
      : _storage = storage,
        _dio = Dio(
          BaseOptions(
            baseUrl: _resolveBaseUrl(),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.add(_buildAuthInterceptor());
    _dio.interceptors.add(_buildErrorInterceptor());
    _dio.interceptors.add(_buildLogInterceptor());
  }

  final Dio _dio;
  // ignore: unused_field
  final SecureStorageService _storage;

  Dio get raw => _dio;

  /// The base URL this client was constructed with. Exposed so startup
  /// diagnostics (see `main.dart`) can log which endpoint is in use
  /// without re-running the platform-aware resolver.
  String get resolvedBaseUrl => _dio.options.baseUrl;

  Interceptor _buildAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  Interceptor _buildErrorInterceptor() {
    return InterceptorsWrapper(
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == false) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: ApiException.fromResponse(
                data,
                statusCode: response.statusCode,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.next(response);
      },
      onError: (error, handler) {
        final response = error.response;
        if (response?.data is Map<String, dynamic>) {
          final body = response!.data as Map<String, dynamic>;
          if (body['success'] == false) {
            handler.next(
              DioException(
                requestOptions: error.requestOptions,
                response: response,
                error: ApiException.fromResponse(
                  body,
                  statusCode: response.statusCode,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
        }
        handler.next(error);
      },
    );
  }

  Interceptor _buildLogInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint('→ ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
              '← ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint(
              '✗ ${error.requestOptions.method} ${error.requestOptions.uri}: ${error.message}');
        }
        handler.next(error);
      },
    );
  }
}
