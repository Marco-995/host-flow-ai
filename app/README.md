# host_flow

Flutter app for HostFlow AI (mobile client for cp-chatbot `/api/v1`).

## Getting Started

Standard Flutter setup: [Flutter documentation](https://docs.flutter.dev/).

```bash
cd app
flutter pub get
flutter run
```

## Local API configuration

The API base URL is **required** for network calls. Pass it via `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

| Target | Example `API_BASE_URL` |
|--------|-------------------------|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator | `http://127.0.0.1:8000` |
| Physical device (same LAN as backend) | `http://192.168.x.x:8000` |
| Production | `https://your-api-host` |

- No trailing slash needed; the client normalizes the base URL.
- **Android:** `INTERNET` and cleartext HTTP are enabled for local development. Use HTTPS in production.
- **iOS:** For HTTP to localhost, you may need App Transport Security exceptions in debug builds.
- **Flutter Web:** Requires CORS on the backend; not the primary target for v1.

### Health check (manual)

With cp-chatbot running:

```bash
curl http://127.0.0.1:8000/api/v1/health
# {"status":"ok","version":"v1"}
```

From Dart (after Step 1 foundation):

```dart
final health = await HealthRepository(
  apiClient: ApiClient(baseUrl: 'http://10.0.2.2:8000'),
).checkHealth();
```

## Validation

```bash
cd app
flutter pub get
flutter analyze
flutter test
```
