# TASK-IMP-006 — Authoritative RR, XP, rank, wallet and Progress

Status: `APPROVED — EXECUTABLE`

Mode: `FAST PRIVATE TWO-USER MVP`

TASK-IMP-004 and TASK-IMP-005A are merged. TASK-IMP-005B is deliberately not a prerequisite for scoring and remains deferred. This packet is executable immediately.

## Objective

Implement the smallest complete scoring/progress vertical:

```text
stored weekly allocations + submitted workout results
→ lazy authoritative scoring refresh
→ RR / XP ledgers + account snapshot
→ rank derived from rank-v6 thresholds
→ Home uses real rank / RR / XP
→ Progress shows totals, rank ladder and workout/reward history
→ weekly swap can fall back to 5 RR when free credits are unavailable
```

No production-grade scoring engine is required.

## Reuse

Reuse:

- `training_week_items.allocated_rr`
- `training_week_items.allocated_base_xp`
- `training_week_items.allocated_missed_penalty_rr`
- `workout_sessions`
- `workout_results`
- `free_swap_wallets`
- the 20 rank thresholds already defined by `StoneSetRankAssets`

Do not create a second incompatible rank ladder.

## Database

Add one migration after the 005A migration.

Minimum tables:

- `rank_accounts`
- `rr_ledger`
- `xp_ledger`

Optional only if it makes the implementation simpler:

- `rank_events`

Do not add milestone/streak/weekly-evaluation/config-history tables.

### Account

One row per user:

```text
user_id
rr_balance
lifetime_xp
rank_id
updated_at
```

The account is a cached authoritative snapshot derived from append-only ledgers.

## Rank thresholds

Use exactly the existing presentation thresholds:

```text
bronze_i       0
bronze_ii      100
bronze_iii     200
silver_i       325
silver_ii      475
silver_iii     650
gold_i         825
gold_ii        1025
gold_iii       1250
platinum_i     1500
platinum_ii    1775
platinum_iii   2075
diamond_i      2400
diamond_ii     2750
diamond_iii    3125
elite           3525
champion        3950
apex            4400
prodigy         4900
adonis          5500
```

Rank is based on current RR balance, clamped at zero minimum.

No rank decay in this packet.

## Scoring rule

Keep scoring deterministic and simple.

### Submitted workout

For a workout result:

```text
completion_ratio = completed_sets / planned_sets
RR earned = floor(allocated_rr * completion_ratio)
XP earned = floor(allocated_base_xp * completion_ratio)
```

A fully completed workout receives the full allocation.

A partial result receives proportional RR/XP.

Each workout result may create reward entries only once.

### Missed workout

For a workout plan item whose assigned date is before the user's local current date and that has no submitted workout result:

```text
RR delta = -allocated_missed_penalty_rr
XP delta = 0
```

Apply only once.

### Rest day

For a rest item whose assigned date is on or before the user's local current date:

```text
RR earned = allocated_rr
XP earned = allocated_base_xp
```

Apply only once.

No streak, consistency multiplier, top-up, bonus, decay or milestone logic.

## Lazy scoring refresh

Implement one narrow server helper/RPC equivalent to:

```text
get_progress_v1()
```

On every call:

1. require authenticated product user;
2. use their reward timezone;
3. ensure rank account exists;
4. scan eligible unprocessed workout results/rest days/missed past workouts;
5. append missing ledger entries idempotently;
6. recalculate account RR/XP from ledgers;
7. derive current rank from rank-v6 thresholds;
8. return account + recent RR/XP transactions + workout history + rank ladder.

No cron.

No weekly finalization table.

No provisional state.

No background scoring worker.

## Ledger

Minimum RR entry fields:

```text
id
user_id
source_type
source_id
delta
created_at
```

Minimum XP entry fields are the same.

Use a uniqueness rule such as:

```text
(user_id, source_type, source_id)
```

so retries cannot double-score.

Expected RR source types:

```text
workout_reward
rest_reward
missed_workout
paid_swap
```

Expected XP source types:

```text
workout_reward
rest_reward
```

Ledgers are append-only to authenticated clients. Mutations happen only through trusted functions.

## Paid swaps

Update the current swap confirmation server function in this new migration.

Behavior:

```text
if free_swap_wallet.balance > 0:
  consume 1 free credit
else:
  refresh scoring
  require rr_balance >= 5
  append rr_ledger delta -5 source_type paid_swap
```

Then perform the same date swap and weekly two-swap limit already implemented in Phase 4.

If RR is insufficient:

```text
paid_swap_insufficient_rr
```

Do not build a payment-choice screen. Free credit is used first; otherwise 5 RR automatically.

## Domain/data

Add only the minimum contracts:

```text
RankAccount
RankDefinition
ProgressTransaction
WorkoutHistoryItem
ProgressSnapshot
ProgressRepository
```

Repository method:

```text
getProgress()
```

Keep decoding simple and immutable.

## Android Home

Replace fixture-only values for normal authenticated Home:

- rank ID
- RR
- rank progress
- lifetime XP

Keep any unrelated fixture-only metrics that are not implemented.

The rank asset/presentation layer remains unchanged.

Do not redesign Home.

## Android Progress

Replace `/progress` placeholder with one useful screen containing:

- current rank card;
- RR balance;
- lifetime XP;
- progress to next rank;
- rank ladder list;
- recent reward/penalty transactions;
- submitted workout history with date/status/completed sets.

No charts.

No exercise PR graphs.

No calendar heatmap.

No correction UI.

No complex filters.

## Week swap UI

Existing free-credit UI may remain mostly unchanged.

When free credits are zero, allow confirmation if the server can charge RR and label the action clearly, for example:

```text
Use 5 RR
```

If insufficient RR, show a readable error.

Do not build a wallet/payment modal.

## Explicit exclusions

Do not implement:

- 005B guidance/media playback;
- streaks;
- multipliers other than implicit 1.0x;
- milestones;
- PR detection/caps;
- rank decay;
- weekly evaluation/finalization tables;
- cron/catch-up jobs;
- provisional rewards;
- reward reversal/corrections;
- progression recommendations;
- exercise charts;
- dashboard scoring UI;
- production hardening;
- 007 or 008.

## Minimal tests

Database:

- workout reward scores once;
- partial workout scores proportionally;
- rest reward scores once;
- missed past workout penalty scores once;
- rank threshold changes correctly;
- lazy refresh is idempotent;
- paid swap uses free credit first;
- zero free credit consumes exactly 5 RR;
- insufficient RR rejects paid swap;
- cross-user account/ledger reads denied.

Dart/data:

- progress decoding;
- rank decoding;
- repository happy path/error mapping.

Mobile:

- Progress renders authoritative snapshot;
- Home uses real rank/RR/XP;
- paid-swap label/error state.

No broad new golden/security/performance suite.

## Verification

During implementation use focused tests only.

Final external verification may use the existing Foundation CI once after the branch is ready.

Do not add new CI infrastructure.

## Completion

COMPLETE when one user can:

```text
submit workout
→ refresh Home/Progress
→ see RR + XP reflected
→ see rank derived from RR
→ see workout/reward history
→ use a free swap when available
→ otherwise pay 5 RR for a swap
```

and repeated refreshes do not duplicate rewards/penalties.
