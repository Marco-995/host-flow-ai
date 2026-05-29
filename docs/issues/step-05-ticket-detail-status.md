# Step 5: Ticket Detail + Status Update

## Status

Resolved

## Resolved In

- Commit: `bdda779`
- Notes: Added TicketDetailScreen with GET/PATCH support and status updates.

## Priority

P0

## Context

Step 4 provides the ticket list. Users need a detail view and the ability to update ticket status (e.g. open → in progress → resolved) per backend v1.

## Goal

Navigate from list to detail, load `GET /api/v1/tickets/{id}`, display core fields, and allow status changes via `PATCH /api/v1/tickets/{id}` for users with ticket write permission.

## Scope

- Detail DTO and repository methods: `getTicket(id)`, `patchTicket(id, body)`
- Extend `ApiClient` with `patchJson` (or equivalent) if not present
- Detail screen/route within existing dashboard body (no go_router): e.g. push state or nested view from list selection
- Status control UI (dropdown/chips) mapped to backend enum/string values
- Optimistic or refresh-after-save pattern (keep simple)
- Error handling for 404/403/validation errors
- List refresh or local state update after successful PATCH

## Out of Scope

- Message thread (Step 6)
- Creating new tickets (unless backend adds POST later — see future admin APIs)
- Assignee management, tags, attachments
- Analytics, knowledge, bot config
- Email-ticket model (`email_ticket.dart`) — separate domain
- Backend schema changes

## Backend Endpoints

- `GET /api/v1/tickets/{id}`
- `PATCH /api/v1/tickets/{id}`
- `GET /api/v1/tickets/` (list refresh)

## RBAC

| Role | View detail | Update status |
|------|-------------|---------------|
| **staff** | Yes with `tickets_read` | Yes with `tickets_write` |
| **super** | Yes | Yes |

UI must disable or hide status edit when `tickets_write` is false (read-only detail).

## Files Likely to Change

- `app/lib/core/network/api_client.dart` (PATCH support)
- `app/lib/data/models/ticket_models.dart`
- `app/lib/data/repositories/ticket_repository.dart`
- `app/lib/features/chatbot/view/support_tickets_screen.dart` (navigation to detail)
- `app/lib/features/chatbot/view/ticket_detail_screen.dart` (new)
- `app/test/core/network/api_client_test.dart` (PATCH tests)
- `app/test/data/repositories/ticket_repository_test.dart`

## Acceptance Criteria

- [ ] Tapping a list item opens detail with data from `GET /api/v1/tickets/{id}`.
- [ ] Invalid id / 404 shows error, no crash.
- [ ] Status change calls `PATCH` with correct payload; UI reflects success.
- [ ] Read-only users see detail but cannot change status.
- [ ] Back navigation returns to list; list reflects updated status.
- [ ] Auth token and 401 retry behavior unchanged.

## Test Plan

- Unit: detail JSON parse; PATCH request body serialization.
- Unit: repository PATCH success and error paths.
- Widget: detail shows fields; status control disabled when `tickets_write: false`.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```

### Manual smoke

- Staff with read+write: open ticket → change status → verify on backend/reload.
- Staff read-only (if test user exists): detail visible, edit disabled.
- Super: full flow works.
