# Stone Set End-to-End Application Workflow

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT WORKFLOW`
Tasks: `TASK-PD-008`, `TASK-PL-002`

## Product surfaces

### Android Flutter app

- sign-in;
- week, rank, wallet, and history;
- online workout start;
- workout timers and set entry;
- SQLite local draft recovery and synchronization;
- swaps and payment selection;
- pending, provisional, and finalized results;
- progression, protection, and corrections.

### Flutter Web dashboard

- private routine drafting;
- hard validation feedback;
- submission for independent review;
- approval or rejection without reviewer edits;
- publication preview, future activation, and history.

### Supabase backend

- identity and sessions;
- RLS-protected records;
- routine validation, review, and publication;
- weekly plans and locks;
- workout synchronization;
- server-authoritative rewards, wallet, penalties, corrections, and finalization.

## 1. Account provisioning and sign-in

1. An operator creates the two initial Supabase Auth users.
2. Each user receives a linked profile.
3. Public registration remains disabled.
4. Mobile and dashboard sessions use authenticated publishable-client access.
5. One ordinary user cannot read or mutate another user's private records.

## 2. Routine draft, validation, and review

1. The user creates a draft in the dashboard.
2. The draft is editable only by its author.
3. The server runs `routine-validator-v1` and returns structured hard errors.
4. A valid draft is submitted with an immutable content hash.
5. A different authorized user reviews the exact submission.
6. The reviewer may approve or reject and leave a note; the reviewer cannot edit the draft.
7. Self-approval is rejected server-side.
8. Approval stores the reviewer, validator result, content hash, and timestamp.
9. Publication reruns validation and verifies that the approved hash still matches.
10. Publication creates an immutable version effective on a future unlocked Monday.
11. Rejection leaves the current published version active.
12. Every reward-bearing change requires a new reviewed version in MVP.

## 3. Weekly materialization

At or before the reward week:

1. materialize any due monthly free-swap grant idempotently;
2. select the approved published routine version effective for the week;
3. create seven dated plan items;
4. store routine, validator, rank, scheduling, and timezone versions;
5. allocate daily RR, base XP, and workout penalties deterministically;
6. store immutable base schedule and pre-lock current schedule.

Later routine changes cannot rewrite a materialized week.

## 4. Mobile home

The authenticated home screen shows:

- today's workout or rest item;
- seven-day schedule and lock states;
- swaps used and remaining;
- free-swap balance;
- rank, RR, lifetime XP, multiplier, and progress;
- pending synchronization and provisional transactions;
- the next valid action.

## 5. Swap workflow

1. User selects two distinct unlocked dates.
2. Backend validates ownership, active week, locks, and remaining allowance.
3. UI previews both items, resulting order, warnings, credits, and `Pay 5 RR` option.
4. User explicitly chooses one payment instrument.
5. Backend atomically exchanges complete plan-item identities, consumes the allowance and payment, and writes audit records.
6. Canceled preview changes nothing.
7. Swapping back is another valid paid or credited swap.

## 6. Workout start

Starting requires connectivity.

1. User opens today's workout.
2. Client requests a session start with an idempotency key.
3. Backend verifies the item is owned, current, unlocked, and reward eligible.
4. Backend creates or returns the session, locks the item, and returns:
   - server session ID;
   - server start timestamp;
   - immutable prescription snapshot;
   - previous comparable results and recommendation evidence.
5. Mobile creates the SQLite local draft keyed by user and session.
6. Session and rest timers start.

An offline client may view a cached prescription but cannot authoritatively start a new session.

## 7. Set entry and offline continuation

For each working set, the user records exercise variant, load where applicable, repetitions, RIR, status, and optional note or pain flag.

- Every completed edit is transactionally autosaved to SQLite.
- UI keystrokes may debounce for at most 500 milliseconds.
- Outbox mutations carry stable idempotency keys and payload versions.
- A valid started workout may continue without connectivity.
- Sync occurs on foreground, connectivity regain, explicit retry, and final submit.
- Stone Set does not run continuous periodic polling.
- The cached prescription cannot be altered for the active session.

## 8. Session completion

### Online completion

1. Client synchronizes pending mutations.
2. Client submits final state idempotently.
3. Backend validates prescription, sets, timestamps, completion, logging, duplication, PR evidence, and configuration versions.
4. Backend returns the authoritative completed, partial, invalid, protected, or correction-pending state and stored provisional transactions.

### Offline completion

1. Mobile records local `pending_submission`.
2. No authoritative RR, XP, PR, rank, or consistency result is shown.
3. UI displays pending synchronization.
4. On reconnection, the outbox and final submission synchronize idempotently.
5. Duplicate retries return the existing server result.

### Week-close grace

A session started before its item locked has 24 hours after Sunday 23:59 in the reward timezone to synchronize. Weekly finalization waits for started sessions until resolution or grace expiry.

## 9. Rest items

- A programmed rest item remains visible.
- No manual completion check-in is required.
- It finalizes automatically at local day close and earns its stored lower allocation.
- It has no PR or missed penalty.
- Unscheduled training on that date earns no extra RR or XP.

## 10. Weekly finalization

After the week and pending-session grace:

1. freeze the final post-swap schedule;
2. apply approved protections and corrections;
3. resolve all seven plan items;
4. apply direct missed-workout penalties;
5. calculate workout-completion ratio;
6. classify perfect, non-perfect, failed, or protected;
7. increment, freeze, or reset consistency;
8. apply multiplier top-ups, milestones, perfect-week bonus, and failed-week decay;
9. store immutable schedule, wallet, rank, and evaluation snapshots.

Finalization is idempotent.

## 11. Logout and account privacy

If unsynchronized data exists, logout requires:

- synchronize now;
- remain signed in; or
- explicitly discard the draft.

After sync or discard, private local data for that account is removed. Silent account switching with another user's draft is not supported.

## 12. Progression, protection, and corrections

- Progression recommendations use comparable exercise history and double progression.
- Recommendations never silently mutate a published routine.
- Pain flags stop automatic progression for the movement and do not provide medical diagnosis.
- Protected events require an auditable reason.
- Backdated corrections reverse exact stored values and preserve transaction history.

## 13. History

Users can inspect routine versions and reviews, weeks and swaps, workout sets, PR evidence, RR/XP transactions, wallet grants and consumption, penalties, decay, milestones, protection, corrections, and every configuration version used.

## MVP exclusions

- public signup;
- iOS;
- coach or organization accounts;
- cross-user routine editing;
- social, nutrition, sleep, payment, wearable, or medical-diagnosis features;
- offline workout start;
- client-side score finalization;
- historical recalculation from current formulas.
