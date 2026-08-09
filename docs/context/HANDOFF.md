# Stone Set Latest Handoff

Updated: 2026-08-09

## Current state

```text
TASK-IMP-003A — COMPLETE AND MERGED (PR #14)
TASK-IMP-003B — COMPLETE AND MERGED (PR #16)
TASK-IMP-003C — APPROVED AND EXECUTABLE
```

`TASK-IMP-003B` merged through PR #16 at merge commit
`1b1c18d95214117e59a6c208139c2b019e313cb2` after final CI run `31305011340` passed.

Implemented through 003B:

- private provisioned authentication, session restoration, password-change and logout boundaries;
- shared Flutter design system and Android Home/Week/Progress/Profile shell;
- adaptive Flutter Web dashboard shell and Overview;
- owner-scoped exercise library and structured guidance authoring/publication;
- IndexedDB exercise/guidance draft recovery;
- private exercise images with selection, orientation correction, resize/re-encode, metadata stripping and hashing;
- private Supabase Storage upload/finalization, ordering, cover selection and alt text;
- deterministic immutable media manifests;
- strict YouTube normalization and user-initiated official IFrame preview;
- focused domain/data/dashboard/database/Storage tests and path-sensitive CI.

No routine, weekly-plan, workout, rank/wallet or production deployment runtime exists yet.

## Current implementation mode

Stone Set is a private application for two known users, not a public production SaaS.

Future packets should optimize for working functionality and implementation speed. Preserve existing Auth/RLS/private-data boundaries, but do not add production-grade threat modeling, anti-abuse systems, exhaustive permission matrices, broad golden suites or unnecessary CI lanes unless a concrete implementation defect requires them.

## Exact next action

```text
task: TASK-IMP-003C
branch: codex/task-imp-003c-routine-review-publication
packet: docs/tasks/TASK-IMP-003C.md
mode: fast private two-user implementation
```

Implement only the runtime for routine draft authoring, validation, submission, second-user review, publication and version history. The packet has already been simplified and approved; no new planning task or ADR is required.
