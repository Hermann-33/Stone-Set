# TASK-IMP-013A — Cached mobile shell, synchronization and Home refresh

Updated: 2026-08-13
Status: `PARTIAL`
Branch: `agent/task-imp-013a-offline-cache`
Decision: `ADR-0010`
Pull request: `#47`

## Current verdict

The runtime implementation is complete and the exact implementation candidate passed Foundation CI, including the full affected mobile test suite, Android release APK build and Android API 24 profile lane. The task remains `PARTIAL` because canonical documentation is being finalized, the PR is not yet merged, exact-main CI/private distribution have not yet been verified, and the required physical Android airplane-mode acceptance flow still needs a real device.

```text
starting main                    b9e7d02cf51f96e89b70b30e758d4c5a6b8175bd
implementation branch            agent/task-imp-013a-offline-cache
green implementation head        51474a6e8d3157bfbdad9c9e1de3fa57a468a758
pull request                      #47 — OPEN / DRAFT
Foundation CI                     run 31621647343 (#365) — PASS
Documentation/repository checks   PASS
Formatting                        PASS
Strict static analysis            PASS
Mobile deterministic goldens      PASS
Mobile tests                      PASS
Android release APK               PASS
Android release rank bundle       PASS
Android API 24 profile            PASS
Supabase migration                none
New dependency                    none
Fresh Firebase release            pending merge/main distribution
Physical device acceptance        pending real Android device
```

Historical Firebase release `0.1.0 / 1000062 / 5j1j4rhquebu0` belongs to TASK-IMP-012 and is not evidence for this task.

## Objective

Make the Android application useful without connectivity after one successful online authentication/bootstrap, using owner-scoped SQLite snapshots and one synchronization coordinator. Home, Week and Progress render cached authoritative state offline. Home pull-to-refresh awaits real synchronization and updates rank/RR while Home remains mounted.

Offline-created workout sessions and reconciliation remain explicitly deferred to TASK-IMP-013B. ADR-0003 continues to require an online authoritative workout start.

## Mandatory repository reads

Before modifying this task, read:

1. `AGENTS.md`;
2. `docs/context/ACTIVE_CONTEXT.md`;
3. `docs/context/ARCHITECTURE.md`;
4. `docs/context/CODEBASE_MAP.md`;
5. `docs/context/WORKFLOW.md`;
6. `docs/context/HANDOFF.md`;
7. `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`;
8. `docs/decisions/ADR-0003-local-workout-drafts-and-online-finalization.md`;
9. `docs/decisions/ADR-0007-path-sensitive-ci-gates.md`;
10. `docs/decisions/ADR-0009-private-android-app-distribution.md`;
11. `docs/decisions/ADR-0010-offline-first-mobile-cache-and-synchronization.md`.

## Verified starting state

Before implementation:

```text
local database                   stone_set_workout.db v1
local workout tables             active_workouts, workout_set_drafts
read snapshot cache              none
central mobile sync coordinator  none
cold offline restored session    unable to expose cached protected shell
Home live data                    fixture base + direct Week/Progress reads
Home pull-to-refresh              none
workout start                     online only
server authority                  Supabase
```

## Implemented scope

### SQLite owner-scoped cache

The existing mobile database is versioned from v1 to v2 without replacing the workout database. The migration preserves `active_workouts` and `workout_set_drafts` and adds:

```text
mobile_snapshots
mobile_sync_state
```

Snapshots are keyed by immutable owner UUID and snapshot key, carry schema/generation/freshness metadata, and are decoded with owner validation. Week and Progress are promoted as a coherent generation so a failed partial refresh cannot replace the last good generation.

Primary implementation areas:

```text
apps/mobile/lib/features/local/data/mobile_local_database.dart
apps/mobile/lib/features/local/data/mobile_snapshot_store.dart
apps/mobile/lib/features/local/data/mobile_snapshot_codec.dart
apps/mobile/lib/features/local/data/sqflite_mobile_snapshot_store.dart
apps/mobile/lib/features/local/providers/mobile_local_providers.dart
```

### Cached authentication/bootstrap

`MobileSessionController` now:

- stores a successful fully authenticated bootstrap best-effort;
- recovers the persisted Supabase session locally on cold start;
- loads only the matching owner-scoped cached bootstrap before network refresh;
- can expose the previously verified protected shell without requiring a successful network call first;
- rejects wrong-owner cached bootstrap data;
- never uses cached password-change-required, disabled/access-denied, maintenance or incompatible state as authorization;
- preserves an authenticated cached shell across transient transport failures;
- signs out on definitive session rejection.

First-ever authentication remains online-only.

### Central synchronization coordinator

`MobileSyncController` is the single-flight synchronization boundary. Its authoritative sequence is:

1. resolve current owner/session;
2. revalidate foreground authentication;
3. stop on changed/invalid session;
4. synchronize supported pending workout edits;
5. fetch authoritative current Week/wallet;
6. fetch authoritative Progress/rank/history;
7. validate ownership;
8. atomically commit the cache generation;
9. publish synchronization metadata/generation.

Its state records owner, running state, last success/attempt, last recoverable failure, generation and pending mutation count. Failed reads preserve the prior good generation.

No polling timer and no new connectivity dependency were added.

### Offline Home, Week and Progress

- Home combines its existing presentation fixture base with cached authoritative Week and Progress data.
- Week is cache-first and preserves the prior cached schedule when refresh fails.
- Progress is cache-first and preserves the primary authoritative rank/history snapshot when secondary progression data is unavailable.
- The three surfaces observe synchronization generation changes rather than requiring application restart.
- No local RR, XP, wallet, rank or ledger transaction is fabricated.

### Pull-to-refresh and stale-rank regression

Home uses native `RefreshIndicator` behavior with always-scrollable semantics and awaits the synchronization coordinator. On failure it stops cleanly and preserves cached UI.

The regression test mutates authoritative Progress from PLATINUM II / 1910 RR to PLATINUM III / 2100 RR, performs a real pull gesture and proves the mounted Home displays the new rank/RR without recreating the `StatefulNavigationShell` or restarting the app.

Week and Progress also route manual refresh through the coordinator.

### Lifecycle synchronization

The authenticated shell is lifecycle-aware and requests best-effort synchronization:

- after cached shell startup;
- after sign-in/bootstrap through the authenticated state path;
- on app resume;
- from Home/Week/Progress manual refresh;
- after accepted workout completion through a best-effort callback.

### Workout and logout safety

- Existing active workout durability remains in the same SQLite database.
- Pending set edits synchronize before final Week/Progress reads.
- Post-submit synchronization failure cannot undo an accepted server workout submission.
- `UnsynchronizedPrivateWork` is connected to actual owner-scoped workout local state.
- Logout/session loss does not silently destroy pending owner work.
- Another account cannot see a previous owner's cache or pending workout state.

## Server/database changes

### Local SQLite

Implemented migration: `1 → 2`.

### Supabase

No Postgres, RPC, Auth policy, RLS or Storage migration was required. Existing server authority is reused unchanged.

## New dependencies

None.

## Protected behavior and non-goals

The implementation does not change:

- `rank-v6` thresholds or the 20-rank ladder;
- multiplier, perfect-week, penalty or PR reward rules;
- `schedule-v3`, swaps, free-credit/payment rules or complete-identity swap semantics;
- routine publication;
- authoritative workout/reward history;
- server authority for RR, XP, rank, wallet, consistency, penalties, PRs or finalization;
- offline workout start;
- offline authoritative swaps;
- exercise media or YouTube rules;
- Android application ID, signer identity or Firebase distribution architecture;
- CI thresholds or API-24 requirements.

## Acceptance criteria and evidence

### Bootstrap/cache

- first launch without a persisted session remains signed out — covered;
- matching verified cache can render before network refresh — covered;
- wrong-owner cache is rejected — covered;
- password-change-required cache cannot expose protected content — covered;
- local DB v1→v2 preserves workout tables — covered;
- bootstrap, Week and Progress codecs preserve owner/state and reject cross-owner payloads — covered.

### Synchronization/Home

- pending workout synchronization precedes Week/Progress reads — covered;
- failed refresh preserves prior generation — covered;
- Home pull-to-refresh updates rank on the mounted shell — covered;
- deterministic Home/rank goldens remain green — covered.

### Week/Progress/workout/logout

- Week server mutation semantics remain authoritative — covered by affected tests;
- cached Progress remains authoritative — covered by affected tests;
- workout local sync/submit regression tests pass — covered;
- authentication/logout/private-work widget tests pass with explicit test dependencies — covered.

### CI

Foundation CI run `31621647343` on exact head `51474a6e8d3157bfbdad9c9e1de3fa57a468a758` completed successfully. The affected path classification activated mobile, Android release and API-24 checks, and all applicable jobs passed.

## Physical Android acceptance — still required

On a real tester device:

1. install the fresh post-merge TASK-IMP-013A Firebase build;
2. sign in online and load Home, Week and Progress;
3. enable airplane mode;
4. kill Stone Set;
5. reopen Stone Set;
6. verify cached Home rank/data is visible;
7. verify cached Week schedule is visible;
8. verify cached Progress authoritative snapshot is visible;
9. pull Home to refresh while offline and verify existing content remains;
10. restore internet;
11. pull Home to refresh;
12. verify current authoritative rank/RR updates while Home remains mounted.

Do not claim this physical gate without real-device evidence.

## Remaining completion gates

1. Commit the canonical documentation evidence on the implementation branch.
2. Obtain Foundation CI success on that new exact documentation head.
3. Mark PR #47 ready for review.
4. Merge PR #47 using the exact green head.
5. Verify Foundation CI success for the exact resulting `main` commit.
6. Verify a fresh Private Android Distribution run and record its version/build/Firebase release ID plus safe signer/app identity evidence.
7. Complete the physical Android airplane-mode acceptance flow.

## Required documentation updates

Changed current facts must be reflected in:

- `docs/tasks/TASK-IMP-013A.md`;
- `docs/tasks/README.md`;
- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/HANDOFF.md`;
- `docs/context/CODEBASE_MAP.md`;
- active append-only audit log.

ADR-0010 remains the accepted durable design decision; no superseding ADR is required.

## Git requirements

- keep scope on `agent/task-imp-013a-offline-cache`;
- no unrelated formatting or generated churn;
- PR #47 must merge only from an exact-head successful Foundation CI result;
- verify the resulting exact `main` CI before claiming merge completion;
- do not reuse historical Firebase release evidence as fresh TASK-IMP-013A evidence.

## Completion report format

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
