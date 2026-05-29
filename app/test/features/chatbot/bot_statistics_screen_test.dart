import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/core/session/session_controller.dart';
import 'package:host_flow/data/models/analytics_models.dart';
import 'package:host_flow/data/models/user_models.dart';
import 'package:host_flow/data/repositories/analytics_repository.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:host_flow/features/chatbot/view/bot_statistics_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import '../../core/storage/fake_token_storage.dart';

Map<String, dynamic> _samplePayload() => {
      'period_days': 30,
      'summary': {
        'total_interactions': 2,
        'distinct_sessions': 1,
        'avg_messages_per_session': 2.0,
        'fallback_count': 1,
        'fallback_rate': 0.5,
        'avg_response_time_ms': 150.0,
        'token_events_with_usage': 1,
        'token_sum': 25,
        'token_avg': 25.0,
      },
      'usage_by_day': [
        {'date': '2026-05-28', 'count': 2},
      ],
      'usage_by_hour': [
        {'hour': 10, 'count': 2},
      ],
      'latency': {'avg_ms': 150.0, 'min': null, 'max': null},
      'latency_events': [],
      'categories': [
        {'category': 'preise', 'count': 1},
      ],
    };

Map<String, dynamic> _emptyPayload() => {
      'period_days': 30,
      'summary': {
        'total_interactions': 0,
        'distinct_sessions': 0,
        'avg_messages_per_session': 0.0,
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

SessionController _superSession() {
  final client = ApiClient(
    httpClient: MockClient((_) async => http.Response('{}', 200)),
    baseUrl: 'http://127.0.0.1:8000',
  );
  final session = SessionController(
    authRepository: AuthRepository(apiClient: client),
    tokenStorage: FakeTokenStorage(),
  );
  session.status = SessionStatus.authenticated;
  session.currentUser = UserMeResponse.fromJson({
    'id': 'super:admin',
    'username': 'admin',
    'role': 'super',
    'permissions': {
      'tickets_read': true,
      'tickets_write': true,
      'analytics_read': true,
      'knowledge_read': true,
      'knowledge_write': true,
      'bot_config_read': true,
      'bot_config_write': true,
    },
  });
  return session;
}

SessionController _staffNoAnalyticsSession() {
  final client = ApiClient(
    httpClient: MockClient((_) async => http.Response('{}', 200)),
    baseUrl: 'http://127.0.0.1:8000',
  );
  final session = SessionController(
    authRepository: AuthRepository(apiClient: client),
    tokenStorage: FakeTokenStorage(),
  );
  session.status = SessionStatus.authenticated;
  session.currentUser = UserMeResponse.fromJson({
    'id': 'staff:alice',
    'username': 'alice',
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
  });
  return session;
}

class FakeAnalyticsRepository extends AnalyticsRepository {
  FakeAnalyticsRepository({
    Future<AnalyticsSummary> Function(int days)? onGetSummary,
  })  : _onGetSummary = onGetSummary,
        super(
          apiClient: ApiClient(
            httpClient: MockClient((_) async => http.Response('{}', 200)),
            baseUrl: 'http://127.0.0.1:8000',
          ),
        );

  final Future<AnalyticsSummary> Function(int days)? _onGetSummary;
  var callCount = 0;
  final List<int> requestedDays = [];

  @override
  Future<AnalyticsSummary> getSummary({int days = 30}) async {
    callCount++;
    requestedDays.add(days);
    if (_onGetSummary != null) return _onGetSummary(days);
    return AnalyticsSummary.fromJson(_emptyPayload());
  }
}

Widget _wrapStats({
  required FakeAnalyticsRepository repo,
  SessionController? session,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 900,
        width: 1200,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<SessionController>.value(
              value: session ?? _superSession(),
            ),
          ],
          child: BotStatisticsScreen(repository: repo),
        ),
      ),
    ),
  );
}

void main() {
  Future<void> pumpLarge(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(child);
  }

  testWidgets('shows loading then summary metrics', (tester) async {
    final repo = FakeAnalyticsRepository(
      onGetSummary: (days) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        final payload = _samplePayload();
        payload['period_days'] = days;
        return AnalyticsSummary.fromJson(payload);
      },
    );

    await pumpLarge(tester, _wrapStats(repo: repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Interaktionen'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('preise'), findsOneWidget);
  });

  testWidgets('empty state when no interactions', (tester) async {
    final repo = FakeAnalyticsRepository(
      onGetSummary: (_) async => AnalyticsSummary.fromJson(_emptyPayload()),
    );

    await pumpLarge(tester, _wrapStats(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Noch keine Analytics-Daten im gewählten Zeitraum.'),
      findsOneWidget,
    );
  });

  testWidgets('error state and retry', (tester) async {
    var calls = 0;
    final repo = FakeAnalyticsRepository(
      onGetSummary: (_) async {
        calls++;
        if (calls == 1) {
          throw ApiException(
            statusCode: 500,
            error: const ApiErrorResponse(
              code: 'SERVER_ERROR',
              message: 'Server down',
            ),
          );
        }
        return AnalyticsSummary.fromJson(_samplePayload());
      },
    );

    await pumpLarge(tester, _wrapStats(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Server down'), findsOneWidget);

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Interaktionen'), findsOneWidget);
    expect(repo.callCount, greaterThanOrEqualTo(2));
  });

  testWidgets('permission error without analytics_read', (tester) async {
    final repo = FakeAnalyticsRepository();

    await pumpLarge(
      tester,
      _wrapStats(repo: repo, session: _staffNoAnalyticsSession()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.textContaining('Keine Berechtigung, Analytics zu laden'),
      findsOneWidget,
    );
    expect(repo.callCount, 0);
  });

  testWidgets('days selector reloads with new days param', (tester) async {
    final repo = FakeAnalyticsRepository(
      onGetSummary: (days) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        final payload = _emptyPayload();
        payload['period_days'] = days;
        if (days == 7) {
          payload['summary'] = {
            'total_interactions': 1,
            'distinct_sessions': 1,
            'avg_messages_per_session': 1.0,
            'fallback_count': 0,
            'fallback_rate': 0.0,
            'token_events_with_usage': 0,
          };
        }
        return AnalyticsSummary.fromJson(payload);
      },
    );

    await pumpLarge(tester, _wrapStats(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repo.requestedDays.last, 30);

    await tester.tap(find.text('7 Tage'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repo.requestedDays, contains(7));
    expect(find.text('Interaktionen'), findsOneWidget);
  });
}
