# Future: UI Shell Cleanup (Sidebar, TopBar, Layout)

## Status

Open

## Priority

Future

## Context

Step 3 intentionally avoided large layout changes. `AppSidebar` and `TopBar` have known test-time issues (ListTile ink warnings, overflow in small viewports). Demo dashboard shell is desktop-oriented and not mobile-responsive.

## Goal

Improve shell UX and test stability without changing RBAC rules or API integration behavior.

## Scope

- Wrap ListTiles in `Material` or refactor selection highlight to fix ink splash warnings
- Sidebar: scrollable nav for small heights; fix header row overflow
- TopBar: responsive truncation for username/role + title
- Optional: split shell into smaller widgets for testing
- Reduce `takeException()` workarounds in sidebar tests

## Out of Scope

- RBAC product rules (staff vs super visibility)
- go_router migration
- Full responsive/mobile redesign
- Feature screen content (tickets, analytics data)
- Backend work

## Backend Endpoints

None.

## RBAC

No changes to `AppNavigation` rules — layout only.

## Files Likely to Change

- `app/lib/core/widgets/app_sidebar.dart`
- `app/lib/core/widgets/top_bar.dart`
- `app/lib/features/dashboard/view/dashboard_screen.dart`
- `app/test/core/widgets/app_sidebar_rbac_test.dart`
- Optional: `app/test/widget_test.dart` (safe dashboard smoke if layout fixed)

## Acceptance Criteria

- [ ] `flutter test` passes without absorbing framework exceptions in sidebar tests (or fewer).
- [ ] Manual: 260px sidebar at 720p+ height — no yellow overflow stripes.
- [ ] Staff/super menu items unchanged in visibility and labels.
- [ ] Logout and title bar still functional.

## Test Plan

- Widget tests at realistic viewport (400×900, 1280×800).
- Optional golden snapshots for sidebar (if team adopts goldens).

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```
