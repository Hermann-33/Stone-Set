# ADR-0010: Offline-first mobile cache and synchronization coordination

## Status

Accepted

- Date: 2026-08-12
- Type: Mobile persistence, authentication continuity, synchronization, and data integrity
- Supersedes: ADR-0003 only where its local persistence scope is narrower than owner-scoped cached read snapshots and centralized synchronization
- Preserves: ADR-0002 server authority; ADR-0003 online workout-start boundary, local workout durability, and online authoritative finalization; ADR-0006 YouTube policy; ADR-0007 CI gates; ADR-0009 Android signing and distribution; `rank-v6`; `schedule-v3`

## Context

Stone Set already persists Supabase sessions and SQLite workout drafts, but Home, Week, and Progress currently depend on live Supabase reads. On a cold mobile launch the client recovers a local Supabase session and then requires a successful network refresh/profile bootstrap before exposing protected content. A transport failure therefore makes an already-bootstrapped user effectively unable to use the cached application.

The mobile Home rank can also remain stale while Home stays mounted because rank, week, workout synchronization, and refresh behavior are coordinated through independent provider invalidations rather than one completed synchronization boundary.

The product now requires a user who has authenticated and successfully bootstrapped online at least once to reopen the Android app without connectivity, see the last synchronized private state for the same owner, continue supported local work, and synchronize when connectivity returns. Server-authoritative rewards, rank, schedule mutations, and finalization must remain unchanged.

ADR-0003 explicitly excludes offline workout start. This ADR does not remove that boundary. Offline-created workout sessions and their reconciliation require a separate superseding decision after TASK-IMP-013A is stable.

## Decision criteria

- useful cold launch after a prior successful online bootstrap;
- no first-ever offline authentication or local password system;
- owner isolation on shared devices;
- cached reads render before network timeout;
- one coherent synchronization boundary for Home-related authoritative state;
- pending local workout mutations synchronize before rank/progress refresh;
- no client-authored RR, XP, rank, wallet, schedule, or reward finalization;
- no continuous polling or unnecessary connectivity dependency;
- process-death durability through SQLite;
- minimal change to existing Supabase RPCs and Android release architecture.

## Options considered

### Option A — Keep every private screen online-only

Rejected. It wastes the existing persisted session and SQLite architecture, prevents useful offline access after a valid bootstrap, and leaves Home refresh correctness dependent on process recreation.

### Option B — Add independent caches and refresh logic inside each screen

Rejected. It would duplicate network classification, create mixed freshness generations, scatter invalidations, and make account isolation harder to audit.

### Option C — Owner-scoped SQLite snapshots plus one mobile synchronization coordinator

Accepted. It extends the existing SQLite architecture, preserves server authority, supports cached-first rendering, and gives manual refresh/startup/resume a single awaited synchronization boundary.

## Decision

### Authentication continuity

- First-ever authentication and first successful profile/bootstrap verification require connectivity.
- Supabase Auth remains the only credential and session authority; Stone Set creates no local password or parallel identity system.
- After a successful online bootstrap, mobile persists the minimum owner-scoped verified bootstrap snapshot required to restore the authenticated shell offline.
- On later launch, the client first recovers the persisted Supabase session and loads only a bootstrap snapshot whose owner UUID matches that recovered session.
- The client attempts Supabase refresh/bootstrap when network service is usable.
- A transport/server-availability failure by itself does not prove the persisted session invalid and does not discard the same-owner cached shell.
- A definitive authentication, revocation, profile-disabled, profile-missing, or compatibility rejection still transitions safely to the existing authentication/access state and quarantines unsynchronized owner data as required.
- Password-change-required state may not be bypassed by a cached snapshot. A cached snapshot is eligible for offline protected access only after the account previously completed required password change and reached an authenticated state.

### Owner-scoped mobile snapshots

The Android app extends its existing SQLite persistence. No second database framework is introduced.

Snapshot records are owner scoped and versioned. The conceptual record is:

```text
owner_id
snapshot_key
schema_version
payload_json
server_updated_at
cached_at
generation_id
```

Initial keys may include:

```text
identity.bootstrap
week.current
progress.current
```

Home may be derived from the authoritative cached Week and Progress snapshots plus existing presentation models rather than duplicating the same data into a separate Home snapshot.

All cache reads and writes require the immutable Supabase user UUID. Another authenticated user can never read a previous owner's snapshot, workout draft, or pending mutation.

### Cached-first rendering

After same-owner persisted session recovery and eligible cached bootstrap:

```text
load local SQLite state
→ render authenticated shell and cached Home/Week/Progress
→ start best-effort synchronization
```

Cached content is explicitly stale/non-authoritative with respect to newer server state, but the last accepted server values remain authoritative for what is displayed. A failed refresh must not blank an already rendered cached screen.

### Synchronization coordinator

Mobile uses one coherent coordinator for synchronization state and refresh ordering. Individual widgets do not own unrelated network retry policy.

The coordinator publishes at least:

- whether synchronization is running;
- last successful synchronization time;
- pending local mutation count where available;
- last recoverable synchronization failure;
- whether the rendered snapshot is cached/stale or freshly synchronized.

For TASK-IMP-013A, synchronization order is:

1. establish the same local owner and eligible persisted session context;
2. revalidate/refresh Supabase session when possible;
3. stop protected network work on definitive authentication rejection;
4. flush supported pending active-workout mutations before final reads;
5. fetch authoritative current Week/wallet;
6. fetch authoritative Progress/rank/history;
7. verify every payload belongs to the current owner;
8. commit the successful read snapshots as one coherent local generation where practical;
9. update last-successful synchronization metadata;
10. publish the new generation to Riverpod consumers.

A partial authoritative read set is not promoted as a successful coherent generation. Existing cached data remains visible when a synchronization attempt fails.

### Synchronization triggers

Required triggers are:

- successful online sign-in/bootstrap;
- application startup after cached render;
- application resume;
- online workout synchronization/completion paths where already supported;
- Home pull-to-refresh;
- explicit retry.

Stone Set does not add continuous polling. A dedicated connectivity package is not required solely to predict reachability; the client attempts the real operation and classifies the result.

### Home pull-to-refresh

Home uses the platform-standard pull-to-refresh interaction. The indicator completes only after the synchronization coordinator completes or fails cleanly.

A successful refresh updates the mounted Home tree from the newly committed snapshot generation. Rank changes must not require application restart, navigation away, or root `MaterialApp` recreation. Existing event-driven rank transition behavior remains intact.

An offline refresh preserves cached Home/rank, stops the indicator, and publishes concise stale/offline synchronization status instead of replacing Home with a full-screen error.

### Week and Progress offline behavior

- Week displays the last synchronized materialized Week/wallet snapshot offline.
- Week swap confirmation remains server-authoritative and requires successful online communication; no offline authoritative swap is created.
- Progress displays the last synchronized authoritative account, rank ladder, ledger entries, and workout history offline.
- Mobile never fabricates provisional RR/XP transactions from cached or unsynchronized local work.

### Logout, session loss, and account switching

- Cached read snapshots are private owner data.
- Logout may hide/remove ordinary read snapshots according to product cleanup policy, but unsynchronized workout data is never silently destroyed.
- Session loss quarantines unsynchronized owner work for that owner.
- A different account cannot read, submit, or merge another owner's local data.

### Offline workout creation remains deferred

TASK-IMP-013A does not create an offline authoritative or provisional workout session before an online server start. ADR-0003's online workout-start boundary remains in force.

A future 013B decision must explicitly define idempotent client workout identity, schedule/version validation, state machine, process-death recovery, conflict preservation, abuse/clock handling, and server reconciliation before offline start is implemented.

## Consequences

### Positive

- previously authenticated users can reopen useful private mobile state without connectivity;
- Home, Week, and Progress no longer wait on network timeout before showing cached state;
- Home rank can update live after an awaited synchronization;
- freshness/error behavior is centralized and testable;
- owner isolation remains explicit at the persistence boundary;
- no new backend or local database framework is required.

### Negative

- SQLite schema/versioning and snapshot serialization expand;
- verified bootstrap data becomes additional private local data that must follow owner cleanup rules;
- sync generation and failure semantics add mobile state complexity;
- server changes that invalidate cached schema require versioned cache handling;
- a stale cached shell can be shown until the server becomes reachable, so the UI must clearly communicate freshness without implying current server validation.

## Security, privacy, data, and operational impact

- Snapshot rows contain private profile/schedule/progress data but no password, service-role key, database password, or authoritative client-owned score state.
- Owner UUID is mandatory in every cache key/query and validated against payload ownership where models carry an owner.
- Cached bootstrap cannot elevate privileges and cannot override a definitive later server rejection.
- Supabase RLS remains authoritative for every network read/write.
- No Firebase runtime datastore, Firestore, Hive, Isar, Realm, or new backend is introduced.
- YouTube remains online-only and is never downloaded or rehosted.
- Existing permanent Android signing and Firebase App Distribution trust boundaries are unchanged.

## Scope boundaries

This ADR authorizes architecture for TASK-IMP-013A only. It does not authorize:

- offline workout start or offline-created session reconciliation;
- offline swaps, routine publication, protection changes, or corrections;
- client-side RR, XP, rank, wallet, penalty, PR, or consistency finalization;
- weakening RLS or adding client writes to ledgers;
- continuous polling or an always-running background service;
- another local database framework;
- offline YouTube playback;
- Android signing/distribution changes.

## Rollback or supersession rule

If cached-shell restoration proves unsafe, the client may temporarily fall back to online bootstrap while preserving owner-scoped snapshots for recovery; disabling cached rendering must not delete unsynchronized workout data.

Any future offline workout-start design must supersede ADR-0003's session-start boundary and this ADR's explicit 013A exclusion with a migration/reconciliation decision.

A replacement persistence framework requires an ADR covering migration of snapshots, active drafts, pending mutations, owner isolation, and rollback.

## Activation evidence

TASK-IMP-013A is the bounded implementation packet. Runtime activation requires its SQLite migration, cache/session adapters, synchronization coordinator, Home/Week/Progress integration, regression tests, final-head CI, and private Android distribution evidence.