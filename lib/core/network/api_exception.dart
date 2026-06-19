import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });

  final String code;
  final String message;
  final int? statusCode;
  final dynamic details;

  factory ApiException.fromResponse(
    Map<String, dynamic> body, {
    int? statusCode,
  }) {
    final error = body['error'] as Map<String, dynamic>?;
    return ApiException(
      code: (error?['code'] as String?) ?? 'UNKNOWN',
      message: (body['message'] as String?) ?? 'Terjadi kesalahan',
      statusCode: statusCode,
      details: error?['details'],
    );
  }

  bool get isRateLimited => code == 'RATE_LIMITED' || statusCode == 429;

  /// A calm, user-facing message. Never leaks internal class names like
  /// "ThrottlerException" or the raw "DioException [...]" prefix.
  String get friendlyMessage {
    switch (code) {
      case 'RATE_LIMITED':
        return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
      case 'UNAUTHORIZED':
        return 'Sesi Anda berakhir. Silakan masuk kembali.';
      case 'FORBIDDEN':
        return 'Anda tidak memiliki akses untuk tindakan ini.';
      case 'NOT_FOUND':
        return 'Data tidak ditemukan.';
    }
    if (statusCode == 429) {
      return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
    }
    if (statusCode == 500) {
      return 'Terjadi kesalahan di server. Coba lagi sebentar.';
    }
    return message.isNotEmpty ? message : 'Terjadi kesalahan.';
  }

  /// Converts any thrown error into a calm, user-facing message suitable
  /// for an error state or snackbar. Unwraps the [ApiException] that the
  /// network layer attaches to a [DioException], and maps transport-level
  /// failures (timeouts, no connection) to friendly text.
  static String messageFrom(Object error) {
    if (error is ApiException) return error.friendlyMessage;
    if (error is DioException) {
      final inner = error.error;
      if (inner is ApiException) return inner.friendlyMessage;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Server lama merespons. Coba lagi sebentar.';
        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
        default:
          if (error.response?.statusCode == 429) {
            return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
          }
          return 'Terjadi kesalahan jaringan. Coba lagi.';
      }
    }
    return 'Terjadi kesalahan.';
  }

  @override
  String toString() => 'ApiException($code): $message';
}
