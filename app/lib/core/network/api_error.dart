import 'dart:convert';

/// cp-chatbot /api/v1 error envelope (flat JSON at response root).
class ApiErrorResponse {
  const ApiErrorResponse({
    required this.code,
    required this.message,
    this.details,
    this.requestId,
  });

  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final String? requestId;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['error'];
    if (nested is Map<String, dynamic>) {
      return ApiErrorResponse._fromFlatMap(nested);
    }
    return ApiErrorResponse._fromFlatMap(json);
  }

  factory ApiErrorResponse._fromFlatMap(Map<String, dynamic> json) {
    final code = json['code'];
    final message = json['message'];
    if (code is String && message is String) {
      final details = json['details'];
      return ApiErrorResponse(
        code: code,
        message: message,
        details: details is Map<String, dynamic> ? details : null,
        requestId: json['request_id'] as String?,
      );
    }
    return ApiErrorResponse(
      code: 'unknown_error',
      message: message is String ? message : 'An unknown error occurred.',
      details: null,
      requestId: json['request_id'] as String?,
    );
  }

  factory ApiErrorResponse.unknown({String? message, int? statusCode}) {
    final suffix = statusCode != null ? ' (HTTP $statusCode)' : '';
    return ApiErrorResponse(
      code: 'unknown_error',
      message: message ?? 'An unknown error occurred.$suffix',
    );
  }

  factory ApiErrorResponse.network(String message) {
    return ApiErrorResponse(code: 'network_error', message: message);
  }

  factory ApiErrorResponse.timeout() {
    return const ApiErrorResponse(
      code: 'timeout',
      message: 'The request timed out.',
    );
  }

  factory ApiErrorResponse.invalidJson(String message) {
    return ApiErrorResponse(code: 'invalid_json', message: message);
  }

  @override
  String toString() {
    final id = requestId != null ? ', request_id=$requestId' : '';
    return 'ApiErrorResponse(code=$code, message=$message$id)';
  }
}

/// Thrown by [ApiClient] for HTTP, network, and parse failures.
class ApiException implements Exception {
  const ApiException({
    required this.error,
    required this.statusCode,
    this.rawBody,
  });

  final ApiErrorResponse error;
  final int statusCode;
  final String? rawBody;

  factory ApiException.fromResponse({
    required int statusCode,
    required String body,
  }) {
    try {
      final decoded = _decodeJsonMap(body);
      if (decoded != null) {
        return ApiException(
          statusCode: statusCode,
          error: ApiErrorResponse.fromJson(decoded),
          rawBody: body,
        );
      }
    } catch (_) {
      // Fall through to unknown_error.
    }
    return ApiException(
      statusCode: statusCode,
      error: ApiErrorResponse.unknown(
        message: body.isNotEmpty ? body : null,
        statusCode: statusCode,
      ),
      rawBody: body,
    );
  }

  factory ApiException.network(String message) {
    return ApiException(
      statusCode: 0,
      error: ApiErrorResponse.network(message),
    );
  }

  factory ApiException.timeout() {
    return ApiException(
      statusCode: 0,
      error: ApiErrorResponse.timeout(),
    );
  }

  factory ApiException.invalidJson(String message) {
    return ApiException(
      statusCode: 0,
      error: ApiErrorResponse.invalidJson(message),
    );
  }

  static Map<String, dynamic>? _decodeJsonMap(String body) {
    if (body.trim().isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  String toString() => 'ApiException(statusCode=$statusCode, error=$error)';
}
