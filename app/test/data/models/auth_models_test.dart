import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/data/models/auth_models.dart';

void main() {
  test('LoginRequest toJson', () {
    const request = LoginRequest(username: 'staff1', password: 'secret');
    expect(request.toJson(), {
      'username': 'staff1',
      'password': 'secret',
    });
  });

  test('RefreshRequest toJson uses snake_case', () {
    const request = RefreshRequest(refreshToken: 'rt_abc');
    expect(request.toJson(), {'refresh_token': 'rt_abc'});
  });

  test('TokenResponse fromJson', () {
    final token = TokenResponse.fromJson({
      'access_token': 'at_1',
      'refresh_token': 'rt_1',
      'token_type': 'bearer',
    });
    expect(token.accessToken, 'at_1');
    expect(token.refreshToken, 'rt_1');
    expect(token.tokenType, 'bearer');
  });
}
