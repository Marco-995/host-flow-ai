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
