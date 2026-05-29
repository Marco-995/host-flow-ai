import '../../core/network/api_client.dart';
import '../models/health_response.dart';

class HealthRepository {
  HealthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<HealthResponse> checkHealth() async {
    final json = await _apiClient.getJson('/api/v1/health');
    return HealthResponse.fromJson(json);
  }
}
