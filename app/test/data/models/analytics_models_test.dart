import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/data/models/analytics_models.dart';

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
        {'hour': 11, 'count': 0},
      ],
      'latency': {
        'avg_ms': 150.0,
        'min': {
          'ms': 120,
          'category': 'preise',
          'timestamp': '2026-05-28T10:00:00+00:00',
        },
        'max': {
          'ms': 180,
          'category': 'service',
          'timestamp': '2026-05-28T10:01:00+00:00',
        },
      },
      'latency_events': [
        {'timestamp': '2026-05-28T10:00:00+00:00', 'ms': 120},
      ],
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
        'avg_response_time_ms': null,
        'token_events_with_usage': 0,
        'token_sum': null,
        'token_avg': null,
      },
      'usage_by_day': [],
      'usage_by_hour': List.generate(
        24,
        (h) => {'hour': h, 'count': 0},
      ),
      'latency': {'avg_ms': null, 'min': null, 'max': null},
      'latency_events': [],
      'categories': [],
    };

void main() {
  test('AnalyticsSummary parses realistic backend sample', () {
    final summary = AnalyticsSummary.fromJson(_samplePayload());
    expect(summary.periodDays, 30);
    expect(summary.summary.totalInteractions, 2);
    expect(summary.summary.distinctSessions, 1);
    expect(summary.summary.fallbackRate, 0.5);
    expect(summary.summary.avgResponseTimeMs, 150.0);
    expect(summary.usageByDay, hasLength(1));
    expect(summary.categories.first.category, 'preise');
    expect(summary.latency.min?.ms, 120);
    expect(summary.hasActivity, isTrue);
    expect(summary.peakHour, 10);
  });

  test('AnalyticsSummary parses empty no-data response', () {
    final summary = AnalyticsSummary.fromJson(_emptyPayload());
    expect(summary.hasActivity, isFalse);
    expect(summary.summary.totalInteractions, 0);
    expect(summary.usageByDay, isEmpty);
    expect(summary.categories, isEmpty);
    expect(summary.peakHour, isNull);
  });

  test('missing optional fields are defensive', () {
    final summary = AnalyticsSummary.fromJson({
      'period_days': 7,
      'summary': {'total_interactions': 1},
    });
    expect(summary.periodDays, 7);
    expect(summary.summary.distinctSessions, 0);
    expect(summary.summary.avgResponseTimeMs, isNull);
    expect(summary.usageByDay, isEmpty);
  });

  test('numeric int/double coercion', () {
    final metrics = AnalyticsSummaryMetrics.fromJson({
      'total_interactions': 3,
      'distinct_sessions': 2,
      'avg_messages_per_session': 1,
      'fallback_count': 0,
      'fallback_rate': 1,
      'avg_response_time_ms': 99,
    });
    expect(metrics.avgMessagesPerSession, 1.0);
    expect(metrics.fallbackRate, 1.0);
    expect(metrics.avgResponseTimeMs, 99.0);
  });

  test('invalid list entries are skipped', () {
    final summary = AnalyticsSummary.fromJson({
      'period_days': 30,
      'summary': {'total_interactions': 1},
      'categories': [
        {'category': 'ok', 'count': 1},
        'bad',
        42,
      ],
    });
    expect(summary.categories, hasLength(1));
    expect(summary.categories.first.category, 'ok');
  });
}
