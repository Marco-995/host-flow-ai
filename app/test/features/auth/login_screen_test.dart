import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/session/session_controller.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:host_flow/features/auth/view/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import '../../core/storage/fake_token_storage.dart';

void main() {
  testWidgets('LoginScreen renders fields and button', (tester) async {
    final client = ApiClient(
      httpClient: MockClient((_) async => http.Response('{}', 200)),
      baseUrl: 'http://127.0.0.1:8000',
    );
    final session = SessionController(
      authRepository: AuthRepository(apiClient: client),
      tokenStorage: FakeTokenStorage(),
    )..status = SessionStatus.unauthenticated;

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SessionController>.value(
          value: session,
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Benutzername'), findsOneWidget);
    expect(find.text('Passwort'), findsOneWidget);
    expect(find.text('Anmelden'), findsOneWidget);
  });
}
