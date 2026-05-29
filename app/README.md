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

## Support tickets (Step 4)

With cp-chatbot running and a user that has ticket permissions:

1. Login as **staff** or **super**.
2. Open **Website Bot → Tickets / Support**.
3. The app loads `GET /api/v1/tickets` (list, empty, or error with retry).
4. Tap a ticket to open the detail screen (Step 5).

## Support ticket detail (Step 5)

1. From the ticket list, tap a ticket — opens `TicketDetailScreen` with data from `GET /api/v1/tickets/{id}`.
2. Change status via dropdown or action chip (requires `tickets_write`; `PATCH /api/v1/tickets/{id}`).
3. Use back to return; the list reloads if the status changed.

## Support ticket messages (Step 6)

On `TicketDetailScreen` (after Step 5):

1. Message thread loads from `GET /api/v1/tickets/{id}/messages` (independent of detail load errors in the messages section only).
2. Legacy snapshot lines and staff messages appear in **Nachrichtenverlauf**.
3. With `tickets_write`, use the reply composer: **Sichtbar für Gast** (`external`) or **Interne Notiz** (`internal`); sends `POST /api/v1/tickets/{id}/messages`.
4. On success the composer clears and the new message appears in the list (no full-screen reload).

## Agent config read (Step 7)

Super only (sidebar + backend):

1. **Wissensdatenbank** loads `GET /api/v1/knowledge/documents` and shows each document as a list row with filename and content preview (no full-text or expand view in Step 7).
2. **Website Bot Übersicht** loads `GET /api/v1/bot-config/` (welcome message + system prompt, read-only).
3. Mock chat simulator uses API welcome message when config loads; replies stay mock (no chat API).
4. Sync, upload, ingest, and RAG test controls are disabled or show **Demnächst verfügbar (nur Lesezugriff in v1).**
5. Staff do not see knowledge or website bot overview in navigation.

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
