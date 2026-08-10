# TASK-IMP-007 — Progression, substitutions, protection and corrections

Status: `IMPLEMENTED — VALIDATING`
Mode: `FAST TWO-USER MVP`
Branch: `codex/task-imp-007-progression-protection-corrections`

## Objective

Turn submitted workout evidence into a simple next-workout recommendation and give the user only the controls needed to override it, prefer a substitute exercise, pause progression for an exercise, flag pain without diagnosis, and correct/reverse RR or XP mistakes.

This packet intentionally does **not** implement a coaching engine, deload algorithms, periodization, automatic routine mutation, medical advice, full-week protection, complex substitution scoring, or enterprise audit workflows.

## Existing inputs to reuse

Do not duplicate existing data:

- `routine_version_prescriptions` already owns working sets, rep range, RIR target, load unit and exercise/guidance identity;
- `workout_sessions`, `workout_session_exercises` and `workout_set_entries` already preserve actual performed sets;
- `workout_results` already records completed/partial submissions;
- `rr_ledger`, `xp_ledger` and `rank_accounts` already provide authoritative progress balances;
- exercise definitions and immutable guidance revisions already exist;
- existing Auth/RLS ownership remains authoritative.

## Aggressive simplification

Implement only:

1. one owner-scoped settings row per exercise;
2. one deterministic recommendation rule;
3. preferred substitute applied at the next workout start;
4. exercise-level progression protection only;
5. a boolean pain flag plus optional note, with no diagnosis or treatment advice;
6. manual next-load override without mutating a published routine;
7. one correction table plus exact RR/XP reversal entries;
8. one mobile Progression section inside the existing Progress experience;
9. focused database/data/mobile tests only.

## Database

### `exercise_progression_settings`

One row per `(user_id, exercise_definition_id)`:

- `progression_protected boolean not null default false`
- `pain_flagged boolean not null default false`
- `preferred_substitute_exercise_id uuid null`
- `manual_next_load numeric(10,3) null`
- `note text not null default ''`
- `updated_at timestamptz`

Constraints:

- owner exercise and substitute must belong to the same user;
- an exercise cannot substitute itself;
- manual load is null or non-negative;
- note length <= 500;
- direct client mutation is denied; owner reads plus RPC mutation only.

### `progress_corrections`

Append-only correction records:

- `id uuid`
- `user_id uuid`
- `kind text check ('rr','xp')`
- `delta integer not null check (delta <> 0)`
- `reason text not null`
- `reverses_correction_id uuid null`
- `created_at timestamptz`

Rules:

- a correction can be reversed once;
- reversal delta is exactly the negative of the original;
- reversal is another immutable correction row;
- no delete/update correction API.

Extend ledger source types with `manual_correction`.

For XP, allow correction ledger deltas to be negative; account totals still clamp at zero.

## Recommendation rule

Server-authoritative and deliberately simple.

For each exercise in the latest effective published routine:

1. If `progression_protected = true` → recommendation state `protected`.
2. Else if `pain_flagged = true` → state `hold`, reason `pain_flagged`.
3. Else if `manual_next_load` is set → state `override`, suggested load = override.
4. Else find the latest submitted **comparable** performance for that original prescription exercise.
5. Comparable means:
   - same original exercise definition;
   - same load unit;
   - workout session used that same exercise rather than a substitute;
   - at least one completed set exists.
6. Numeric load increase is allowed only when:
   - the workout result is `completed`;
   - every prescribed working set is completed;
   - every completed set has repetitions >= `rep_max`;
   - every completed set has RIR >= `rir_target`;
   - all completed sets use one numeric load value.
7. Increase amount:
   - `kg`: +2.5
   - `lb`: +5
8. Otherwise hold the latest comparable numeric load.
9. `bodyweight` / `none`: never invent a numeric load; return `hold` unless protected/override semantics apply.
10. If no comparable evidence exists → `no_data`.

No streaks, fatigue model, percentage jumps, deloads or multi-session smoothing.

## Preferred substitution

A setting may point to another active owner exercise.

At `start_workout_v1` only:

- if the original exercise has a preferred substitute, use the substitute exercise in the workout-session exercise row;
- use the substitute's latest immutable guidance revision;
- preserve routine/prescription immutability;
- do not mutate the published routine;
- recommendation comparability for that performed exercise is false for the original prescription, because the effective session exercise differs from the original prescription exercise.

If a substitute has no guidance revision, reject the setting when it is saved rather than failing workout start.

No substitution equivalence scores or muscle-match engine.

## RPCs

### `get_progression_v1()`

Returns:

- recommendation rows for exercises in the latest effective routine;
- current exercise settings;
- active owner exercise options for substitution;
- recent correction history (latest 50).

### `update_progression_setting_v1(...)`

Single upsert/clear mutation for:

- protection;
- pain flag;
- preferred substitute;
- manual next-load override;
- note.

### `apply_progress_correction_v1(kind, delta, reason)`

- inserts immutable correction;
- inserts matching RR/XP ledger entry;
- refreshes rank account;
- returns updated progress account/correction.

### `reverse_progress_correction_v1(correction_id, reason)`

- validates ownership;
- rejects duplicate reversal;
- inserts opposite immutable correction + ledger entry;
- refreshes account;
- returns updated progress account/correction.

`start_workout_v1` is replaced only as needed to honor preferred substitutions.

## Mobile

Keep UI inside the existing Progress branch.

Add a `Progression` section with simple cards:

- exercise name;
- recommendation: Increase / Hold / Protected / Override / No data;
- latest comparable load when available;
- suggested next load when available;
- short `Why?` explanation;
- Protect toggle;
- Pain flag toggle;
- optional note;
- next-load override set/clear;
- preferred substitute select/clear.

Add a compact `Corrections` action from Progress:

- choose RR or XP;
- signed integer amount;
- reason;
- recent correction rows;
- Reverse action on unreversed original corrections.

No dashboard UI in this phase.

## Tests

### Database

Focused pgTAP only:

- recommendation increase case;
- hold case;
- protected case;
- manual override case;
- substitute setting validation;
- substitution applied at workout start;
- substituted performance excluded from original comparability;
- correction applies exact RR/XP delta;
- reversal applies exact opposite delta once;
- cross-user reads/mutations denied;
- repeated read is idempotent.

### Dart/data

- payload decoding;
- mutation parameter mapping;
- invalid payload failure.

### Mobile

- progression recommendation rendering;
- protection/override setting mutation through fake repository;
- paid/account Progress screen regressions remain green.

## Explicitly deferred

- full-week/item schedule protection;
- automatic routine edits;
- auto-application of recommended load into prescriptions;
- multi-session progression models;
- deloads/fatigue/readiness;
- substitution similarity/equivalence scoring;
- medical diagnosis or injury advice;
- correction approval workflow;
- dashboard progression/correction UI;
- charts;
- notification/background jobs;
- TASK-IMP-008 release work.

## Validation state

- local Supabase reset, pgTAP and database lint passed on implementation head `3df4c9b311c02209351546c1f4d25c013f2cf22a`;
- generated-source verification passed on the same head;
- the first Flutter/Dart run stopped only on formatting in two 007 files;
- the formatter output was applied on head `38db5613d3d0ed6aa687aff4ff6d5ce4ce7b3d5e`;
- final exact-head Foundation CI is the remaining acceptance gate.

## Acceptance

TASK-IMP-007 is complete when:

- the server returns deterministic recommendations from actual workout evidence;
- settings can protect, pain-flag, override and choose a preferred substitute;
- preferred substitution is used on the next workout start without mutating the routine;
- corrections and reversals create exact immutable ledger effects;
- the existing Progress branch exposes these controls;
- focused tests and Foundation CI pass.

## Execution policy

Assistant performs planning, docs, schema design, shared contracts, direct GitHub implementation, test authoring, CI diagnosis/fixes and PR handling wherever feasible.

Codex is used only for a concrete residual local Dart/Flutter implementation or compile/test failure that cannot reasonably be completed through GitHub.

After TASK-IMP-007 merges, execute TASK-IMP-005B before TASK-IMP-008.
