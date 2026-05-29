import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/repositories/agent_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:8000';

  test('getBotConfig success', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/bot-config/');
        return http.Response(
          jsonEncode({
            'system_prompt': 'Prompt',
            'welcome_message': 'Welcome',
          }),
          200,
        );
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final config = await AgentRepository(apiClient: client).getBotConfig();
    expect(config.welcomeMessage, 'Welcome');
    expect(config.systemPrompt, 'Prompt');
  });

  test('getBotConfig sends Bearer when token set', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer at_super');
        return http.Response(
          jsonEncode({'system_prompt': 'p', 'welcome_message': 'w'}),
          200,
        );
      }),
      baseUrl: baseUrl,
    )..getAccessToken = () => 'at_super';
    addTearDown(client.close);

    await AgentRepository(apiClient: client).getBotConfig();
  });

  test('listKnowledgeDocuments success', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/knowledge/documents');
        return http.Response(
          jsonEncode([
            {'filename': 'doc.md', 'content': '# Hi'},
          ]),
          200,
        );
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final result =
        await AgentRepository(apiClient: client).listKnowledgeDocuments();
    expect(result.documents, hasLength(1));
    expect(result.documents.first.filename, 'doc.md');
  });

  test('getBotConfig 403 throws ApiException', () async {
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
      () => AgentRepository(apiClient: client).getBotConfig(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 403)),
    );
  });
}
