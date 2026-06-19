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

  // ---------------------------------------------------------------------------
  // Per-resource request cancellation
  //
  // The mobile UI fires overlapping requests for the same resource (the
  // Alerts screen swaps tabs faster than the previous medicines query
  // completes). Without cancellation, a slow response to a stale filter
  // can race in and overwrite the state of the most recent request.
  //
  // Callers grab a fresh [CancelToken] via [beginMedicinesRequest] before
  // each call. Any token previously returned for the medicines resource is
  // cancelled, so the in-flight request bails out at the network layer.
  // ---------------------------------------------------------------------------
  CancelToken? _activeMedicinesToken;

  /// Returns a fresh [CancelToken] for a /medicines request and cancels any
  /// previous medicines request that is still in flight. The token is
  /// cleared automatically once the request that owns it completes.
  CancelToken beginMedicinesRequest() {
    // Cancel any in-flight medicines request before issuing a new one, so a
    // stale response cannot race in and overwrite the latest filter state.
    _activeMedicinesToken?.cancel('superseded');
    final token = CancelToken();
    _activeMedicinesToken = token;
    return token;
  }

  /// Cancels any in-flight medicines request. Safe to call from controller
  /// `onClose()` and safe to call multiple times.
  void cancelActiveMedicinesRequest() {
    _activeMedicinesToken?.cancel('superseded');
    _activeMedicinesToken = null;
  }

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
          final apiError = ApiException.fromResponse(
            data,
            statusCode: response.statusCode,
          );
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: apiError,
              message: apiError.message,
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
            final apiError = ApiException.fromResponse(
              body,
              statusCode: response.statusCode,
            );
            handler.next(
              DioException(
                requestOptions: error.requestOptions,
                response: response,
                error: apiError,
                message: apiError.message,
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
          // Log everything we have so failures can be diagnosed from the
          // console alone: status, the ApiException payload, and the raw
          // response body. `error.message` is unreliable (it is `null` for
          // DioExceptions we reject ourselves) so we read from `error.error`
          // and `error.response.data` instead.
          debugPrint(
            '✗ ${error.requestOptions.method} ${error.requestOptions.uri} '
            '| type=${error.type} '
            '| status=${error.response?.statusCode} '
            '| api=${error.error} '
            '| body=${error.response?.data}',
          );
        }
        handler.next(error);
      },
    );
  }
}
