// Models for GET /api/v1/analytics/summary.

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return null;
}

class AnalyticsSummaryMetrics {
  const AnalyticsSummaryMetrics({
    required this.totalInteractions,
    required this.distinctSessions,
    required this.avgMessagesPerSession,
    required this.fallbackCount,
    required this.fallbackRate,
    this.avgResponseTimeMs,
    required this.tokenEventsWithUsage,
    this.tokenSum,
    this.tokenAvg,
  });

  final int totalInteractions;
  final int distinctSessions;
  final double avgMessagesPerSession;
  final int fallbackCount;
  final double fallbackRate;
  final double? avgResponseTimeMs;
  final int tokenEventsWithUsage;
  final int? tokenSum;
  final double? tokenAvg;

  factory AnalyticsSummaryMetrics.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryMetrics(
      totalInteractions: _asInt(json['total_interactions']),
      distinctSessions: _asInt(json['distinct_sessions']),
      avgMessagesPerSession: _asDouble(json['avg_messages_per_session']),
      fallbackCount: _asInt(json['fallback_count']),
      fallbackRate: _asDouble(json['fallback_rate']),
      avgResponseTimeMs: _asNullableDouble(json['avg_response_time_ms']),
      tokenEventsWithUsage: _asInt(json['token_events_with_usage']),
      tokenSum: json['token_sum'] == null ? null : _asInt(json['token_sum']),
      tokenAvg: _asNullableDouble(json['token_avg']),
    );
  }
}

class AnalyticsDayCount {
  const AnalyticsDayCount({required this.date, required this.count});

  final String date;
  final int count;

  factory AnalyticsDayCount.fromJson(Map<String, dynamic> json) {
    return AnalyticsDayCount(
      date: json['date'] as String? ?? '',
      count: _asInt(json['count']),
    );
  }
}

class AnalyticsHourCount {
  const AnalyticsHourCount({required this.hour, required this.count});

  final int hour;
  final int count;

  factory AnalyticsHourCount.fromJson(Map<String, dynamic> json) {
    return AnalyticsHourCount(
      hour: _asInt(json['hour']),
      count: _asInt(json['count']),
    );
  }
}

class AnalyticsLatencyExtrema {
  const AnalyticsLatencyExtrema({
    required this.ms,
    required this.category,
    required this.timestamp,
  });

  final int ms;
  final String category;
  final String timestamp;

  factory AnalyticsLatencyExtrema.fromJson(Map<String, dynamic> json) {
    return AnalyticsLatencyExtrema(
      ms: _asInt(json['ms']),
      category: json['category'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

class AnalyticsLatencyBlock {
  const AnalyticsLatencyBlock({
    this.avgMs,
    this.min,
    this.max,
  });

  final double? avgMs;
  final AnalyticsLatencyExtrema? min;
  final AnalyticsLatencyExtrema? max;

  factory AnalyticsLatencyBlock.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AnalyticsLatencyBlock();
    }
    final minJson = json['min'];
    final maxJson = json['max'];
    return AnalyticsLatencyBlock(
      avgMs: _asNullableDouble(json['avg_ms']),
      min: minJson is Map<String, dynamic>
          ? AnalyticsLatencyExtrema.fromJson(minJson)
          : null,
      max: maxJson is Map<String, dynamic>
          ? AnalyticsLatencyExtrema.fromJson(maxJson)
          : null,
    );
  }
}

class AnalyticsCategoryCount {
  const AnalyticsCategoryCount({required this.category, required this.count});

  final String category;
  final int count;

  factory AnalyticsCategoryCount.fromJson(Map<String, dynamic> json) {
    return AnalyticsCategoryCount(
      category: json['category'] as String? ?? '',
      count: _asInt(json['count']),
    );
  }
}

class AnalyticsLatencyPoint {
  const AnalyticsLatencyPoint({required this.timestamp, required this.ms});

  final String timestamp;
  final int ms;

  factory AnalyticsLatencyPoint.fromJson(Map<String, dynamic> json) {
    return AnalyticsLatencyPoint(
      timestamp: json['timestamp'] as String? ?? '',
      ms: _asInt(json['ms']),
    );
  }
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.periodDays,
    required this.summary,
    required this.usageByDay,
    required this.usageByHour,
    required this.latency,
    required this.latencyEvents,
    required this.categories,
  });

  final int periodDays;
  final AnalyticsSummaryMetrics summary;
  final List<AnalyticsDayCount> usageByDay;
  final List<AnalyticsHourCount> usageByHour;
  final AnalyticsLatencyBlock latency;
  final List<AnalyticsLatencyPoint> latencyEvents;
  final List<AnalyticsCategoryCount> categories;

  bool get hasActivity => summary.totalInteractions > 0;

  /// Hour with highest count (0–23), or null if all zero.
  int? get peakHour {
    if (usageByHour.isEmpty) return null;
    var best = usageByHour.first;
    for (final row in usageByHour) {
      if (row.count > best.count) best = row;
    }
    return best.count > 0 ? best.hour : null;
  }

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'];
    final metrics = summaryJson is Map<String, dynamic>
        ? AnalyticsSummaryMetrics.fromJson(summaryJson)
        : AnalyticsSummaryMetrics.fromJson({});

    return AnalyticsSummary(
      periodDays: _asInt(json['period_days'], fallback: 30),
      summary: metrics,
      usageByDay: _parseList(json['usage_by_day'], AnalyticsDayCount.fromJson),
      usageByHour: _parseList(json['usage_by_hour'], AnalyticsHourCount.fromJson),
      latency: AnalyticsLatencyBlock.fromJson(
        json['latency'] is Map<String, dynamic>
            ? json['latency'] as Map<String, dynamic>
            : null,
      ),
      latencyEvents:
          _parseList(json['latency_events'], AnalyticsLatencyPoint.fromJson),
      categories: _parseList(json['categories'], AnalyticsCategoryCount.fromJson),
    );
  }
}

List<T> _parseList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is! List) return [];
  final items = <T>[];
  for (final entry in raw) {
    if (entry is Map<String, dynamic>) {
      items.add(fromJson(entry));
    }
  }
  return items;
}
