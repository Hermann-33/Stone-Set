# Stone Set New-Chat Bootstrap Prompt

Updated: 2026-08-04
Status: `ACTIVE REUSABLE PROMPT`

## Purpose

Use this prompt at the beginning of a new Stone Set conversation. It loads authoritative repository context before planning, advising, or changing files.

## Copy-paste prompt

```text
You are continuing work on Stone Set.

Repository: Hermann-33/Stone-Set
Default branch: main

The repository is authoritative. Do not rely on chat memory, previous-conversation summaries, or assumptions when repository files can be inspected.

Before answering the Stone Set task:

1. Read `AGENTS.md` completely.
2. Read these context files in order:
   - `docs/context/ACTIVE_CONTEXT.md`
   - `docs/context/PROJECT_BRIEF.md`
   - `docs/context/ARCHITECTURE.md`
   - `docs/context/CODEBASE_MAP.md`
   - `docs/context/ROADMAP.md`
   - `docs/context/WORKFLOW.md`
   - `docs/context/HANDOFF.md`
3. Read the accepted product baselines relevant to the task, including:
   - `docs/product/HYPERTROPHY_ROUTINE.md`
   - `docs/product/AUTHENTICATION_AND_SESSION_UX.md`
   - `docs/product/ROUTINE_ELIGIBILITY.md`
   - `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`
   - `docs/product/RANK_SYSTEM.md`
   - `docs/product/WEEKLY_SCHEDULING.md`
   - `docs/product/APPLICATION_WORKFLOW.md`
4. Read `docs/decisions/README.md` and every accepted ADR.
5. When implementing, read the exact approved packet under `docs/tasks/`.
6. Inspect the current branch, recent relevant commits, and directly affected files.
7. Resolve factual conflicts according to `docs/context/WORKFLOW.md`.

Then report:

- current phase and maturity;
- implemented versus documented behavior;
- accepted product and architecture baselines;
- exact next action;
- any conflict with my request.

Operating rules:

- Follow `AGENTS.md` and `docs/context/WORKFLOW.md`.
- Before changing files, provide the required task ID, scope, exclusions, protected behavior, and verification plan.
- Approval of architecture or a task packet does not mean implementation exists.
- Implement only an approved packet whose prerequisites still match the repository.
- Do not silently modify accepted product configurations, ADRs, or historical records.
- Do not add secrets or personal data.
- Keep documentation and audit history synchronized.
- Inspect the final diff, run all required checks, commit with the task ID, push the intended branch, and report the verdict and exact next action.
- Use `COMPLETE`, `PARTIAL`, or `FAIL` according to the repository completion gate.

My task for this chat:
[PASTE THE NEW TASK HERE]
```

## Usage

Replace the placeholder with the actual task. If repository access is unavailable, request the required files instead of reconstructing current state from memory.