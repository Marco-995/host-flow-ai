Compare multiple architecture proposals for the same feature.

Use this command after running `/architect` multiple times, possibly with different agents, models, or worktrees.

Do not implement code.

Steps:

1. Read the provided architecture proposals.
2. Identify the core assumptions behind each proposal.
3. Compare the proposals across:
   - implementation effort,
   - technical risk,
   - maintainability,
   - testability,
   - migration complexity,
   - integration with the existing codebase,
   - impact on existing behavior,
   - future extensibility,
   - rollback strategy.
4. Identify where the proposals agree.
5. Identify where the proposals conflict.
6. Identify hidden risks or missing considerations.
7. Recommend one of:
   - adopt proposal A,
   - adopt proposal B,
   - adopt proposal C,
   - combine selected parts into a hybrid approach,
   - reject all and request a new plan.
8. Produce a final recommended implementation strategy.
9. Break the final recommendation into small implementation phases.
10. Define validation steps.
11. Do not edit files.
12. Do not implement anything.

Output format:

# Architecture Comparison

## 1. Compared Proposals

List the proposals being compared.

## 2. Areas of Agreement

Summarize where all proposals align.

## 3. Key Differences

Explain the important differences.

## 4. Evaluation Matrix

Evaluate each proposal by:
- Effort
- Risk
- Maintainability
- Testability
- Migration complexity
- Integration fit
- Extensibility
- Rollback safety

## 5. Missing Considerations

List important topics not covered or underexplored.

## 6. Recommended Direction

Recommend the best option or hybrid approach.

Explain:
- why it is best,
- what trade-offs it accepts,
- what should not be included in the first PR.

## 7. Implementation Phases

Break the final approach into small phases.

For each phase:
- goal,
- likely files affected,
- expected changes,
- validation.

## 8. Final Validation Plan

List tests, build checks, manual smoke tests, and review steps.

Rules:

- Do not implement code.
- Do not modify files.
- Prefer the smallest safe first implementation.
- Prefer existing project patterns.
- Flag overengineering.
- Flag underengineering.
- Separate must-have decisions from optional future improvements.