import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/session/session_controller.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../storage/fake_token_storage.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:8000';

  Map<String, dynamic> meJson(String role) => {
        'id': '$role:user',
        'username': 'user',
        'role': role,
        'permissions': {
          'tickets_read': true,
          'tickets_write': true,
          'analytics_read': role == 'super',
          'knowledge_read': role == 'super',
          'knowledge_write': false,
          'bot_config_read': role == 'super',
          'bot_config_write': false,
        },
      };

  SessionController buildSession({
    required MockClient mockClient,
    FakeTokenStorage? storage,
  }) {
    final client = ApiClient(httpClient: mockClient, baseUrl: baseUrl);
    final session = SessionController(
      authRepository: AuthRepository(apiClient: client),
      tokenStorage: storage ?? FakeTokenStorage(),
    );
    client.getAccessToken = () => session.accessToken;
    client.onUnauthorized = () => session.refreshSession();
    return session;
  }

  test('bootstrap without tokens becomes unauthenticated', () async {
    final session = buildSession(
      mockClient: MockClient((_) async => throw UnimplementedError()),
    );

    await session.bootstrap();
    expect(session.status, SessionStatus.unauthenticated);
    expect(session.accessToken, isNull);
  });

  test('login saves tokens and loads user', () async {
    final storage = FakeTokenStorage();
    final session = buildSession(
      storage: storage,
      mockClient: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return http.Response(
            jsonEncode({
              'access_token': 'at',
              'refresh_token': 'rt',
            }),
            200,
          );
        }
        if (request.url.path == '/api/v1/users/me') {
          return http.Response(jsonEncode(meJson('staff')), 200);
        }
        throw UnimplementedError(request.url.path);
      }),
    );

    await session.login(username: 'staff', password: 'pw');
    expect(session.status, SessionStatus.authenticated);
    expect(session.currentUser?.role, 'staff');
    expect(storage.accessToken, 'at');
  });

  test('logout clears tokens', () async {
    final storage = FakeTokenStorage()
      ..accessToken = 'at'
      ..refreshToken = 'rt';
    final session = buildSession(
      storage: storage,
      mockClient: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/logout') {
          return http.Response('', 204);
        }
        throw UnimplementedError();
      }),
    );
    session.accessToken = 'at';
    session.refreshToken = 'rt';
    session.status = SessionStatus.authenticated;

    await session.logout();
    expect(session.status, SessionStatus.unauthenticated);
    expect(storage.accessToken, isNull);
  });

  test('refresh failure clears session', () async {
    final storage = FakeTokenStorage()..refreshToken = 'rt_bad';
    final session = buildSession(
      storage: storage,
      mockClient: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/refresh') {
          return http.Response(
            jsonEncode({'code': 'INVALID_TOKEN', 'message': 'bad'}),
            401,
          );
        }
        throw UnimplementedError();
      }),
    );

    final ok = await session.refreshSession();
    expect(ok, isFalse);
    expect(session.status, SessionStatus.unauthenticated);
  });
}
