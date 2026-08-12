# TASK-IMP-013A — Cached mobile shell, synchronization and Home refresh

Updated: 2026-08-12
Status: `APPROVED`
Branch: `agent/task-imp-013a-offline-cache`
Decision: `ADR-0010`

## Objective

Make the Android application useful without connectivity after one successful online authentication/bootstrap, using owner-scoped SQLite snapshots and one synchronization coordinator. Home, Week, and Progress must render cached authoritative state offline. Home pull-to-refresh must await real synchronization and update rank/RR while Home remains mounted.

This task is intentionally bounded. Offline-created workout sessions and reconciliation are deferred to TASK-IMP-013B and remain prohibited by ADR-0003 until a separate superseding decision is accepted.

## Verified starting state

```text
main                                   7cb8b3973ba54fd08d5b619f9443901257a4ca2d
mobile                                 Flutter Android
state/routing                          Riverpod + go_router
backend                                Supabase Auth/Postgres/Storage
local DB                               sqflite, stone_set_workout.db v1
local tables                           active_workouts, workout_set_drafts
read snapshot cache                    none
central mobile sync coordinator        none
cold offline restored session          recoverable failure routes to Login
Home live data                         fixture shell + direct Week + direct Progress reads
Week live data                         direct Supabase current-week read
Progress live data                     direct Supabase progress read
Home pull-to-refresh                   none
workout start                          online only
release signing/distribution           ADR-0009 permanent signer + Firebase App Distribution
```

## Authority and conflicts

- ADR-0002 remains authoritative for Supabase/RLS/server-owned reward state.
- ADR-0003 remains authoritative for online workout start, durable active workout drafts, and server finalization.
- ADR-0010 expands mobile read caching/authenticated-shell continuity and central synchronization.
- Current product/workflow language that makes all protected mobile rendering depend on an immediately refreshed session is superseded only for previously verified same-owner cached operation under ADR-0010.
- The explicit offline-workout-start exclusion remains unchanged in this task.

## Exact scope

### SQLite and cache

- extend the existing SQLite database through a tested version migration;
- add owner-scoped, schema-versioned snapshot persistence for the minimum required cached surfaces;
- cache a previously verified eligible identity bootstrap for same-owner offline shell restoration;
- cache current Week/wallet and Progress/rank/history snapshots;
- store common synchronization/freshness metadata;
- use coherent snapshot generations or an equivalent transaction so failed partial refreshes do not replace a good cached generation;
- never introduce Hive, Isar, Realm, Firestore, or another database framework.

### Authentication/bootstrap

- first-ever sign-in remains online-only;
- after an online authenticated bootstrap, persist the eligible owner-scoped bootstrap snapshot;
- on cold start, recover the Supabase persisted session and load only the matching cached bootstrap before attempting network refresh;
- transport/server-unavailable failure alone keeps the cached authenticated shell usable;
- definitive Auth/profile/compatibility rejection still follows existing sign-out/access-denied/quarantine behavior;
- password-change-required state is never bypassed by cached state.

### Central synchronization

Implement one mobile synchronization coordinator with a common state containing at least:

- synchronization running/not running;
- last successful synchronization time;
- last recoverable failure;
- cached/stale versus freshly synchronized state;
- pending local workout mutation count where the current local model can derive it.

Required order:

1. resolve current owner/session;
2. revalidate Supabase session when possible;
3. stop on definitive authentication rejection;
4. synchronize supported pending active-workout mutations before final reads;
5. fetch current authoritative Week/wallet;
6. fetch authoritative Progress/rank/history;
7. validate payload ownership;
8. commit coherent snapshots;
9. update last-successful metadata;
10. publish one generation/change signal to cache-backed Riverpod consumers.

No continuous polling. Do not add `connectivity_plus` solely for reachability prediction.

### Cached Home

- Home renders from cached Week + Progress immediately when available;
- a network failure after cached render leaves Home/rank visible;
- replace the fixture-status header treatment on live Home with concise synchronization/freshness status;
- preserve fixture/gallery behavior for explicit fixture routes;
- preserve event-driven rank animation from TASK-IMP-009; no idle loop.

### Home pull-to-refresh

- wrap live Home in standard Flutter pull-to-refresh behavior with always-scrollable semantics;
- pull refresh awaits the synchronization coordinator rather than merely invalidating providers;
- successful refresh publishes the new snapshot generation and updates rank/RR without navigation or app restart;
- offline refresh stops cleanly, preserves cached content, and exposes stale/offline status;
- spinner completion is tied to coordinator completion/failure.

### Cached Week

- Week reads the last synchronized materialized schedule/wallet offline;
- pull-to-refresh uses the synchronization coordinator;
- swap confirmation remains a real server mutation and is not applied authoritatively offline;
- failed offline swap attempt produces a concise internet-required/retry state and preserves the cached Week.

### Cached Progress

- Progress reads last synchronized authoritative rank/account/ledger/history offline;
- pull-to-refresh uses the synchronization coordinator;
- no provisional RR/XP transactions are fabricated from local workout state;
- progression-related secondary reads may remain separately unavailable offline if they are not part of the accepted Progress snapshot, but failure must not blank the cached authoritative Progress surface.

### Lifecycle triggers

- successful online sign-in/bootstrap;
- authenticated shell startup after cached render;
- app resume;
- Home/Week/Progress manual refresh;
- existing online workout synchronization/completion path where safe.

Use a lifecycle-aware shell/controller rather than continuous timers.

### Account isolation and logout/session loss

- every snapshot row/query is keyed by immutable owner UUID;
- cached payload ownership is validated before promotion;
- another account never sees a previous owner's Home/Week/Progress/bootstrap/workout state;
- connect the existing unsynchronized-private-work/quarantine hooks to actual local workout state where required for safe logout/session loss;
- do not silently delete pending workout data owned by another or signed-out user;
- ordinary cached read snapshots may be hidden/cleared under existing logout policy without touching quarantined unsynchronized work.

## Database/server changes

### Local SQLite

Expected local migration: database version `1 → 2` (or the next repository-consistent version if implementation inspection requires a different number).

Expected tables conceptually:

```text
mobile_snapshots(
  owner_id,
  snapshot_key,
  schema_version,
  payload_json,
  server_updated_at,
  cached_at,
  generation_id,
  primary key(owner_id, snapshot_key)
)

mobile_sync_state(
  owner_id primary key,
  generation_id,
  last_successful_sync_at,
  last_attempt_at,
  last_error_code,
  updated_at
)
```

The exact schema may be adjusted to fit the existing sqflite abstraction while preserving owner scoping, schema versioning and coherent generation behavior.

### Supabase

No Postgres/RPC migration is expected for 013A. Existing `get_or_create_current_week_v1`, progress reads, Auth refresh/bootstrap, and workout synchronization APIs should be reused. If code inspection proves a server change is required, stop runtime expansion and record the conflict/scope change before implementing it.

## New dependencies

None expected. Reuse existing `sqflite`, Riverpod, go_router and Supabase Flutter packages. Do not add a connectivity package solely for this task.

## Protected behavior and non-goals

Do not alter:

- `rank-v6` thresholds, 20-rank ladder, Adonis 5,500 RR;
- multiplier ladder, perfect-week rules, penalties or PR rewards;
- `schedule-v3`, swap count/payment/free-credit rules or complete-identity swaps;
- hypertrophy routine publication;
- immutable workout/reward history;
- server authority for RR, XP, rank, wallet, consistency, penalties, PRs or finalization;
- offline workout start;
- offline authoritative swaps;
- exercise media content;
- YouTube online-only rule;
- Android application ID/signing identity;
- Firebase private-distribution architecture;
- CI thresholds or API-24 requirements.

## Required tests

### Bootstrap

- no prior successful login + offline → online sign-in required;
- previous successful bootstrap + matching persisted session + offline → cached authenticated shell opens;
- cached bootstrap for user A + persisted session for user B → A cache is rejected/hidden;
- definitive session/profile rejection does not retain protected cached access;
- password-change-required cached state cannot expose protected content.

### SQLite/cache

- v1 workout DB migrates to the new version without losing active workout/set drafts;
- owner-scoped snapshot round-trip for bootstrap, Week and Progress;
- coherent generation commit does not expose partial failed refresh;
- malformed/wrong-schema/wrong-owner snapshot is rejected safely.

### Home

- cached Home is available offline;
- network failure after cached render does not blank Home;
- pull-to-refresh invokes and awaits real synchronization;
- offline refresh stops spinner and preserves cached rank/content;
- mounted Home Rank N → synchronized Rank N+1 displays N+1 without navigation, restart, or root app recreation;
- existing rank transition behavior remains event-driven.

### Week

- cached current schedule/wallet visible offline;
- refresh failure preserves cached schedule;
- offline swap mutation is not applied locally and surfaces an internet-required failure.

### Progress

- cached authoritative Progress visible offline;
- refresh failure preserves cached progress;
- no fabricated local RR/XP ledger entries.

### Account isolation/logout

- user A cache exists; user B signs in; A Home/Week/Progress/bootstrap never appears;
- pending A workout data survives logout/session loss according to owner quarantine policy and remains hidden from B;
- same owner reauthentication can resume owned pending work.

### Regression

- normal online login/bootstrap works;
- normal online Home, Week and Progress work;
- online workout start remains required;
- active-workout set durability/sync remains intact;
- swap semantics remain intact;
- fixture routes remain deterministic;
- TASK-IMP-009 rank motion remains intact.

## Physical acceptance

1. Sign in online.
2. Load Home, Week and Progress at least once.
3. Enable airplane mode.
4. Kill Stone Set.
5. Reopen Stone Set.
6. Home loads cached rank/data.
7. Week loads cached schedule.
8. Progress loads cached authoritative snapshot.
9. Pull Home to refresh offline.
10. Existing content remains visible and refresh completes cleanly.
11. Restore internet.
12. Pull Home to refresh.
13. Current authoritative rank/RR appears while Home remains mounted.
14. No application restart is required.

## Verification

Before merge:

- Dart format/analyze and targeted unit/widget tests;
- full affected mobile test suite;
- sqflite migration/recreation tests;
- account-isolation tests;
- Home mounted-rank regression test;
- repository/link/task/audit checks;
- `git diff --check` equivalent diff inspection;
- Foundation CI final-head checks;
- API-24 lane when activated by ADR-0007 classification;
- Android release compile/signing gates as activated;
- no secret/private-data leakage.

After merge to `main`:

- verify Foundation CI for the exact main commit;
- verify Private Android Distribution triggers for the mobile-relevant diff;
- record released version/build/Firebase release ID and safe APK integrity evidence;
- perform the physical acceptance flow on the tester device when external device access is available.

## Expected implementation areas

```text
apps/mobile/lib/features/identity/...
apps/mobile/lib/features/sync/... or equivalent repository-native coordination area
apps/mobile/lib/features/workout/data/...
apps/mobile/lib/features/workout/providers/...
apps/mobile/lib/features/home/...
apps/mobile/lib/features/week/...
apps/mobile/lib/features/progress/...
apps/mobile/lib/features/shell/...
apps/mobile/test/...
docs/context/...
docs/product/...
docs/tasks/TASK-IMP-013A.md
```

Generated Riverpod/router files are updated only when source annotations/routes require regeneration.

## Risks

- cached bootstrap accidentally bypassing definitive auth/profile/compatibility state;
- mixed-owner or mixed-generation snapshot leakage;
- SQLite migration damaging an active workout draft;
- Home refetch order reading stale rank before pending workout sync completes;
- provider autoDispose/invalidation preventing mounted Home from observing the new generation;
- swap UI appearing locally successful while offline;
- lifecycle synchronization causing duplicate concurrent refreshes;
- over-broad logout cleanup deleting pending owner work;
- release regression from touching unrelated Android signing/distribution files.

Mitigate with owner checks, single-flight synchronization, transactional snapshot promotion, explicit mutation boundaries, migration tests, and no release-pipeline edits.

## Completion report

Return:

- Verdict: COMPLETE | PARTIAL | FAIL
- Task ID
- Final main commit
- Implementation branch and final implementation commit
- PR
- ADR
- SQLite changes
- Mobile/server changes
- Sync coordinator
- Offline bootstrap
- Cached Home/Week/Progress
- Home pull-to-refresh
- Rank refresh without restart
- Account isolation
- Tests/API-24/Foundation CI
- Private Android Distribution version/build/Firebase release ID
- Known residual risks
- Remaining Codex work
- Exact next action