import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/core/session/session_controller.dart';
import 'package:host_flow/data/models/bot_config_models.dart';
import 'package:host_flow/data/models/knowledge_models.dart';
import 'package:host_flow/data/models/user_models.dart';
import 'package:host_flow/data/repositories/agent_repository.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:host_flow/features/chatbot/view/knowledge_base_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import '../../core/storage/fake_token_storage.dart';

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

class FakeAgentRepository extends AgentRepository {
  FakeAgentRepository({
    Future<KnowledgeDocumentsResponse> Function()? onListKnowledge,
    Future<BotConfiguration> Function()? onGetBotConfig,
  })  : _onListKnowledge = onListKnowledge,
        _onGetBotConfig = onGetBotConfig,
        super(
          apiClient: ApiClient(
            httpClient: MockClient((_) async => http.Response('{}', 200)),
            baseUrl: 'http://127.0.0.1:8000',
          ),
        );

  final Future<KnowledgeDocumentsResponse> Function()? _onListKnowledge;
  final Future<BotConfiguration> Function()? _onGetBotConfig;
  var listCallCount = 0;

  @override
  Future<KnowledgeDocumentsResponse> listKnowledgeDocuments() async {
    listCallCount++;
    if (_onListKnowledge != null) return _onListKnowledge();
    return KnowledgeDocumentsResponse.fromJsonList([]);
  }

  @override
  Future<BotConfiguration> getBotConfig() async {
    if (_onGetBotConfig != null) return _onGetBotConfig();
    return BotConfiguration.fromJson({
      'system_prompt': 'p',
      'welcome_message': 'w',
    });
  }
}

Widget _wrapKnowledge(FakeAgentRepository repo) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 900,
        width: 1600,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<SessionController>.value(
              value: _superSession(),
            ),
          ],
          child: KnowledgeBaseScreen(repository: repo),
        ),
      ),
    ),
  );
}

void main() {
  Future<void> pumpLarge(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(child);
  }

  testWidgets('shows loading then document list', (tester) async {
    final repo = FakeAgentRepository(
      onListKnowledge: () async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return KnowledgeDocumentsResponse.fromJsonList([
          {'filename': 'rules.md', 'content': 'Rule text here'},
        ]);
      },
    );

    await pumpLarge(tester, _wrapKnowledge(repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('rules.md'), findsOneWidget);
    expect(find.textContaining('Rule text'), findsAtLeastNWidgets(1));
  });

  testWidgets('empty state', (tester) async {
    final repo = FakeAgentRepository(
      onListKnowledge: () async => KnowledgeDocumentsResponse.fromJsonList([]),
    );

    await pumpLarge(tester, _wrapKnowledge(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Keine Knowledge-Dokumente gefunden.'), findsOneWidget);
  });

  testWidgets('error state and retry', (tester) async {
    var calls = 0;
    final repo = FakeAgentRepository(
      onListKnowledge: () async {
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
        return KnowledgeDocumentsResponse.fromJsonList([
          {'filename': 'ok.md', 'content': 'OK'},
        ]);
      },
    );

    await pumpLarge(tester, _wrapKnowledge(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Server down'), findsOneWidget);

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('ok.md'), findsOneWidget);
    expect(repo.listCallCount, greaterThanOrEqualTo(2));
  });

  testWidgets('sync button disabled upload shows coming soon', (tester) async {
    final repo = FakeAgentRepository();

    await pumpLarge(tester, _wrapKnowledge(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final syncButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Alle neu synchronisieren'),
    );
    expect(syncButton.onPressed, isNull);

    await tester.tap(find.text('PDF Hochladen'));
    await tester.pump();
    expect(
      find.text('Demnächst verfügbar (nur Lesezugriff in v1).'),
      findsOneWidget,
    );
    expect(repo.listCallCount, 1);
  });
}
