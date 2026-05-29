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

## Open steps (implementation order)

| Step | File | Priority | Depends on |
|------|------|----------|------------|
| 4 | [step-04-ticket-list-api.md](./step-04-ticket-list-api.md) | P0 | Step 2, 3 |
| 5 | [step-05-ticket-detail-status.md](./step-05-ticket-detail-status.md) | P0 | Step 4 |
| 6 | [step-06-ticket-messages.md](./step-06-ticket-messages.md) | P0 | Step 5 |
| 7 | [step-07-agent-config-read.md](./step-07-agent-config-read.md) | P1 | Step 2, 3 |
| 8 | [step-08-analytics-summary.md](./step-08-analytics-summary.md) | P1 | Step 2, 3 |
| 9 | [step-09-mock-cleanup-tests.md](./step-09-mock-cleanup-tests.md) | P1 | Steps 4–8 |

Steps 7 and 8 can be parallelized after Step 3. Steps 4 → 5 → 6 must stay sequential.

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

1. Pick the next open step in order (unless explicitly parallelizing 7/8).
2. Implement only the **Scope**; respect **Out of Scope**.
3. Check off **Acceptance Criteria** before marking done in your commit/PR description.
4. Run **Validation Commands** and manual smoke where listed.
