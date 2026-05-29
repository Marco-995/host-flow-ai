/// Request/response models for /api/v1/auth.
class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class RefreshRequest {
  const RefreshRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {
        'refresh_token': refreshToken,
      };
}

class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}
