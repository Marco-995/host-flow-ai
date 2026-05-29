import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
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

Widget _wrapWebsiteBot(FakeAgentRepository repo) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 900,
        width: 1200,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<SessionController>.value(
              value: _superSession(),
            ),
          ],
          child: WebsiteBotScreen(repository: repo),
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

  testWidgets('loads bot config and shows welcome in simulator', (tester) async {
    final repo = FakeAgentRepository(
      onGetBotConfig: () async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return BotConfiguration.fromJson({
          'system_prompt': 'You are the camping bot assistant.',
          'welcome_message': 'API Welcome from backend!',
        });
      },
    );

    await pumpLarge(tester, _wrapWebsiteBot(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('API Welcome from backend!'), findsAtLeastNWidgets(1));
    expect(find.textContaining('camping bot'), findsOneWidget);
  });

  testWidgets('bot config error shows retry', (tester) async {
    final repo = FakeAgentRepository(
      onGetBotConfig: () async {
        throw ApiException(
          statusCode: 403,
          error: const ApiErrorResponse(
            code: 'AUTH_FORBIDDEN',
            message: 'Forbidden',
          ),
        );
      },
    );

    await pumpLarge(tester, _wrapWebsiteBot(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Berechtigung'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
  });

  testWidgets('mock chat reply still works', (tester) async {
    final repo = FakeAgentRepository(
      onGetBotConfig: () async => BotConfiguration.fromJson({
        'system_prompt': 'p',
        'welcome_message': 'Hi',
      }),
    );

    await pumpLarge(tester, _wrapWebsiteBot(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(
      find.byType(TextField).last,
      'Darf ich einen Hund mitbringen?',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send).last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Hunde'), findsWidgets);
  });

  testWidgets('upload button shows coming soon', (tester) async {
    final repo = FakeAgentRepository(
      onGetBotConfig: () async => BotConfiguration.fromJson({
        'system_prompt': 'p',
        'welcome_message': 'w',
      }),
    );

    await pumpLarge(tester, _wrapWebsiteBot(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Neues Dokument hochladen'));
    await tester.pump();
    expect(
      find.text('Demnächst verfügbar (nur Lesezugriff in v1).'),
      findsOneWidget,
    );
  });
}
