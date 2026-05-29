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

## RBAC navigation (Step 3)

After login, menu visibility depends on role and permissions from `GET /api/v1/users/me`:

| Role | Visible areas |
|------|----------------|
| **staff** | Übersicht, Buchungen, Gäste, E-Mails, Website Bot → Tickets / Support |
| **super** | All menu items (demo PMS, bot, analytics, settings) |

Staff cannot open super-only screens; the app shows **Keine Berechtigung für diesen Bereich** if access is denied.

Manual smoke:

- Login as staff → verify limited sidebar; open Tickets under Website Bot.
- Login as super → verify full sidebar.
- Logout and session restart behave as in Step 2.

## Authentication (Step 2)

The app shows a login screen before the dashboard. Tokens are stored with `flutter_secure_storage` (not passwords).

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

1. Enter staff or super credentials from your cp-chatbot deployment.
2. After login, the dashboard opens; use the logout icon in the top bar (tooltip: **Abmelden**).
3. `GET /api/v1/users/me` loads role and permissions (RBAC navigation filtering is Step 3).

Manual smoke:

- Login as **staff** → dashboard, no server errors on `/users/me`.
- Logout → login screen again.
- Login as **super** → dashboard; permissions include analytics/knowledge/bot config flags on `/users/me`.

## Validation

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

Existing `withOpacity` analyzer infos in `knowledge_base_screen.dart` are pre-existing and non-blocking.
