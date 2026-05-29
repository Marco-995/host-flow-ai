import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:8000';

  group('AuthRepository', () {
    test('login returns TokenResponse', () async {
      final client = ApiClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/v1/auth/login');
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['username'], 'alice');
          return http.Response(
            jsonEncode({
              'access_token': 'at_new',
              'refresh_token': 'rt_new',
              'token_type': 'bearer',
            }),
            200,
          );
        }),
        baseUrl: baseUrl,
      );
      addTearDown(client.close);

      final repo = AuthRepository(apiClient: client);
      final tokens = await repo.login(username: 'alice', password: 'pw');
      expect(tokens.accessToken, 'at_new');
    });

    test('fetchMe sends Authorization header when token set', () async {
      final client = ApiClient(
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer at_test');
          return http.Response(
            jsonEncode({
              'id': 'staff:alice',
              'username': 'alice',
              'role': 'staff',
              'permissions': {
                'tickets_read': true,
                'tickets_write': true,
                'analytics_read': false,
                'knowledge_read': false,
                'knowledge_write': false,
                'bot_config_read': false,
                'bot_config_write': false,
              },
            }),
            200,
          );
        }),
        baseUrl: baseUrl,
      )..getAccessToken = () => 'at_test';
      addTearDown(client.close);

      final user = await AuthRepository(apiClient: client).fetchMe();
      expect(user.username, 'alice');
    });

    test('logout accepts 204', () async {
      final client = ApiClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/v1/auth/logout');
          return http.Response('', 204);
        }),
        baseUrl: baseUrl,
      )..getAccessToken = () => 'at_test';
      addTearDown(client.close);

      await AuthRepository(apiClient: client).logout(refreshToken: 'rt_x');
    });

    test('login 401 throws ApiException', () async {
      final client = ApiClient(
        httpClient: MockClient((_) async {
          return http.Response(
            jsonEncode({'code': 'INVALID_CREDENTIALS', 'message': 'Bad login'}),
            401,
          );
        }),
        baseUrl: baseUrl,
      );
      addTearDown(client.close);

      expect(
        () => AuthRepository(apiClient: client).login(
          username: 'x',
          password: 'y',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
