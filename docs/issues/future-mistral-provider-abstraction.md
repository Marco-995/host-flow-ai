# Future: Mistral / LLM Provider Abstraction

## Status

Open

## Priority

Future

## Context

HostFlow AI branding implies LLM-assisted workflows. cp-chatbot should own model calls server-side; the **Flutter app must not** embed API keys or call Mistral directly in the integration track (explicitly excluded in Steps 1–9).

## Goal

If the app ever needs LLM features (draft reply suggestions, on-device previews), introduce a **provider abstraction** that talks only to backend-orchestrated endpoints, never raw Mistral from the client.

## Scope

- Interface e.g. `LlmSuggestionService` with backend implementation only
- Optional staging flag via `--dart-define` for feature toggles
- Error mapping consistent with `ApiException`
- Documentation: secrets stay on server

## Out of Scope

- Mistral API keys in Flutter
- `dart:io` direct HTTPS to `api.mistral.ai`
- Step 4–9 ticket/message bodies calling LLM from client
- Replacing backend bot logic

## Backend Endpoints

Hypothetical examples (server-mediated):

- `POST /api/v1/.../suggest-reply`
- `POST /api/v1/.../summarize`

Confirm with cp-chatbot before implementation.

## RBAC

Follow permissions on each endpoint; default deny for staff unless product allows.

## Files Likely to Change

- `app/lib/core/llm/` or `app/lib/data/repositories/llm_repository.dart` (new, future)
- Ticket detail compose UI (optional consumer)

## Acceptance Criteria

- [ ] No Mistral (or other) provider secrets in repo or app bundle.
- [ ] All LLM traffic auditable via backend logs.
- [ ] Feature behind explicit product flag.

## Test Plan

- Mock backend responses only; no live LLM in CI.

## Validation Commands

```bash
cd app
flutter analyze
flutter test
```
