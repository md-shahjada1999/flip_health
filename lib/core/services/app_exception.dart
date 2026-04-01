class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory AppException.timeout() =>
      AppException(message: 'Request Timeout', statusCode: 408);

  factory AppException.network() =>
      AppException(message: 'No internet connection');

  factory AppException.unauthorized() =>
      AppException(message: 'Session expired. Please login again.', statusCode: 401);

  factory AppException.server([String? detail]) => AppException(
        message: detail ?? 'Something went wrong. Please try again.',
        statusCode: 500,
      );

  factory AppException.unknown([String? detail]) =>
      AppException(message: detail ?? 'An unexpected error occurred');

  @override
  String toString() => message;
}
