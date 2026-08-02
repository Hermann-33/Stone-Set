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
8. relevant accepted files under `docs/decisions/`

If a requested task conflicts with repository context, stop and report the exact conflict before modifying files.

## Required pre-change summary

Before editing, state:

1. current project state;
2. current task and task ID;
3. applicable accepted decisions;
4. files and systems in scope;
5. protected or explicitly excluded areas;
6. verification that will be run.

## Planning-stage restriction

Stone Set is currently in product discovery. Do not select a stack, generate application scaffolding, or implement features until the relevant product and architecture decisions are documented and accepted.

Proposals are not decisions. A proposed technology, feature, data model, or architecture becomes authoritative only after it is recorded in the appropriate context document or accepted ADR.

## Architecture and security boundaries

- Do not invent implementation facts.
- Do not represent mock, visual, local-only, or planned behavior as persistent production behavior.
- Do not add secrets, credentials, tokens, private keys, or personal data to the repository.
- Do not introduce external services, authentication, persistence, analytics, telemetry, or deployment infrastructure without an explicit documented decision.
- Do not perform destructive data, branch, history, or infrastructure operations without explicit task authorization.

## Task packet requirements

Every implementation prompt for Codex must include:

- task ID and title;
- objective;
- repository context files to read;
- exact scope;
- non-goals;
- protected behavior and boundaries;
- acceptance criteria;
- required tests and checks;
- required documentation updates;
- Git requirements;
- required completion-report format.

## Completion gate

A task is `COMPLETE` only when every applicable track passes:

1. user-facing behavior;
2. application/service behavior;
3. persistence or external-state behavior;
4. security and privacy;
5. tests, lint, type checks, and build;
6. documentation and decision records;
7. Git diff, commit, and push requirements.

Use `PARTIAL` when valid work remains behind a required gate. Use `FAIL` when the task violates accepted boundaries, fails required verification, or cannot be reconciled safely.

## Documentation update rules

Update only the documents whose owned facts changed:

- product purpose or scope: `PROJECT_BRIEF.md`;
- accepted system design: `ARCHITECTURE.md` and possibly an ADR;
- current status: `ACTIVE_CONTEXT.md`;
- module or file ownership: `CODEBASE_MAP.md`;
- phase position or completion criteria: `ROADMAP.md`;
- operating process: `WORKFLOW.md` and possibly an ADR;
- latest task result and exact next action: `HANDOFF.md`;
- material findings and verdicts: `AUDIT_LOG.md`.

Do not create competing versions of the same fact.

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
4. update context and handoff documents;
5. commit with the task ID;
6. push the intended branch;
7. report branch, commit, checks, risks, and verdict.
