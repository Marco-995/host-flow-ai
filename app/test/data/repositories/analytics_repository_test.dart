import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/repositories/analytics_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:8000';

  Map<String, dynamic> minimalSummary() => {
        'period_days': 30,
        'summary': {
          'total_interactions': 1,
          'distinct_sessions': 1,
          'avg_messages_per_session': 1.0,
          'fallback_count': 0,
          'fallback_rate': 0.0,
          'token_events_with_usage': 0,
        },
        'usage_by_day': [],
        'usage_by_hour': [],
        'latency': {},
        'latency_events': [],
        'categories': [],
      };

  test('getSummary success', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/analytics/summary');
        expect(request.url.queryParameters['days'], '30');
        return http.Response(jsonEncode(minimalSummary()), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final summary =
        await AnalyticsRepository(apiClient: client).getSummary(days: 30);
    expect(summary.summary.totalInteractions, 1);
  });

  test('getSummary sends days query param', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.url.queryParameters['days'], '7');
        return http.Response(jsonEncode(minimalSummary()), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    await AnalyticsRepository(apiClient: client).getSummary(days: 7);
  });

  test('getSummary clamps days below 1 and above 365', () async {
    String? capturedDays;
    final client = ApiClient(
      httpClient: MockClient((request) async {
        capturedDays = request.url.queryParameters['days'];
        return http.Response(jsonEncode(minimalSummary()), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final repo = AnalyticsRepository(apiClient: client);
    await repo.getSummary(days: 0);
    expect(capturedDays, '1');

    await repo.getSummary(days: 999);
    expect(capturedDays, '365');
  });

  test('getSummary sends Bearer when token set', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer at_super');
        return http.Response(jsonEncode(minimalSummary()), 200);
      }),
      baseUrl: baseUrl,
    )..getAccessToken = () => 'at_super';
    addTearDown(client.close);

    await AnalyticsRepository(apiClient: client).getSummary();
  });

  test('getSummary 403 throws ApiException', () async {
    final client = ApiClient(
      httpClient: MockClient((_) async {
        return http.Response(
          jsonEncode({'code': 'AUTH_FORBIDDEN', 'message': 'Forbidden'}),
          403,
        );
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    expect(
      () => AnalyticsRepository(apiClient: client).getSummary(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 403)),
    );
  });

  test('getSummary 500 throws ApiException', () async {
    final client = ApiClient(
      httpClient: MockClient((_) async {
        return http.Response(
          jsonEncode({'code': 'SERVER_ERROR', 'message': 'Server down'}),
          500,
        );
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    expect(
      () => AnalyticsRepository(apiClient: client).getSummary(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 500)),
    );
  });

  test('clampDays', () {
    expect(AnalyticsRepository.clampDays(0), 1);
    expect(AnalyticsRepository.clampDays(30), 30);
    expect(AnalyticsRepository.clampDays(400), 365);
  });
}
