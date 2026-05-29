import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/session/session_controller.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:host_flow/features/auth/view/auth_gate.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import '../../core/storage/fake_token_storage.dart';

class _TestSession extends SessionController {
  _TestSession(SessionStatus initialStatus)
      : super(
          authRepository: AuthRepository(
            apiClient: ApiClient(
              httpClient: MockClient((_) async => http.Response('{}', 200)),
              baseUrl: 'http://127.0.0.1:8000',
            ),
          ),
          tokenStorage: FakeTokenStorage(),
        ) {
    status = initialStatus;
  }

  @override
  Future<void> bootstrap() async {}
}

SessionController fakeSession(SessionStatus initialStatus) =>
    _TestSession(initialStatus);

void main() {
  Widget buildTestApp(SessionStatus status) {
    final session = fakeSession(status);
    return MaterialApp(
      home: ChangeNotifierProvider<SessionController>.value(
        value: session,
        child: AuthGate(
          authenticatedChild: const SizedBox(key: Key('authenticated_stub')),
        ),
      ),
    );
  }

  testWidgets('unauthenticated shows login', (tester) async {
    await tester.pumpWidget(
      buildTestApp(SessionStatus.unauthenticated),
    );

    expect(find.text('Anmelden'), findsOneWidget);
    expect(find.text('HostFlow Anmeldung'), findsOneWidget);
  });

  testWidgets('authenticated shows stub child not dashboard', (tester) async {
    await tester.pumpWidget(
      buildTestApp(SessionStatus.authenticated),
    );

    expect(find.byKey(const Key('authenticated_stub')), findsOneWidget);
    expect(find.text('HostFlow'), findsNothing);
  });

  testWidgets('bootstrapping shows loading', (tester) async {
    await tester.pumpWidget(
      buildTestApp(SessionStatus.bootstrapping),
    );

    expect(find.text('Wird geladen…'), findsOneWidget);
  });
}
