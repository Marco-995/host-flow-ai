import '../../core/network/api_client.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository {
  AnalyticsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static int clampDays(int days) {
    if (days < 1) return 1;
    if (days > 365) return 365;
    return days;
  }

  Future<AnalyticsSummary> getSummary({int days = 30}) async {
    final clamped = clampDays(days);
    final json = await _apiClient.getJson(
      '/api/v1/analytics/summary',
      authenticated: true,
      query: {'days': '$clamped'},
    );
    return AnalyticsSummary.fromJson(json);
  }
}
