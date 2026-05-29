import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/config/app_config.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/repositories/health_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:8000';

  group('AppConfig', () {
    test('requireApiBaseUrl throws when API_BASE_URL is empty', () {
      expect(
        () => AppConfig.requireApiBaseUrl(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('API_BASE_URL is not set'),
          ),
        ),
      );
    });
  });

  group('ApiClient', () {
    late MockClient mockClient;
    late ApiClient apiClient;

    setUp(() {
      mockClient = MockClient((_) async {
        throw UnimplementedError('Override per test');
      });
      apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );
    });

    tearDown(() {
      apiClient.close();
    });

    test('GET success returns JSON map', () async {
      mockClient = MockClient((request) async {
        expect(request.url.toString(), '$baseUrl/api/v1/health');
        expect(request.headers['Accept'], 'application/json');
        return http.Response(
          jsonEncode({'status': 'ok', 'version': 'v1'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: baseUrl,
      );

      final json = await apiClient.getJson('/api/v1/health');
      expect(json['status'], 'ok');
      expect(json['version'], 'v1');
    });

    test('non-2xx v1 error throws ApiException', () async {
      mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'code': 'TICKET_NOT_FOUND',
            'message': 'Not found',
            'request_id': 'req_test',
          }),
          404,
        );
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      expect(
        () => apiClient.getJson('/api/v1/missing'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.error.code, 'code', 'TICKET_NOT_FOUND'),
        ),
      );
    });

    test('non-JSON error body falls back to unknown_error', () async {
      mockClient = MockClient((_) async {
        return http.Response('plain text error', 502);
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      final ex = await _expectApiException(
        () => apiClient.getJson('/api/v1/health'),
      );
      expect(ex.statusCode, 502);
      expect(ex.error.code, 'unknown_error');
    });

    test('timeout throws ApiException with code timeout', () async {
      mockClient = MockClient((_) async {
        await Future<void>.delayed(const Duration(seconds: 10));
        return http.Response('{}', 200);
      });
      apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(milliseconds: 50),
      );

      final ex = await _expectApiException(
        () => apiClient.getJson('/api/v1/health'),
      );
      expect(ex.error.code, 'timeout');
      expect(ex.statusCode, 0);
    });

    test('network error throws ApiException with code network_error', () async {
      mockClient = MockClient((_) async {
        throw http.ClientException('Connection refused');
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      final ex = await _expectApiException(
        () => apiClient.getJson('/api/v1/health'),
      );
      expect(ex.error.code, 'network_error');
    });

    test('postJson sends JSON body', () async {
      mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], 'application/json');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['username'], 'u');
        return http.Response(
          jsonEncode({'access_token': 'a', 'refresh_token': 'r'}),
          200,
        );
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      final json = await apiClient.postJson(
        '/api/v1/auth/login',
        {'username': 'u', 'password': 'p'},
        skipAuthRetry: true,
      );
      expect(json['access_token'], 'a');
    });

    test('postVoid accepts 204 without JSON', () async {
      mockClient = MockClient((_) async => http.Response('', 204));
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      await apiClient.postVoid(
        '/api/v1/auth/logout',
        {'refresh_token': 'rt'},
        authenticated: true,
        skipAuthRetry: true,
      );
    });

    test('authenticated GET sends Bearer header', () async {
      mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer my_token');
        return http.Response('{"status":"ok","version":"v1"}', 200);
      });
      apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: baseUrl,
      )..getAccessToken = () => 'my_token';

      await apiClient.getJson('/api/v1/health', authenticated: true);
    });

    test('401 retries once after onUnauthorized succeeds', () async {
      var callCount = 0;
      mockClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response(
            jsonEncode({'code': 'UNAUTHORIZED', 'message': 'expired'}),
            401,
          );
        }
        expect(request.headers['Authorization'], 'Bearer refreshed');
        return http.Response(
          jsonEncode({
            'id': 'staff:x',
            'username': 'x',
            'role': 'staff',
            'permissions': {
              'tickets_read': true,
              'tickets_write': true,
              'analytics_read': false,
              'knowledge_read': false,
              'knowledge_write': false,
              'bot_config_read': false,
              'bot_config_write': false,
            },
          }),
          200,
        );
      });
      var token = 'old';
      apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: baseUrl,
      );
      apiClient.getAccessToken = () => token;
      apiClient.onUnauthorized = () async {
        token = 'refreshed';
        return true;
      };

      final json = await apiClient.getJson(
        '/api/v1/users/me',
        authenticated: true,
      );
      expect(callCount, 2);
      expect(json['username'], 'x');
    });

    test('patchJson sends JSON body with Bearer', () async {
      mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/tickets/42');
        expect(request.headers['Authorization'], 'Bearer patch_token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'closed');
        return http.Response(
          jsonEncode({
            'id': 42,
            'status': 'closed',
            'origin': 'legacy',
            'created_at': '2024-01-01T00:00:00',
            'updated_at': '2024-01-01T00:00:00',
            'customer_email': 'g@example.com',
            'questions': [],
            'allowed_actions': ['reopen', 'archive'],
            'message_count': 0,
          }),
          200,
        );
      });
      apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: baseUrl,
      )..getAccessToken = () => 'patch_token';

      final json = await apiClient.patchJson(
        '/api/v1/tickets/42',
        {'status': 'closed'},
        authenticated: true,
      );
      expect(json['status'], 'closed');
    });

    test('strips trailing slash from base URL', () async {
      final client = ApiClient(
        httpClient: MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/api/v1/health');
          return http.Response('{"status":"ok","version":"v1"}', 200);
        }),
        baseUrl: '$baseUrl/',
      );
      addTearDown(client.close);
      await client.getJson('/api/v1/health');
    });

    test('getJsonList parses JSON array', () async {
      mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/knowledge/documents');
        return http.Response(
          jsonEncode([
            {'filename': 'a.md', 'content': 'Hello'},
          ]),
          200,
        );
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      final list = await apiClient.getJsonList('/api/v1/knowledge/documents');
      expect(list, hasLength(1));
      expect((list.first as Map)['filename'], 'a.md');
    });

    test('getJsonList non-array 2xx throws invalid_json', () async {
      mockClient = MockClient((_) async {
        return http.Response(jsonEncode({'data': []}), 200);
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      await expectLater(
        apiClient.getJsonList('/api/v1/knowledge/documents'),
        throwsA(isA<ApiException>().having((e) => e.error.code, 'code', 'invalid_json')),
      );
    });

    test('getJsonList non-2xx throws ApiException', () async {
      mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({'code': 'AUTH_FORBIDDEN', 'message': 'Forbidden'}),
          403,
        );
      });
      apiClient = ApiClient(httpClient: mockClient, baseUrl: baseUrl);

      await expectLater(
        apiClient.getJsonList('/api/v1/knowledge/documents'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 403)),
      );
    });
  });

  group('HealthRepository', () {
    test('parses status and version from health endpoint', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({'status': 'ok', 'version': 'v1'}),
          200,
        );
      });
      final repository = HealthRepository(
        apiClient: ApiClient(httpClient: mockClient, baseUrl: baseUrl),
      );

      final health = await repository.checkHealth();
      expect(health.status, 'ok');
      expect(health.version, 'v1');
    });
  });
}

Future<ApiException> _expectApiException(
  Future<void> Function() action,
) async {
  try {
    await action();
    fail('Expected ApiException');
  } on ApiException catch (e) {
    return e;
  }
}
