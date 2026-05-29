Explore and design a complex feature before implementation.

Use this command for large, ambiguous, architecture-heavy, or high-impact features.
Do not write implementation code yet.

Goal:
Find multiple viable solution approaches, compare them, and recommend the safest implementation strategy for this codebase.

Steps:

1. Understand the feature request.
2. Inspect the relevant codebase areas, existing architecture, data flow, APIs, UI patterns, tests, and conventions.
3. Identify affected domains, modules, files, routes, models, services, components, and external integrations.
4. Ask focused clarification questions if key requirements are missing.
5. Propose three possible implementation approaches:
   - Conservative approach
   - Balanced approach
   - Ambitious / scalable approach
6. For each approach, evaluate:
   - implementation effort,
   - technical risk,
   - maintainability,
   - testability,
   - migration complexity,
   - impact on existing behavior,
   - integration with the current codebase,
   - future extensibility,
   - rollback strategy.
7. Recommend one approach.
8. Explain why the recommended approach is best for this project.
9. Break the recommended approach into implementation phases.
10. Define validation strategy:
    - unit tests,
    - integration tests,
    - UI tests if relevant,
    - typecheck,
    - lint,
    - build,
    - manual smoke tests.
11. Identify risks, open questions, and decisions required before implementation.
12. Do not edit files.
13. Do not implement anything until the user explicitly approves one approach.

Output format:

# Feature Architecture Plan

## 1. Feature Summary

Briefly restate the requested feature and intended outcome.

## 2. Codebase Context

List inspected files, modules, patterns, APIs, models, components, routes, and tests.

## 3. Assumptions

List assumptions made from the codebase and user request.
Mark uncertain assumptions clearly.

## 4. Open Questions

List only questions that materially affect architecture or implementation.

## 5. Affected Areas

List likely affected parts of the system:
- Backend
- Frontend
- Data model
- API contracts
- Authentication / authorization
- External services
- Tests
- Documentation
- Configuration

Omit irrelevant sections.

## 6. Option A: Conservative Approach

Describe the smallest safe implementation.

Evaluate:
- Effort:
- Risk:
- Maintainability:
- Testability:
- Migration complexity:
- Integration fit:
- Pros:
- Cons:

## 7. Option B: Balanced Approach

Describe a pragmatic implementation with good long-term maintainability.

Evaluate:
- Effort:
- Risk:
- Maintainability:
- Testability:
- Migration complexity:
- Integration fit:
- Pros:
- Cons:

## 8. Option C: Ambitious / Scalable Approach

Describe a more future-proof or extensible implementation.

Evaluate:
- Effort:
- Risk:
- Maintainability:
- Testability:
- Migration complexity:
- Integration fit:
- Pros:
- Cons:

## 9. Recommendation

Recommend exactly one approach.

Explain:
- why this approach fits the current codebase,
- why it is better than the alternatives,
- what trade-offs it accepts,
- what should explicitly not be done in this PR.

## 10. Implementation Phases

Break the recommended approach into small phases.

For each phase:
- goal,
- files likely affected,
- expected changes,
- validation.

## 11. Validation Plan

List exact validation steps and commands if discoverable from the repo.

## 12. Risks & Rollback

List:
- main risks,
- how to detect failure,
- rollback strategy,
- follow-up work.

Rules:

- Do not implement code.
- Do not modify files.
- Do not add dependencies.
- Do not modify configuration.
- Prefer existing project patterns over generic best practices.
- Keep the recommended first implementation as small as possible while preserving future extensibility.
- If multiple agents or models are available, recommend running this same command in parallel and comparing results before implementation.

Parallel-agent note:

For high-risk or highly ambiguous features, this architecture analysis should be run in parallel with multiple agents or models. Each agent should independently produce its own architecture plan. Afterward, use `/compare-architectures` to compare the proposals and create a final recommended implementation strategy.