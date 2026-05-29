# App Backend Integration — Issue Tracker (Repo-local)

GitHub Issues are not used for this track. Each step is a Markdown file in this folder, structured like a GitHub issue.

**Branch track:** `feature/backend-api-integration-foundation`  
**Backend:** cp-chatbot `/api/v1`  
**Stack (unchanged):** `http`, `provider`, `flutter_secure_storage`, `--dart-define=API_BASE_URL`, manual JSON — no dio, riverpod, go_router.

## Completed steps

| Step | Title | Notes |
|------|--------|--------|
| 1 | App API Foundation | `ApiClient`, `ApiException`, `HealthRepository`, `AppConfig` |
| 2 | Auth Foundation | Login, refresh, logout, `SessionController`, secure tokens |
| 3 | RBAC Navigation | `AppNavItem`, `AppNavigation`, sidebar guard, `ForbiddenPlaceholder` |
| 4 | Support Tickets — Ticket List API | `TicketRepository`, `SupportTicketsScreen`, list states |
| 5 | Ticket Detail + Status Update | `TicketDetailScreen`, GET/PATCH ticket APIs |
| 6 | Ticket Messages | Message thread GET/POST on `TicketDetailScreen` |
| 7 | Agent Config Read | `AgentRepository`, knowledge list + bot config read-only UI |
| 8 | Analytics Summary | `AnalyticsRepository`, `BotStatisticsScreen` with 7/30/90 days |
| 9 | Mock Cleanup + Tests | Demo/API copy, README integration matrix, overview tests |

## Open steps (implementation order)

_None — v1 backend integration track (Steps 1–9) is complete on this branch. See **Future / backlog** below._

Steps 1 → 9 are complete. Next work is future/backlog issues (admin write, chat API, UI shell, etc.).

## Future / backlog

| File | Priority |
|------|----------|
| [future-backend-admin-write-apis.md](./future-backend-admin-write-apis.md) | Future |
| [future-chat-conversation-api.md](./future-chat-conversation-api.md) | Future |
| [future-mistral-provider-abstraction.md](./future-mistral-provider-abstraction.md) | Future |
| [future-ui-shell-cleanup.md](./future-ui-shell-cleanup.md) | Future |

## RBAC summary (navigation + API)

| Role | App areas (Step 3) | Ticket APIs | Analytics | Knowledge / Bot config |
|------|-------------------|-------------|-----------|-------------------------|
| **staff** | Übersicht, Buchungen, Gäste, E-Mails, Website Bot → Tickets / Support | read/write (if `tickets_*` on `/users/me`) | no | no |
| **super** | All demo areas + bot subs + settings | read/write | read (`analytics_read`) | read (`knowledge_read`, `bot_config_read`) |

Client-side RBAC must stay aligned with backend permission flags from `GET /api/v1/users/me`.

## Validation (every step)

```bash
cd app
flutter analyze
flutter test
```

## How to use these issues

1. Pick the next item from **Future / backlog** (integration Steps 1–9 are done).
2. Implement only the **Scope**; respect **Out of Scope**.
3. Check off **Acceptance Criteria** before marking done in your commit/PR description.
4. Run **Validation Commands** and manual smoke where listed.
