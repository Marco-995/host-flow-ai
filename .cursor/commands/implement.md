Implement the requested change carefully.

Use this command after a plan has been created and approved.

Steps:

1. Read the approved plan from this chat.
2. Inspect relevant files and call sites before editing.
3. Confirm the intended behavior from the approved plan.
4. Implement only the approved scope.
5. Make focused changes only.
6. Follow existing project patterns.
7. Add or update tests where applicable.
8. Run relevant validation commands if available.
9. Summarize:
   - changed files,
   - important decisions,
   - validation results,
   - remaining risks.

Rules:

- Keep the diff small.
- Do not rewrite unrelated code.
- Do not deviate from the approved plan unless you explain why and get approval first.
- Do not change public APIs, schemas, routes, or config unless explicitly included in the approved plan.
- Do not add dependencies unless explicitly requested.
- Do not modify config files unless required and approved.
- If the approved plan is missing, ambiguous, or outdated, stop and create a short implementation plan before editing.