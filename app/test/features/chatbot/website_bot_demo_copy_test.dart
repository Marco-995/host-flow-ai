import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/session/session_controller.dart';
import 'package:host_flow/data/models/bot_config_models.dart';
import 'package:host_flow/data/models/user_models.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:host_flow/features/chatbot/view/chatbot_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import '../../core/storage/fake_token_storage.dart';
import 'knowledge_base_screen_test.dart' show FakeAgentRepository;

void main() {
  testWidgets('shows honest demo KPI and mock chat labels', (tester) async {
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

    final repo = FakeAgentRepository(
      onGetBotConfig: () async => BotConfiguration.fromJson({
        'system_prompt': 'p',
        'welcome_message': 'Hi',
      }),
    );

    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<SessionController>.value(value: session),
            ],
            child: WebsiteBotScreen(repository: repo),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Demo-KPIs — echte Analytics findest du unter Bot Statistiken.'),
      findsOneWidget,
    );
    expect(
      find.text('Mock-Chat — keine Conversation API in v1.'),
      findsOneWidget,
    );
    expect(find.textContaining('Step 8'), findsNothing);
  });
}
