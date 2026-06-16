import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/dummy_flag.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required SecureStorageService storage})
      : _storage = storage,
        _dio = Dio(
          BaseOptions(
            baseUrl: kApiBaseUrl,
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
