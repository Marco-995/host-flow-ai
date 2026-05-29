# Step 6: Ticket Messages

## Status

Open

## Priority

P0

## Context

Step 5 delivers ticket detail and status. Support workflows need the conversation thread: list messages and post staff replies.

## Goal

On ticket detail, load messages via `GET /api/v1/tickets/{id}/messages` and send new messages via `POST /api/v1/tickets/{id}/messages`, with appropriate RBAC and UX (loading, send disabled while posting, errors).

## Scope

- Message DTO(s) and repository methods for GET + POST messages
- UI: scrollable message list (author, body, timestamp per API)
- Compose field + send action on detail screen
- Append new message to list or refetch after POST
- Handle empty thread and send failures
- Content types / roles as returned by API (user vs agent vs staff — map labels only)

## Out of Scope

- Real-time / WebSocket updates
- Rich text, attachments, typing indicators
- Chat widget / website bot live chat (future chat API)
- Mistral or LLM calls from the app
- Editing or deleting messages (unless backend adds endpoints later)
- Ticket list/detail rework beyond message section

## Backend Endpoints

- `GET /api/v1/tickets/{id}/messages`
- `POST /api/v1/tickets/{id}/messages`
- `GET /api/v1/tickets/{id}` (detail context)

## RBAC

| Role | Read messages | Post message |
|------|---------------|--------------|
| **staff** | `tickets_read` | `tickets_write` |
| **super** | Yes | Yes |

Hide compose UI when write permission is false.

## Files Likely to Change

- `app/lib/data/models/ticket_models.dart` (message types)
- `app/lib/data/repositories/ticket_repository.dart`
- `app/lib/features/chatbot/view/ticket_detail_screen.dart`
- `app/test/data/models/ticket_models_test.dart`
- `app/test/data/repositories/ticket_repository_test.dart`

## Acceptance Criteria

- [ ] Opening a ticket loads and displays the message history.
- [ ] Sending a message POSTs to API and appears in the UI without app restart.
- [ ] Send button disabled while request in flight; errors shown to user.
- [ ] Read-only users see history but cannot compose.
- [ ] No message API calls when user lacks `tickets_read` on that ticket path.
- [ ] Existing ticket list/detail/status flows still work.

## Test Plan

- Unit: message list + single message JSON parse.
- Unit: POST message — body shape, 201/200 handling, error envelope.
- Widget: thread renders N messages; send triggers repo (mock).

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```

### Manual smoke

- Staff: reply on open ticket → visible after reload and immediately if refetch implemented.
- Backend validation error → user-visible message.
- Logout mid-screen → safe return to login (no orphan timers).
