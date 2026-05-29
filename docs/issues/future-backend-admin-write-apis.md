# Future: Backend Admin Write APIs (Knowledge + Bot Config)

## Status

Open

## Priority

Future

## Context

Steps 7–8 cover **read-only** bot config and knowledge documents for super users. Product and ops will eventually need create/update/delete flows (upload PDF, sync website, edit bot prompts). These endpoints are **not** in the current v1 integration track.

## Goal

When cp-chatbot exposes stable write/admin endpoints, integrate them in the Flutter app with proper RBAC, validation, and audit-friendly UX.

## Scope

- TBD per backend OpenAPI (e.g. POST/PATCH/DELETE knowledge documents, PUT bot-config)
- Super-only or fine-grained `knowledge_write` / `bot_config_write` from `/users/me`
- Optimistic UI vs save-and-refresh
- File upload if backend supports multipart

## Out of Scope

- Until backend ships: no client implementation in Steps 4–9
- Mistral keys in the app
- Ticket admin beyond existing PATCH/messages v1

## Backend Endpoints

Not available in current v1 list. Placeholder categories:

- Knowledge document CRUD / sync triggers
- Bot configuration update
- Possible admin-only namespaces under `/api/v1/…`

## RBAC

| Role | Expected |
|------|----------|
| **staff** | Read-only or no access per product |
| **super** | Write where `knowledge_write` / `bot_config_write` true |

## Files Likely to Change

- `app/lib/data/repositories/knowledge_repository.dart`
- `app/lib/data/repositories/bot_config_repository.dart`
- `app/lib/features/chatbot/view/knowledge_base_screen.dart`
- `app/lib/features/chatbot/view/chatbot_screen.dart`
- `app/lib/core/network/api_client.dart` (upload helpers if needed)

## Acceptance Criteria

- [ ] Blocked until backend contract is published and reviewed.
- [ ] Issue updated with concrete endpoints and payloads before implementation starts.

## Test Plan

- Contract tests from sample JSON fixtures per endpoint.
- Permission matrix tests (write denied for staff).

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```
