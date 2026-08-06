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
Phase 0 — COMPLETE
Phase 1 — COMPLETE
```

`TASK-IMP-001` is complete and merged through pull request #5 at merge commit
`3d0830767fd5320f33a4b7a209d937d2b59f7a6e`.

Implementation is authorized only through a currently approved bounded task packet whose
prerequisites still match current repository state.

```text
TASK-IMP-002A — COMPLETE ON DRAFT PULL REQUEST #7; PENDING REVIEW AND MERGE
```

The bounded identity/session implementation is verified on
`codex/task-imp-002a-identity-sessions`, but it is not merged into `main` and creates no remote
infrastructure. Review and merge draft pull request #7 before any later packet is considered.
`TASK-IMP-002B` and `TASK-IMP-002C` remain non-executable until separately approved.

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
