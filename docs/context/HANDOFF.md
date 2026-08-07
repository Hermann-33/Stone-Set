# Stone Set Latest Handoff

Updated: 2026-08-07

## Current task result

```text
Task ID: TASK-PD-018
Title: Verify Phase 2C merge and approve exercise/guidance
Verdict: COMPLETE
Planning branch: codex/task-pd-018-approve-imp-003a
Planning pull request: #13
Verified base: be0f57eee35066da0590e0cf2a3f55d6193231af
Phase 2C pull request: #12 — MERGED
Phase 2C final CI: 31165238497 — PASS
Next packet: TASK-IMP-003A — APPROVED, NOT EXECUTED
```

`TASK-IMP-002C` is complete and merged through pull request #12 at
`be0f57eee35066da0590e0cf2a3f55d6193231af`. Its final head
`0d2249016612b4c5987a32f5b037272b84e930ee` is an ancestor of `main`. Final-head CI passed
documentation/repository, Flutter/Dart, Chrome, Android release/API 24 profile, Web release and local
Supabase gates. The only skips were the expected manual golden-candidate jobs and success-only diff
uploads.

## Implemented boundary

- foundation, one root Dart workspace lockfile and pinned toolchain;
- local-only Supabase identity/session schema, signup denial, RLS/RPC and operator tooling;
- mobile and dashboard provisioned login, password change, session restoration/revalidation,
  revocation/disablement handling and logout/private-state clearing;
- shared semantic themes, responsive primitives and rank presentation;
- fixture-only Android Home/Week/Progress/Profile shell and rank hero;
- fixture-only adaptive Web shell, Overview, productivity layers, path routes and reviewed Linux
  goldens.

No exercise/guidance product schema, browser recovery, media/Storage, routines/review, schedules,
workouts, rank/wallet authority or remote infrastructure exists yet.

## Approved Phase 3A boundary

`TASK-PD-018` creates and approves `docs/tasks/TASK-IMP-003A.md` with:

- fixed authenticated-read-only muscle taxonomy;
- owner-scoped exercise definitions and ordered primary/secondary muscles;
- structured plain-text guidance drafts with optimistic concurrency;
- server-owned canonical JSON and SHA-256 content/revision hashes;
- immutable published revisions and narrow idempotent save/archive/clone/publish operations;
- explicit Data API grants, RLS and function-execution boundaries;
- owned-only clone and cross-user denial;
- exact `idb_shim 2.9.6+2` browser recovery adapter, user-scoped clearing and conflict comparison;
- adaptive exercise library/editor/version UI and Android compile-time read-only contracts.

Media, images, Storage and YouTube remain Phase 3B. Routine usage, independent review and routine
publication remain Phase 3C. The packet creates no remote infrastructure.

## Security boundaries

- public/anonymous signup remains disabled;
- active identity/session/password-change enforcement remains required for product mutations;
- object access, RLS and function execution are separately granted/tested;
- no editable metadata authorization or client-supplied ownership/hash/version authority;
- published revisions are immutable;
- user text is plain structured content, never executable HTML;
- browser recovery is private, user-scoped and non-authoritative;
- service-role/management credentials never enter clients, bundles, logs or Git.

## Exact next action

After the `TASK-PD-018` planning pull request passes CI and merges:

```text
Execute TASK-IMP-003A
branch: codex/task-imp-003a-exercise-guidance
packet: docs/tasks/TASK-IMP-003A.md
```

Do not execute `TASK-IMP-003B` or any later packet yet.
