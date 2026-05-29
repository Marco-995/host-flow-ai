# Future: Chat / Conversation API (Website Bot Live)

## Status

Open

## Priority

Future

## Context

The app has **Website Bot** navigation and overview placeholders. v1 backend integration focuses on **support tickets** (escalations), not embedded website visitor chat sessions. A separate conversation/stream API may exist later on cp-chatbot or another service.

## Goal

Define and integrate live or historical website bot conversations in the dashboard (super/staff visibility TBD), without coupling to the ticket message model.

## Scope

- Conversation list + message stream endpoints (TBD)
- UI distinct from `SupportTicketsScreen` / ticket messages (Step 6)
- Session identity, channel (web widget), handoff to ticket
- Pagination and search

## Out of Scope

- Steps 4–9 ticket implementation
- In-app Mistral calls (see `future-mistral-provider-abstraction.md`)
- Replacing ticket APIs with chat APIs
- go_router deep links

## Backend Endpoints

Not in current v1 list. Examples to confirm with backend team:

- `GET /api/v1/conversations/…` (hypothetical)
- WebSocket/SSE (hypothetical)

## RBAC

| Role | TBD with product |
|------|------------------|
| **staff** | Possibly read-only transcript for support context |
| **super** | Full visibility |

Align with Step 3 nav: staff currently has no Website Bot overview — only Tickets / Support.

## Files Likely to Change

- New feature module under `app/lib/features/chatbot/` or `conversations/`
- `app/lib/core/navigation/app_navigation.dart` (new `AppNavItem`s if needed)
- `app/lib/features/chatbot/view/chatbot_screen.dart`

## Acceptance Criteria

- [ ] Product spec + backend OpenAPI agreed before coding.
- [ ] No regression to ticket flows or RBAC guards.

## Test Plan

- Repository tests with recorded fixtures.
- Manual smoke with staging widget/snippet URL.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```
