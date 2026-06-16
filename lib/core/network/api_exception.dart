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

  @override
  String toString() => 'ApiException($code): $message';
}
