import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_error.dart';

/// Central HTTP wrapper for cp-chatbot /api/v1.
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

  /// Returns current access token for authenticated requests.
  String? Function()? getAccessToken;

  /// Called on 401; return true to retry the request once with a new token.
  Future<bool> Function()? onUnauthorized;

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static const _authRetrySkipPaths = {
    '/api/v1/auth/login',
    '/api/v1/auth/refresh',
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

  Map<String, String> _headers({required bool authenticated}) {
    final headers = Map<String, String>.from(_jsonHeaders);
    if (authenticated) {
      final token = getAccessToken?.call();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  bool _canRetryAuth(String path, bool skipAuthRetry) {
    return !skipAuthRetry && !_authRetrySkipPaths.contains(path);
  }

  /// GET request returning a JSON object map.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    bool authenticated = false,
    bool skipAuthRetry = false,
  }) async {
    final response = await _send(
      path: path,
      query: query,
      authenticated: authenticated,
      skipAuthRetry: skipAuthRetry,
      send: (uri, headers) => _httpClient.get(uri, headers: headers),
    );
    return _handleJsonResponse(response);
  }

  /// POST request returning a JSON object map.
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
    bool skipAuthRetry = false,
  }) async {
    final response = await _send(
      path: path,
      authenticated: authenticated,
      skipAuthRetry: skipAuthRetry,
      send: (uri, headers) => _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _handleJsonResponse(response);
  }

  /// POST request with no JSON body in the response (e.g. 204 logout).
  Future<void> postVoid(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
    bool skipAuthRetry = false,
  }) async {
    final response = await _send(
      path: path,
      authenticated: authenticated,
      skipAuthRetry: skipAuthRetry,
      send: (uri, headers) => _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    _handleVoidResponse(response);
  }

  Future<http.Response> _send({
    required String path,
    Map<String, String>? query,
    required bool authenticated,
    required bool skipAuthRetry,
    required Future<http.Response> Function(Uri uri, Map<String, String> headers)
        send,
  }) async {
    final uri = _buildUri(path, query: query);
    var retried = false;

    while (true) {
      try {
        final response = await send(uri, _headers(authenticated: authenticated))
            .timeout(_timeout);

        if (response.statusCode == 401 &&
            authenticated &&
            !retried &&
            _canRetryAuth(path, skipAuthRetry) &&
            onUnauthorized != null) {
          final refreshed = await onUnauthorized!();
          if (refreshed) {
            retried = true;
            continue;
          }
        }

        return response;
      } on TimeoutException {
        throw ApiException.timeout();
      } on http.ClientException catch (e) {
        throw ApiException.network(e.message);
      }
    }
  }

  Map<String, dynamic> _handleJsonResponse(http.Response response) {
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

  void _handleVoidResponse(http.Response response) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      return;
    }

    throw ApiException.fromResponse(
      statusCode: status,
      body: response.body,
    );
  }

  void close() {
    if (_ownsClient) {
      _httpClient.close();
    }
  }
}
