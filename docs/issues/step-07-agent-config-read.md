# Step 7: Agent Config Read (Bot Config + Knowledge Documents)

## Status

Resolved

## Resolved In

- Commit: `69acdfa`
- Notes: Super read-only bot config and knowledge documents via `AgentRepository` and `ApiClient.getJsonList`.

## Priority

P1

## Context

Super users see **Website Bot** sub-items including bot overview, **Wissensdatenbank**, and related areas. `KnowledgeBaseScreen` and `WebsiteBotScreen` / config UIs still use in-memory mocks. Backend exposes read-only config and knowledge document listing.

## Goal

For **super** (and users with `bot_config_read` / `knowledge_read`), load and display read-only data from bot config and knowledge document endpoints. Staff must not gain access via UI or API calls from these screens.

## Scope

- DTOs + `BotConfigRepository` (or split repos) for:
  - `GET /api/v1/bot-config/`
  - `GET /api/v1/knowledge/documents`
- Replace mock lists in `KnowledgeBaseScreen` with API-driven list (loading/error/empty)
- Bot overview / config screen: show fields returned by bot-config endpoint (read-only)
- Use `SessionController.currentUser` / `AppNavigation.canAccess` before fetching
- Super-only navigation already enforced in Step 3 — do not widen staff menu

## Out of Scope

- Creating/updating/deleting documents or bot config (future admin write APIs)
- RAG ingestion, crawl triggers, Mistral
- Ticket flows (Steps 4–6)
- Analytics (Step 8)
- `withOpacity` layout cleanup (future UI shell)
- Backend changes

## Backend Endpoints

- `GET /api/v1/bot-config/`
- `GET /api/v1/knowledge/documents`
- `GET /api/v1/users/me` (permission flags)

## RBAC

| Role | Bot config read | Knowledge documents read |
|------|-----------------|---------------------------|
| **staff** | No — screens hidden | No |
| **super** | Yes (`bot_config_read`) | Yes (`knowledge_read`) |

403 from API must show forbidden/error state, not crash.

## Files Likely to Change

- `app/lib/data/models/bot_config_models.dart` (new)
- `app/lib/data/models/knowledge_models.dart` (new)
- `app/lib/data/repositories/bot_config_repository.dart` (new)
- `app/lib/data/repositories/knowledge_repository.dart` (new)
- `app/lib/features/chatbot/view/knowledge_base_screen.dart`
- `app/lib/features/chatbot/view/chatbot_screen.dart` (website bot overview)
- `app/lib/main.dart` (providers)
- `app/test/data/repositories/*_test.dart`

## Acceptance Criteria

- [ ] Super login: knowledge screen lists documents from API.
- [ ] Super login: bot config screen shows API data (read-only).
- [ ] Staff cannot open these screens via sidebar (unchanged Step 3).
- [ ] If staff somehow lands on route, guard or empty + no successful fetch.
- [ ] Loading and error states implemented.
- [ ] No new dependencies; uses existing `ApiClient`.

## Test Plan

- Unit: parse bot-config and knowledge list responses.
- Unit: repositories with mock HTTP 200/403.
- Optional widget: knowledge screen with injected repo mock.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```

### Manual smoke

- Super → Wissensdatenbank → data matches `curl` to knowledge endpoint.
- Super → Website Bot overview/config → matches bot-config endpoint.
- Staff → menu items absent; direct guard still safe.
