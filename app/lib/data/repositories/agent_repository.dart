import '../../core/network/api_client.dart';
import '../models/bot_config_models.dart';
import '../models/knowledge_models.dart';

class AgentRepository {
  AgentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<BotConfiguration> getBotConfig() async {
    final json = await _apiClient.getJson(
      '/api/v1/bot-config/',
      authenticated: true,
    );
    return BotConfiguration.fromJson(json);
  }

  Future<KnowledgeDocumentsResponse> listKnowledgeDocuments() async {
    final json = await _apiClient.getJsonList(
      '/api/v1/knowledge/documents',
      authenticated: true,
    );
    return KnowledgeDocumentsResponse.fromJsonList(json);
  }
}
