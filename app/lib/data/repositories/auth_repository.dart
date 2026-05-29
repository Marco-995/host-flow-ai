import '../../core/network/api_client.dart';
import '../models/auth_models.dart';
import '../models/user_models.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      '/api/v1/auth/login',
      LoginRequest(username: username, password: password).toJson(),
      skipAuthRetry: true,
    );
    return TokenResponse.fromJson(json);
  }

  Future<TokenResponse> refresh({required String refreshToken}) async {
    final json = await _apiClient.postJson(
      '/api/v1/auth/refresh',
      RefreshRequest(refreshToken: refreshToken).toJson(),
      skipAuthRetry: true,
    );
    return TokenResponse.fromJson(json);
  }

  Future<void> logout({required String refreshToken}) async {
    await _apiClient.postVoid(
      '/api/v1/auth/logout',
      RefreshRequest(refreshToken: refreshToken).toJson(),
      authenticated: true,
      skipAuthRetry: true,
    );
  }

  Future<UserMeResponse> fetchMe() async {
    final json = await _apiClient.getJson(
      '/api/v1/users/me',
      authenticated: true,
    );
    return UserMeResponse.fromJson(json);
  }
}
