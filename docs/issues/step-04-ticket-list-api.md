# Step 4: Support Tickets — Ticket List API

## Status

Open

## Priority

P0

## Context

Steps 1–3 delivered API foundation, auth/session, and RBAC navigation. `SupportTicketsScreen` is still a static placeholder. Staff and super can open **Tickets / Support** in the sidebar, but no ticket data is loaded from cp-chatbot.

## Goal

Load and display a real ticket list from `GET /api/v1/tickets/` using the authenticated `ApiClient`, with loading/error/empty states and RBAC-safe access for staff and super.

## Scope

- Ticket list DTO(s) and `TicketRepository` (or equivalent) for `GET /api/v1/tickets/`
- Wire repository through existing `SessionController` / `main.dart` provider pattern (same as auth)
- Replace placeholder UI in `SupportTicketsScreen` with a list (status, subject/title, updated time — per API shape)
- Query params only if required by backend v1 (e.g. pagination defaults documented in implementation)
- Handle `ApiException` (flat error envelope) with user-visible message
- Respect `AppNavigation.canAccess(AppNavItem.supportTickets, user)` — screen already gated by dashboard

## Out of Scope

- Ticket detail view (Step 5)
- PATCH status update (Step 5)
- Messages read/write (Step 6)
- Analytics, knowledge, bot config (Steps 7–8)
- Mock cleanup of unrelated PMS screens (Step 9)
- Chat / Mistral
- Backend changes
- go_router, dio, riverpod
- Sidebar or RBAC rule changes beyond using existing `tickets_read`

## Backend Endpoints

- `GET /api/v1/tickets/` (authenticated)
- `GET /api/v1/users/me` (already used — permissions for tickets)

## RBAC

| Role | List tickets |
|------|----------------|
| **staff** | Yes, if `permissions.tickets_read` (and write not required for list) |
| **super** | Yes (all ticket permissions via super role) |

If `tickets_read` is false, user should not see Tickets in sidebar (Step 3); no new nav rules in this step.

## Files Likely to Change

- `app/lib/data/models/ticket_models.dart` (new)
- `app/lib/data/repositories/ticket_repository.dart` (new)
- `app/lib/features/chatbot/view/support_tickets_screen.dart`
- `app/lib/main.dart` (register repository/provider if needed)
- `app/test/data/models/ticket_models_test.dart` (new)
- `app/test/data/repositories/ticket_repository_test.dart` (new)
- Optional: `app/test/features/chatbot/support_tickets_screen_test.dart` (widget test with mocked repo)

## Acceptance Criteria

- [ ] After staff/super login with `tickets_read`, opening **Tickets / Support** loads data from the API (not hardcoded mocks).
- [ ] Loading indicator shown while request is in flight.
- [ ] Empty list shows a clear empty state (no crash).
- [ ] API error shows message from `ApiException` (or fallback), no silent failure.
- [ ] Requests use Bearer token via existing `ApiClient` auth callbacks.
- [ ] No regression: auth gate, RBAC sidebar, logout, existing tests pass.

## Test Plan

- Unit: JSON parsing for ticket list response (happy path + missing optional fields).
- Unit: `TicketRepository` with `MockClient` — 200 list, 401/403 error mapping.
- Widget (optional): screen shows list rows when repo returns data; shows error text on failure.
- Do not pump full `DashboardScreen` shell if layout asserts fail — test screen or repo in isolation.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```

### Manual smoke

- `flutter run --dart-define=API_BASE_URL=...`
- Login as **staff** with tickets permission → open Tickets / Support → list matches backend.
- Login as **super** → same.
- Stop backend → error state visible, app stable.
