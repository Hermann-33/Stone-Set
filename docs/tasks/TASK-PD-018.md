# TASK-PD-018 — Verify Phase 2C merge and approve exercise/guidance

Status: `COMPLETE`
Approved by: user one-shot MVP orchestration request on 2026-08-07
Type: post-merge verification and bounded implementation planning only

## Objective

Verify the merged `TASK-IMP-002C` result, correct canonical pre-merge facts, resolve the bounded
exercise/guidance implementation details left open by the accepted plans, and promote
`TASK-IMP-003A` as the next executable packet without implementing runtime behavior or changing
external infrastructure.

## Mandatory inputs reviewed

- repository governance, README and canonical context;
- accepted exercise/guidance, complete UI and application-workflow specifications;
- accepted ADR-0001, ADR-0002, ADR-0005 and ADR-0006;
- existing task packets, merged dashboard/shared code and tests;
- current identity migration, Supabase configuration/tests and CI workflow;
- pull request #12 metadata, merge graph and final-head CI;
- current official Supabase RLS, function, migration and pgTAP guidance;
- current `idb_shim` package metadata and the existing coordinated Dart dependency graph.

## Verified starting state

```text
Working tree              CLEAN
Branch                    main
main / origin/main        be0f57eee35066da0590e0cf2a3f55d6193231af
TASK-IMP-001              COMPLETE AND MERGED
TASK-IMP-002A             COMPLETE AND MERGED
TASK-IMP-002B             COMPLETE AND MERGED
TASK-IMP-002C             COMPLETE AND MERGED
Pull request #12          MERGED
PR head                   0d2249016612b4c5987a32f5b037272b84e930ee
PR merge                  be0f57eee35066da0590e0cf2a3f55d6193231af
Final 002C CI             31165238497 — PASS
Post-merge main CI        31166440467 — PASS
Remote infrastructure     NONE
```

The PR head is an ancestor of `main`. Final-head CI passed documentation/repository,
Flutter/Dart, Android API 24 profile and local Supabase jobs. The two manual golden-candidate jobs
were expected to skip on an ordinary push/PR run; no required check was skipped. No existing task,
branch or pull request collides with `TASK-PD-018` or `TASK-IMP-003A`.

## Material findings

1. Current-state documents still described `TASK-IMP-002C` as unexecuted or merge-pending and must
   be corrected from the verified Git graph. Append-only audit history remains unchanged.
2. `TASK-IMP-003A.md` did not exist. The accepted plans define its capability but leave exact
   taxonomy, canonical hashing, clone authorization and browser-recovery dependency choices to the
   bounded packet.
3. Phase 3A remains inside accepted Flutter/Supabase architecture. It adds the first authoritative
   product domain but does not require a new backend, router, state framework or ADR.
4. The current Supabase changelog records the April 2026 Data API change that SQL-created tables are
   not exposed automatically. The packet therefore treats object grants, RLS and function execution
   as independent, tested controls rather than assuming new objects are client-usable.
5. The muscle taxonomy is a fixed server-seeded, authenticated-read-only MVP vocabulary with stable
   keys. It is not user-authored and is not a medical classification.
6. Guidance stays structured plain text. Server-owned canonical JSON schema version 1 and SHA-256
   content/revision hashes make publication evidence deterministic and testable.
7. No accepted cross-user content-sharing/read model exists. Phase 3A clone is therefore limited to
   the authenticated owner's readable exercise; cross-user clone/read is denied. A later sharing
   decision requires an ADR or bounded authorization change.
8. `idb_shim 2.9.6+2` is the selected IndexedDB adapter. Its current stable metadata requires Dart
   `^3.12.0`, supports modern Web APIs/JS and Wasm compilation, and does not conflict with the pinned
   Dart 3.12.2 baseline. It is added only during implementation, pinned exactly and resolved through
   the single root lockfile.
9. Media metadata, Storage, images and YouTube remain owned by `TASK-IMP-003B`. Routine usage,
   review and publication scheduling remain owned by `TASK-IMP-003C`. Phase 3A must use truthful
   unavailable/placeholder states rather than fake persisted records.

Official evidence reviewed:

- <https://supabase.com/docs/guides/database/postgres/row-level-security>
- <https://supabase.com/docs/guides/database/functions>
- <https://supabase.com/docs/guides/local-development/testing/overview>
- <https://supabase.com/docs/guides/local-development/cli/testing-and-linting>
- <https://pub.dev/packages/idb_shim/versions>

## Exact planning changes

- record PR #12, merge commit and final CI as complete;
- mark Phase 2C complete and merged;
- create this planning record;
- create `TASK-IMP-003A.md` with an implementation-ready verified state, schema/security/hash/cache
  contracts, exact scope/non-goals, tests, Git behavior and completion report;
- promote `TASK-IMP-003A` to `APPROVED — NOT EXECUTED`;
- append material evidence to `docs/context/AUDIT_LOG_CONTINUED_3.md`.

## Protected boundaries

- documentation/governance only;
- no `apps/`, `packages/`, `supabase/`, `.github/workflows/`, dependency, lockfile or tool edit;
- no migration, muscle row, exercise, guidance draft/revision, browser cache or UI implementation;
- no Storage bucket, image, YouTube, routine, review, schedule, workout, rank or wallet behavior;
- no remote Supabase/Vercel change, account creation, secret or personal data;
- preserve identity/session/signup/password-proof/operator and append-only history boundaries;
- do not approve `TASK-IMP-003B` or any later packet.

## Git requirements

```text
branch: codex/task-pd-018-approve-imp-003a
no work directly on main
no history rewriting or force-push
commit contains TASK-PD-018
push branch
open draft PR targeting main
inspect complete diff and final-head checks
merge only after every required gate is successful
```

## Verification

- PR #12 merge/head ancestry/final CI evidence;
- task-ID, branch and PR collision search;
- official Supabase and package compatibility review;
- documentation-only path review;
- `git diff --check` and repository documentation/hygiene checks;
- complete `main...HEAD` diff, secret/personal-data and clean-tree review;
- required GitHub Actions passing on the final planning head.

## Approval verdict and exact next action

```text
TASK-PD-018    COMPLETE
TASK-IMP-002C  COMPLETE AND MERGED
TASK-IMP-003A  APPROVED — NOT EXECUTED
```

After this planning pull request merges:

```text
Execute TASK-IMP-003A
branch: codex/task-imp-003a-exercise-guidance
packet: docs/tasks/TASK-IMP-003A.md
```

No later packet is executable yet.
