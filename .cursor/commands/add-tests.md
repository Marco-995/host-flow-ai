Add or improve tests for the requested code.

Steps:

1. Inspect the target code and existing test patterns.
2. Identify behavior that should be tested.
3. Cover:
   - happy path,
   - edge cases,
   - error states,
   - boundary conditions,
   - relevant regressions.
4. Prefer existing test utilities, fixtures, and conventions.
5. Avoid testing implementation details.
6. Do not rewrite production code unless a bug is discovered.
7. Run relevant tests if available.
8. Summarize what was tested and what remains uncovered.

Rules:

- Tests should verify behavior, not internal implementation.
- Keep tests readable and maintainable.
- Do not introduce new test libraries unless explicitly requested.