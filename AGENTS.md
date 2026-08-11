# Stone Set Agent Rules

This file governs all planning, implementation, audit, refactor, cleanup, documentation, and workflow work in this repository.

## Repository authority

The repository is authoritative. Chat history, memory, assumptions, and prior prompts are non-authoritative unless their conclusions are written into the repository.

## Mandatory pre-work

Before changing files, read in this order:

1. `docs/context/ACTIVE_CONTEXT.md`
2. `docs/context/PROJECT_BRIEF.md`
3. `docs/context/ARCHITECTURE.md`
4. `docs/context/CODEBASE_MAP.md`
5. `docs/context/ROADMAP.md`
6. `docs/context/WORKFLOW.md`
7. `docs/context/HANDOFF.md`
8. relevant accepted product files under `docs/product/`
9. relevant accepted ADRs under `docs/decisions/`
10. the approved execution packet under `docs/tasks/`, when implementing

If a requested task conflicts with repository context, stop and report the exact conflict before modifying files.

## Current phase boundary

```text
Phase 0  — COMPLETE
Phase 1  — COMPLETE
Phase 2A — COMPLETE
Phase 2B — COMPLETE
Phase 2C — COMPLETE
Phase 3A — COMPLETE
Phase 3B — COMPLETE
Phase 3C — COMPLETE
Phase 4  — COMPLETE
Phase 5A — COMPLETE
Phase 5B — COMPLETE
Phase 6  — COMPLETE
Phase 7  — COMPLETE
Phase 8  — COMPLETE
```

`TASK-IMP-001` is complete and merged through pull request #5 at merge commit
`3d0830767fd5320f33a4b7a209d937d2b59f7a6e`.

`TASK-IMP-002A` is complete and merged through pull request #7 at merge commit
`2281be745b75116e70d2fed9ccf85c60e79bc4aa`.

`TASK-IMP-002B` is complete and merged through pull request #10 at merge commit
`1ab0fc56543dbd64500a9319dd6a3f014c4ccc90`.

`TASK-IMP-002C` is complete and merged through pull request #12 at merge commit
`be0f57eee35066da0590e0cf2a3f55d6193231af`.

`TASK-IMP-003A` is complete and merged through pull request #14 at merge commit
`eb59a3b4707ff12c154594408f1f7902555f39e0`.

All planned implementation and the minimal private release through `TASK-IMP-008` are complete.
The post-release presentation-modernization task is also complete and merged:

```text
docs/tasks/TASK-IMP-009.md
```

`TASK-IMP-009` is complete and merged through pull request #31 at merge commit
`e59303d5acd4dbfe6706822b100913c531dc9297`. It changed presentation, accessibility and
event-driven motion in the existing Flutter Android application only. It did not change backend,
persistence, route, workflow, rank, scheduling, workout, reward, routine-publication or other
product semantics. Direct owner routine publication remains authoritative; do not
reintroduce independent review, approval queues or a second-user publication dependency.

The latest bounded implementation packet is complete:

```text
docs/tasks/TASK-IMP-010.md
branch: codex/task-imp-010-consistency-multiplier
```

`TASK-IMP-010` is complete. Its code is merged through PR #34 at
`12eb3010064a7e17774c5c1ce564badce8b68d6a`; the exact committed migration was then deployed through
Supabase migration history to production project `pjltldrernuvrjsnmcqg` and verified at authoritative
base `1.00`. It does not authorize invented streak history, weekly/swap changes or exercise-media
work. The next approved bounded implementation packet is:

```text
docs/tasks/TASK-IMP-011.md
branch: codex/task-imp-011-exercise-media-completion
```

It may integrate the existing 003B media stack into exercise detail, add the ADR-0008 atomic
draft-materialization contract, inventory production and populate only explicitly approved media.
It must not change routine usage, prescriptions, weekly/swap behavior, scoring or historical
snapshots.

## Required pre-change summary

Before editing, state:

1. current project state;
2. current task and task ID;
3. applicable accepted decisions;
4. files and systems in scope;
5. protected or explicitly excluded areas;
6. verification that will be run.

## Architecture and security boundaries

- Do not invent implementation facts.
- Do not represent mock, visual, local-only, or planned behavior as persistent production behavior.
- Do not add secrets, credentials, tokens, private keys, or personal data to the repository.
- Do not create or modify external infrastructure unless the task packet explicitly authorizes it.
- Do not perform destructive data, branch, history, or infrastructure operations without explicit task authorization.
- Public clients never receive service-role keys, database passwords, backup credentials, or operator tokens.
- Clients never authoritatively set RR, XP, rank, penalties, wallet balances, milestones, or finalization totals.
- Supabase RLS and narrowly scoped server operations remain the authorization and integrity boundaries.

## Task packet requirements

Every implementation packet must include:

- task ID and title;
- objective;
- mandatory repository reads;
- verified starting state;
- exact scope;
- non-goals;
- protected behavior and boundaries;
- acceptance criteria;
- required tests and checks;
- required documentation updates;
- Git requirements;
- required completion-report format.

Agents must re-check repository state rather than blindly trust an older packet.

## Completion gate

A task is `COMPLETE` only when every applicable track passes:

1. user-facing behavior;
2. application or service behavior;
3. persistence or external-state behavior;
4. security and privacy;
5. tests, lint, type checks, build, and CI;
6. documentation and decision records;
7. Git diff, commit, push, and PR requirements.

Use `PARTIAL` when valid work remains behind a required gate. Use `FAIL` when the task violates accepted boundaries, fails required verification, or cannot be reconciled safely.

## Documentation update rules

Update only documents whose owned facts changed:

- product purpose or scope: `PROJECT_BRIEF.md`;
- accepted system design: `ARCHITECTURE.md` and possibly an ADR;
- current status: `ACTIVE_CONTEXT.md`;
- module or file ownership: `CODEBASE_MAP.md`;
- phase position or completion criteria: `ROADMAP.md`;
- operating process: `WORKFLOW.md` and possibly an ADR;
- latest task result and exact next action: `HANDOFF.md`;
- material findings and verdicts: the active audit-log volume listed in `CODEBASE_MAP.md`.

Do not create competing versions of the same fact. Preserve accepted ADR and audit history.

## ADR triggers

Create an ADR before durable changes to:

- runtime or system architecture;
- public contracts;
- persistence ownership or migration strategy;
- authentication or authorization;
- material security or privacy controls;
- external-service integration;
- deployment model;
- repository governance or authority hierarchy.

Never rewrite an accepted ADR to conceal a changed decision. Add a new ADR that explicitly supersedes the old decision.

## Git discipline

After successful work:

1. inspect the complete diff;
2. remove unrelated changes;
3. run all required verification;
4. update context, audit, and handoff documents;
5. commit with the task ID;
6. push the intended branch;
7. report branch, commit, checks, risks, and verdict.
