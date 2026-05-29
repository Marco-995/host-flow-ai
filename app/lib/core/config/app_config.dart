/// Runtime configuration for API connectivity (via --dart-define).
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const Duration requestTimeout = Duration(seconds: 15);

  /// Returns [apiBaseUrl] without a trailing slash, or throws if unset.
  static String requireApiBaseUrl() {
    final trimmed = apiBaseUrl.trim();
    if (trimmed.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Pass --dart-define=API_BASE_URL=<url> when running or building.\n'
        'Examples:\n'
        '  Android emulator: http://10.0.2.2:8000\n'
        '  iOS simulator:    http://127.0.0.1:8000\n'
        '  Physical device:  http://<LAN-IP>:8000\n'
        '  Production:       https://your-api-host',
      );
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
