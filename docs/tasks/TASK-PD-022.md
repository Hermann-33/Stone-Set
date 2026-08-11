# TASK-PD-022 — Approve authoritative consistency multiplier correction

Status: `COMPLETE`
Date: 2026-08-11
Branch: `codex/task-pd-022-approve-imp-010`

## Objective

Verify the current Home/progress/backend boundary and approve the smallest truthful correction for
the fixture multiplier leak. This planning task creates no runtime, schema or production change.

## Verified starting state

```text
main                         9c09b35 — TASK-IMP-009 completion merged
working tree                 clean before planning edits
TASK-IMP-009                 complete and merged through PR #31
Home standard fixture        Multiplier = 1.5× / Fixture state
authenticated Home merge     replaces live rank and XP, but not multiplier
RankAccount                  no multiplier or perfect-week streak field
rank_accounts                no multiplier or streak column
progress payload             no multiplier field
weekly finalization evidence no immutable perfect/protected-week evaluation history
```

The current backend resolves daily RR/XP ledger effects lazily. It does not persist the complete,
immutable weekly classifications needed to reconstruct the accepted rank-v6 perfect-week streak,
reset and protected-week rules. Existing workout, week and progression-protection data are not an
honest substitute for that missing authority.

## Decision

Approve `TASK-IMP-010` to establish a server-owned base multiplier of `1.00×`, expose it through the
existing progress account payload and replace the authenticated Home fixture value with that live
value. The explicit fixture/preview path retains its intentional `1.5×` scenario.

The full rank-v6 streak ladder remains accepted product behavior but is deferred until a later
bounded task designs authoritative week evaluation/finalization and protected-full-week evidence.
No historical perfect weeks are inferred, no owner account receives a special value, and no RR,
XP, ledger, rank-threshold, wallet, schedule, swap or workout behavior changes.

No ADR is required for this bounded additive correction because it extends the existing
Supabase-authoritative progress account contract without changing authority, persistence ownership,
deployment topology or public workflow. A later full streak evaluator is an ADR trigger if it
introduces a new finalization model.

## Compatibility and security evidence

- Supabase migrations remain the source-controlled deployment mechanism; remote schema changes
  must use the committed migration history rather than ad-hoc production SQL:
  <https://supabase.com/docs/guides/deployment/database-migrations>.
- RLS and object grants remain distinct controls. The existing `rank_accounts` owner-select policy
  and read-only authenticated grant remain intact; clients receive no update privilege:
  <https://supabase.com/docs/guides/database/postgres/row-level-security>.
- Exact decimal `numeric` is appropriate for the finite multiplier values. The implementation
  packet requires a bounded check constraint and server-owned default.

## Files changed by this planning task

- `AGENTS.md`;
- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/CODEBASE_MAP.md`;
- `docs/context/ROADMAP.md`;
- `docs/context/HANDOFF.md`;
- `docs/tasks/README.md`;
- `docs/tasks/TASK-PD-022.md`;
- `docs/tasks/TASK-IMP-010.md`;
- append-only entry in `docs/context/AUDIT_LOG_CONTINUED_3.md`.

## Explicitly unchanged

- application, package, generated and test source;
- dependencies and lockfiles;
- migrations, Supabase configuration and remote Supabase state;
- CI workflows and release artifacts;
- weekly scheduling and swap behavior/UI;
- media behavior and production content;
- accepted product specifications, ADRs and historical audit records.

## Planning verification

- task-packet required-section validation;
- repository/document and relative-link checks;
- `git diff --check`;
- Markdown-only path review;
- secret and personal-data scan;
- append-only audit validation;
- complete diff and clean-tree review.

Runtime tests and builds are intentionally deferred because this approval diff contains only
Markdown. They are mandatory in `TASK-IMP-010`.

## Exact next action

```text
Execute TASK-IMP-010
branch: codex/task-imp-010-consistency-multiplier
packet: docs/tasks/TASK-IMP-010.md
```
