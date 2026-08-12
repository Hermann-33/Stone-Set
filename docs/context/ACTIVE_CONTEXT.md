# Stone Set Active Context

Updated: 2026-08-13

## Current position

Stone Set is a private hypertrophy training application with:

- Android Flutter client;
- Flutter Web dashboard hosted on Vercel;
- Supabase Auth/Postgres/Storage backend;
- private Android updates through Firebase App Distribution.

Implementation mode remains **FAST PRIVATE RELEASE**. Preserve Auth/RLS/private-data boundaries and server authority, but do not add enterprise workflow or hardening that the private app does not need.

## Active bounded task

```text
TASK-IMP-013A — Cached mobile shell, synchronization and Home refresh
branch: agent/task-imp-013a-offline-cache
PR: #47
ADR: ADR-0010
status: PARTIAL — runtime candidate green; merge/distribution/device acceptance pending
```

The exact runtime candidate head
`51474a6e8d3157bfbdad9c9e1de3fa57a468a758` passed Foundation CI run `31621647343` (#365).
Applicable jobs included repository/docs checks, generated-source verification, formatting, strict
analysis, deterministic mobile goldens, affected mobile tests, Android release APK/rank-bundle
verification and Android API 24 profile; all passed.

Canonical documentation is now being synchronized on the same implementation branch. Any
subsequent documentation commit creates a new exact head and must obtain a fresh successful
Foundation CI result before PR #47 is merged.

## TASK-IMP-013A implemented behavior

The Android client now has an owner-scoped offline-first read shell after one prior successful
online authentication/bootstrap:

- `stone_set_workout.db` is migrated from v1 to v2 without replacing the existing workout draft
  tables;
- `mobile_snapshots` stores schema-versioned owner-scoped bootstrap/Week/Progress snapshots;
- `mobile_sync_state` stores synchronization generation/freshness/error metadata;
- cached bootstrap can expose the same-owner protected shell before a network refresh;
- wrong-owner, password-change-required, access-denied, maintenance and incompatible cached states
  cannot authorize protected content;
- Home, Week and Progress are cache-first and preserve the last good generation when refresh fails;
- one single-flight mobile sync coordinator revalidates auth, synchronizes supported pending workout
  edits, then refreshes authoritative Week/wallet and Progress/rank/history before committing one
  coherent cache generation;
- Home uses native pull-to-refresh and awaits that coordinator;
- a regression test proves mounted Home rank/RR changes after pull-to-refresh without application
  restart or shell recreation;
- Week and Progress manual refresh use the same coordinator;
- authenticated-shell startup and app resume request best-effort synchronization;
- successful workout completion triggers best-effort authoritative read refresh;
- logout/session loss does not silently destroy owner-scoped pending workout work.

No Supabase migration, new package dependency, rank/schedule rule change, application ID/signing
change or Firebase pipeline change is part of TASK-IMP-013A.

## Preserved authority boundaries

- Supabase remains authoritative for authentication, RR, XP, rank, wallet, consistency, penalties,
  PRs, swaps, schedule and workout finalization.
- Cached mobile data is private, owner-scoped and non-authoritative.
- First-ever sign-in remains online-only.
- ADR-0003 still requires an online authoritative workout start.
- Offline-created workout sessions and reconciliation remain deferred to TASK-IMP-013B.
- Offline swap attempts do not become authoritative local mutations.
- `rank-v6`, `schedule-v3`, the 20-rank ladder and existing reward semantics are unchanged.

## Exact next engineering action

1. Finish canonical TASK-IMP-013A documentation/audit updates on
   `agent/task-imp-013a-offline-cache`.
2. Obtain Foundation CI success on that new exact head.
3. Mark PR #47 ready for review and merge only that exact green head.
4. Verify Foundation CI for the resulting exact `main` commit.
5. Verify a **fresh** Private Android Distribution run for the merged mobile diff and record its
   version, build and Firebase release ID.
6. Complete the TASK-IMP-013A physical airplane-mode acceptance flow on a real Android device.

Do not use the historical TASK-IMP-012 release `0.1.0 / 1000062 / 5j1j4rhquebu0` as fresh
TASK-IMP-013A distribution evidence.

## Physical acceptance still outstanding

A real tester device must prove:

- online sign-in and initial Home/Week/Progress load;
- airplane-mode kill/relaunch exposes cached Home, Week and Progress;
- offline Home pull-to-refresh completes without blanking cached content;
- internet restoration followed by Home pull-to-refresh updates current authoritative rank/RR
  without restart.

This cannot be claimed from emulator/widget tests alone.

## Independent residual tasks

### TASK-IMP-011

Exercise media engineering/deployment is complete. Approved production content remains external:
only explicitly supplied/approved cover images and YouTube selections may be populated. Never
fabricate or scrape content.

### TASK-IMP-012

Permanent Android signing and automatic private Firebase distribution are proven. Remaining
external gates are an independent signing-key/password backup and the one-time
old-debug-signed-to-permanent phone migration/install confirmation.

The active permanent signer fingerprint remains:

```text
D2FCB14AB458AE0F77D3CC7528E09D0D3C4514A7CAA9981C7F26AD87908C2829
```

Firebase project `stone-set` contains Android app
`1:263990431224:android:fe2bf52c3f622047225a0d`; group `stone-set-testers` is the private tester
channel.

## Routine publication policy — authoritative

The original TASK-IMP-003C independent-review lifecycle is superseded. Current routine lifecycle is:

```text
Create/Edit → Save → Validate → Publish
```

A routine owner publishes their own validated routine directly. Do not reintroduce submission,
reviewer, approval/rejection or second-user publication dependencies unless the product owner makes
a new explicit decision.

## Release topology

- single hosted Supabase project `pjltldrernuvrjsnmcqg`;
- production dashboard at `https://stone-set.vercel.app`;
- private Android updates through Firebase App Distribution group `stone-set-testers`;
- no staging environment;
- no Play Store/AAB requirement;
- public clients contain only publishable Supabase client configuration; service-role/database
  secrets never enter Flutter clients.
