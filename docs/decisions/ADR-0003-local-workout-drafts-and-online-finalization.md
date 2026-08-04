# ADR-0003: Local workout drafts and online authoritative finalization

## Status

Accepted

- Date: 2026-08-04
- Type: Client persistence, synchronization, and data integrity
- Supersedes: None
- Preserves: ADR-0002 server authority, immutable ledgers, schedule locking, and `rank-v6`

## Context

Workout entry must survive app interruption and temporary connectivity loss. At the same time, schedule locks, swaps, RR, XP, PR validation, penalties, and weekly finalization cannot be safely authored offline by an untrusted client.

A fully offline-first score engine would create conflict-resolution, fraud, clock, duplication, and historical-recalculation risks that are disproportionate for a two-user MVP.

## Decision criteria

- no lost set entries after interruption;
- no client-authored score totals;
- deterministic conflict handling;
- low battery and background-processing cost;
- explicit pending and synchronized states;
- cross-account privacy on a shared device;
- bounded implementation complexity;
- future ability to extend offline behavior without rewriting server records.

## Options considered

### Option A — Fully online workout entry

Advantages:

- simplest consistency model;
- every operation immediately reaches the server.

Disadvantages:

- a network interruption can lose active workout data or make the app unusable in a gym.

### Option B — Fully offline-first workouts and finalization

Advantages:

- maximum disconnected capability.

Disadvantages:

- offline schedule locking conflicts with swaps and date boundaries;
- client clocks and duplicate submissions become authoritative inputs;
- RR and weekly finalization require complex reconciliation;
- unnecessary complexity for the MVP.

### Option C — Online start, local continuation, online finalization

Advantages:

- the server establishes the valid session and locks the schedule item;
- set entry survives connectivity loss;
- the server remains authoritative for completion and rewards;
- synchronization is idempotent and explainable.

Disadvantages:

- a workout cannot start without connectivity;
- rewards remain pending until synchronization succeeds.

## Decision

Stone Set adopts Option C.

### Local persistence technology

- The Android mobile app uses SQLite through Flutter's `sqflite` package.
- SQLite stores active workout drafts, set entries, cached plan snapshots, and a synchronization outbox.
- SQLite does not store passwords, service-role keys, database passwords, or authoritative rank totals.
- Local schema changes are versioned and tested.

### Session start boundary

Starting a workout requires connectivity.

The backend atomically:

1. confirms the plan item is current, unlocked, and owned by the authenticated user;
2. creates or returns the idempotent session record;
3. locks the plan item;
4. returns the immutable prescription snapshot, session ID, and server start timestamp.

An offline client may view a cached workout but cannot create an authoritative session start, swap days, or change protection state.

### Offline continuation

After a valid online start:

- the user may continue entering sets without connectivity;
- every set edit and session-state transition is transactionally autosaved locally;
- autosave occurs immediately after a completed edit, with UI keystrokes debounced by no more than 500 milliseconds;
- one account may have at most one active workout session;
- the local draft is keyed by authenticated user ID and server session ID;
- the cached prescription is immutable for that session.

### Outbox and synchronization

Each outbound mutation stores:

```text
outboxItem = {
  idempotencyKey,
  userId,
  sessionId,
  mutationType,
  payloadVersion,
  payload,
  createdAtLocal,
  retryCount,
  lastAttemptAt,
  lastError
}
```

Synchronization runs when:

- the app returns to the foreground;
- connectivity is regained;
- the user taps retry or submit;
- the active screen performs an explicit refresh.

Stone Set does not use continuous five-minute polling or an always-running background timer. Background behavior must respect mobile battery and operating-system limits.

### Completion and reward boundary

Ending a session offline creates a local `pending_submission` state.

Until the backend accepts the idempotent submission:

- the workout is not finalized;
- RR, XP, PRs, consistency, and penalties are not committed;
- the UI displays pending synchronization rather than a fabricated award;
- the user cannot edit the server-authoritative rank result.

The backend validates the stored prescription, sets, timestamps, completion, logging, duplication, PR evidence, and configuration versions before returning the authoritative result.

### Week-close grace

A session started online before its plan item locked may synchronize after the week boundary.

```text
pending-session synchronization grace = 24 hours after Sunday 23:59
```

Weekly finalization waits until the earlier of:

- all started sessions are resolved; or
- the 24-hour grace expires.

A draft not synchronized by the deadline resolves under the normal missed/invalid rules unless an auditable correction is later approved.

### Logout and account switching

MVP does not support silent multi-account switching.

When unsynchronized data exists, logout is blocked until the user chooses one of:

1. synchronize now;
2. remain signed in;
3. explicitly discard the local draft.

After successful sync or explicit discard, cached private data for that user is removed. A different account cannot read the previous user's local draft.

## Consequences

### Positive

- active workouts survive app termination and network loss;
- server schedule locking remains reliable;
- rank and wallet integrity remain centralized;
- synchronization behavior is testable and idempotent;
- local complexity is bounded to draft and outbox state.

### Negative

- users need connectivity to start a session;
- rewards can remain pending after a disconnected workout;
- SQLite migrations and recovery require their own tests;
- logout requires explicit handling when data is unsynchronized.

## Security, privacy, data, and operational impact

- The local database remains inside the application sandbox.
- It contains private workout data but no backend secrets.
- Cross-user access is prevented through user scoping and logout cleanup.
- Server timestamps and stored configuration versions control finalization.
- Client clock values are evidence only and never the sole basis for awards.
- Duplicate retries must return the existing server result rather than create new transactions.

## Scope boundaries

This ADR does not authorize:

- offline workout start;
- offline swaps or routine publication;
- client-side RR or XP finalization;
- background push infrastructure;
- arbitrary server conflict merging;
- package installation outside an approved implementation task;
- iOS local-persistence implementation in the initial release.

## Rollback or supersession rule

A later ADR may allow offline session start only if it defines secure schedule reservations, clock validation, conflict precedence, abuse controls, and migration from existing server-started sessions.

A different local database requires a migration and recovery plan for active drafts.

## Activation evidence

`TASK-PL-002` accepts this architecture. Runtime activation requires the relevant bounded implementation task and tests.