# Step 8: Analytics Summary

## Status

Resolved

## Resolved In

- Commit: `2b5ca6b`
- Notes: Analytics summary on `BotStatisticsScreen` via `AnalyticsRepository` and days selector 7/30/90.

## Priority

P1

## Context

`BotStatisticsScreen` is a placeholder. Super users with `analytics_read` see **Statistiken** under Website Bot. Backend provides aggregated metrics at `GET /api/v1/analytics/summary`.

## Goal

Fetch and display analytics summary for authorized users on `BotStatisticsScreen` (cards or simple metrics layout), with loading/error states aligned with API response shape.

## Scope

- `AnalyticsSummary` (or similar) model + `AnalyticsRepository`
- `GET /api/v1/analytics/summary` via authenticated client
- Update `BotStatisticsScreen` to render API fields (counts, rates, period — per backend contract)
- Gate fetch on `permissions.analytics_read` / super role
- Reuse existing RBAC navigation (staff do not see Statistiken)

## Out of Scope

- Charts library additions (use simple text/cards unless already in project)
- Historical drill-down, export, dashboards
- Ticket or message analytics beyond summary endpoint
- Knowledge/bot config (Step 7)
- Backend aggregation changes

## Backend Endpoints

- `GET /api/v1/analytics/summary`
- `GET /api/v1/users/me`

## RBAC

| Role | Analytics summary |
|------|-------------------|
| **staff** | No — nav item hidden |
| **super** | Yes with `analytics_read` |

## Files Likely to Change

- `app/lib/data/models/analytics_models.dart` (new)
- `app/lib/data/repositories/analytics_repository.dart` (new)
- `app/lib/features/chatbot/view/bot_statistics_screen.dart`
- `app/lib/main.dart`
- `app/test/data/models/analytics_models_test.dart`
- `app/test/data/repositories/analytics_repository_test.dart`

## Acceptance Criteria

- [ ] Super with `analytics_read`: Statistiken screen shows live summary data.
- [ ] Staff: no Statistiken in sidebar; no analytics API calls from app flows.
- [ ] 403/401 handled with user-visible error.
- [ ] Loading state while fetching.
- [ ] No new charting dependencies required for MVP.

## Test Plan

- Unit: summary JSON parsing (including null-safe optional metrics).
- Unit: repository success + error paths.
- Optional widget: screen shows metric labels from fixture JSON.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```

### Manual smoke

- Compare screen values with `curl -H "Authorization: Bearer …" …/analytics/summary`.
- Toggle super user without `analytics_read` (if available) → UI respects permission.
