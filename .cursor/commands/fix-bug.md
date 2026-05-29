Investigate and fix a bug systematically.

Steps:

1. Restate the bug in precise technical terms.
2. Identify the expected behavior.
3. Identify the actual behavior.
4. Inspect relevant files and call sites.
5. Generate 3-5 likely hypotheses.
6. Determine the most likely root cause.
7. Propose a minimal fix.
8. Add or update tests if applicable.
9. Run relevant validation commands if available.
10. Summarize:
    - root cause,
    - changed files,
    - validation results,
    - remaining risks.

Rules:

- Keep the fix minimal.
- Do not refactor unrelated code.
- Do not change public APIs unless explicitly required.
- Ask for clarification if the bug cannot be reproduced from the available context.