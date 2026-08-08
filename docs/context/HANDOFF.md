# Stone Set Latest Handoff

Updated: 2026-08-08

## Current task result

```text
Task ID: TASK-IMP-003A
Title: Implement exercise library and structured guidance
Verdict: IMPLEMENTED — FINAL-HEAD CI AND MERGE PENDING
Task branch: codex/task-imp-003a-exercise-guidance
Verified base: a3a3efc373cfd992716ee48b2d28e0c3bec12b58
Planning pull request: #13 — MERGED
Implementation pull request: not opened yet
Next packet: TASK-IMP-003A — remains the only executable packet until merge
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

The task branch now contains the fixed muscle taxonomy, owner-only exercise/guidance schema,
least-privilege Data API/RLS/RPC boundary, immutable published revisions and hashes, shared
contracts, typed dashboard library/editor/history routes and user-partitioned IndexedDB recovery.
Media/Storage, routines/review, schedules, workouts, rank/wallet authority and remote infrastructure
do not exist yet.

## Implemented Phase 3A boundary

`TASK-IMP-003A` implements the approved packet with:

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

Generate and review the four Linux dashboard golden candidates, open the draft pull request, pass
the single path-sensitive final-head CI run and merge the exact verified head:

```text
Finish TASK-IMP-003A
branch: codex/task-imp-003a-exercise-guidance
packet: docs/tasks/TASK-IMP-003A.md
```

Do not execute `TASK-IMP-003B` or any later packet until 003A merges and the grouped planning packet
promotes them.
