import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_error.dart';

/// Central HTTP wrapper for cp-chatbot /api/v1 (no auth in Step 1).
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Duration? timeout,
  })  : _httpClient = httpClient ?? http.Client(),
        _ownsClient = httpClient == null,
        _baseUrl = baseUrl,
        _timeout = timeout ?? AppConfig.requestTimeout;

  final http.Client _httpClient;
  final bool _ownsClient;
  final String? _baseUrl;
  final Duration _timeout;

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  String get _resolvedBaseUrl {
    final raw = (_baseUrl ?? AppConfig.requireApiBaseUrl()).trim();
    return raw.endsWith('/')
        ? raw.substring(0, raw.length - 1)
        : raw;
  }

  Uri _buildUri(String path, {Map<String, String>? query}) {
    if (!path.startsWith('/')) {
      throw ArgumentError.value(path, 'path', 'must start with /');
    }
    return Uri.parse('$_resolvedBaseUrl$path').replace(queryParameters: query);
  }

  /// GET request returning a JSON object map.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query: query);
    try {
      final response = await _httpClient
          .get(uri, headers: _jsonHeaders)
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException.timeout();
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;

    if (status >= 200 && status < 300) {
      if (body.trim().isEmpty) {
        throw ApiException.invalidJson('Empty response body.');
      }
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw ApiException.invalidJson(
          'Expected JSON object, got ${decoded.runtimeType}.',
        );
      } on FormatException catch (e) {
        throw ApiException.invalidJson(e.message);
      }
    }

    throw ApiException.fromResponse(statusCode: status, body: body);
  }

  void close() {
    if (_ownsClient) {
      _httpClient.close();
    }
  }
}
