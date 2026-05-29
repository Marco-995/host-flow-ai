# Step 9: Mock Cleanup + Integration Test Hardening

## Status

Resolved

## Resolved In

- Commit: `2f9cfe0`
- Notes: Demo vs API-backed copy cleanup, README integration matrix and smoke, overview/email labeling, widget tests.

## Priority

P1

## Context

After Steps 4–8, ticket/bot/analytics paths use real APIs. Demo PMS areas (Buchungen, Gäste, E-Mails, Rezensionen, Concierge, Unterkünfte, Abrechnung) may still contain prototype mocks and misleading copy implying live data.

## Goal

Clearly separate **API-integrated** features from **demo-only** prototypes, remove dead mock code where replaced, and harden tests/documentation so CI and onboarding reflect the true integration state.

## Scope

- Audit screens not wired to v1 API; label as demo/placeholder in UI where they remain mock-only
- Remove unused mock data structures superseded by repositories (e.g. knowledge hardcoded `_sources` after Step 7)
- Ensure `email_ticket.dart` is not confused with support tickets (rename docs/comments only if needed — avoid large renames unless necessary)
- README / `docs/issues/README.md` integration status table update
- Test coverage gaps: ticket + analytics + knowledge happy paths
- Keep `widget_test` construction-only if full dashboard pump still unstable
- Document manual smoke checklist for full v1 flow (auth → RBAC → tickets → super analytics)

## Out of Scope

- Implementing PMS/booking/email/review backends (no endpoints in v1 list)
- Chat, Mistral, admin write APIs (future issues)
- Sidebar layout overhaul (future UI shell)
- Backend changes
- New navigation features

## Backend Endpoints

None new — validates integration of:

- Auth + `/users/me`
- Tickets (list, detail, patch, messages)
- `/analytics/summary`
- `/bot-config/`, `/knowledge/documents`

## RBAC

Regression pass: staff vs super menus and guards unchanged from Step 3; integrated screens respect permissions after cleanup.

## Files Likely to Change

- Demo feature screens under `app/lib/features/**` (bookings, guests, email, reviews, concierge, accommodations, billing)
- `app/lib/features/overview/view/overview_screen.dart` (copy/cards honesty)
- `app/README.md`
- `docs/issues/README.md` (mark steps 4–8 done)
- Various `app/test/**` consolidation

## Acceptance Criteria

- [ ] No screen integrated in Steps 4–8 still shows old hardcoded data as if live.
- [ ] Demo-only screens show explicit “Demo” / placeholder messaging (or equivalent).
- [ ] `flutter test` green; no flaky full-dashboard pump introduced.
- [ ] `flutter analyze` — only known pre-existing infos or fewer.
- [ ] README lists which areas are API-backed vs prototype.
- [ ] Support ticket domain clearly distinct from email automation mocks.

## Test Plan

- Run full suite; add missing repository tests if Steps 4–8 skipped any.
- Optional golden/widget tests only where stable (ticket list item, analytics card).
- Manual end-to-end script documented in README or this issue’s smoke section.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```

### Manual smoke (full v1)

1. Login staff → tickets list/detail/messages (if permissions).
2. Logout → login super → knowledge, bot config, analytics.
3. Verify demo areas do not imply false API connectivity.
4. Hot restart / re-login session stable.
