Refactor the requested code without changing behavior.

Steps:

1. Inspect the relevant files and call sites.
2. Identify the current responsibilities and pain points.
3. Propose a minimal refactoring plan.
4. Preserve existing behavior and public APIs.
5. Keep the diff focused.
6. Avoid broad rewrites.
7. Add or update tests if behavior is not already covered.
8. Run relevant validation commands if available.
9. Summarize changed files and explain why the refactor is safe.

Rules:

- Do not introduce new abstractions unless they clearly reduce complexity.
- Do not change runtime behavior unless explicitly requested.
- Do not rename public exports, routes, props, or API fields without approval.