# TASK-IMP-015 — Week day detail, deliberate swaps, and reliable workout start

Updated: 2026-08-14
Status: `COMPLETE`
Decision: `ADR-0012`

## Objective

Fix the mobile Week workflow so any weekday can be opened for complete exercise/prescription/guidance inspection, swap selection requires deliberate long presses, and a stale synchronized local workout cannot prevent today's authoritative workout start.

## Verified root causes

Production evidence showed the same Thursday/Friday pair was confirmed twice in opposite order. The second legal schedule-v3 confirmation reversed the first and consumed the second weekly swap. That immutable history was not rewritten or silently refunded.

The authoritative `start_workout_v1` RPC was inspected in production and does not reject today's requested item merely because another historical active server session exists. The mobile `WorkoutController.loadOrStart` independently blocked a different local active draft before issuing the requested server start.

## Implemented outcome

- normal Week tap opens read-only detail for that materialized day;
- workout days show every prescription and a guidance action;
- rest days explicitly show no prescribed exercises;
- long press, not normal tap, selects each swap day;
- swap confirmation is single-flight and clears selection immediately after server acceptance;
- `public.get_training_week_item_detail_v1(uuid)` provides the narrow owner-scoped authenticated read contract;
- the detail RPC uses a left join for the routine day so genuine rest items still return a row;
- read-only guidance resolves the latest finalized owner/exercise bundle without rewriting routine/version/week history;
- a different pending local workout must synchronize before switching;
- failed synchronization preserves the old draft and blocks switching;
- a different synchronized stale local workout can be cleared locally before the existing authoritative online start;
- server workout-session history is never deleted or rewritten by this flow.

## Verification evidence

Implementation PR:

```text
PR #56
head                  d303dbd8e5a0eed25836bc10868d06cec47cb8db
Foundation CI #413    31781422679 — PASS
```

Applicable PR-head gates passed:

- repository/docs hygiene;
- canonical Dart formatting;
- strict static analysis;
- mobile goldens;
- mobile unit/widget tests, including tap-vs-long-press and safe-workout-switch regressions;
- Android release APK + rank asset verification;
- Android API 24 profile scenario;
- Local Supabase reset;
- Auth/private Storage lifecycle;
- full pgTAP, including the new RPC security/rest-day assertions;
- database lint.

Merged runtime main:

```text
main                  d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
Foundation CI #414    31782008565 — PASS
```

## Production Supabase

Tracked migration:

```text
supabase/migrations/20260813042000_training_week_item_detail.sql
```

Production migration history:

```text
20260814080728_training_week_item_detail
```

Post-deploy verification:

```text
detail RPC exists                         true
security definer                          false
anon execute                              false
authenticated execute                     true
training_week_items                       7 (unchanged)
workout_sessions                          2 (unchanged)
weekly_swaps                              2 (unchanged)
```

No schedule, swap or workout-history row was rewritten by deployment.

## Vercel

The runtime main push produced deployment record `dpl_D6RgWmX6ucoy9j8eWrmfCujch1wy`, which resolved `CANCELED` under the path-sensitive ignored-build policy. No Flutter Web dashboard build was needed or used for this mobile/database task. Existing production hosting remained intact.

## Private Android distribution

Private Android Distribution run:

```text
run                   31782531713 (#73) — PASS
commit                d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
application ID        io.github.hermann33.stoneset
version               0.1.0
build                 1000073
Firebase release      3evhve7djjghg
group                 stone-set-testers
APK SHA-256           0F4C9972A0E86EF595A3926A5DCD808DF37E549646E55DF1505BFDA812A83D02
signing cert SHA-256  D2FCB14AB458AE0F77D3CC7528E09D0D3C4514A7CAA9981C7F26AD87908C2829
```

The workflow verified APK application ID, version identity, permanent signer and integrity before distributing through Firebase App Distribution.

## Protected behavior

No historical swap reversal/refund, no server-session deletion, no rank-v6 or schedule-v3 economics changes, no swap-limit/payment change, no routine publication change, no started-workout guidance mutation, no offline new-workout creation, and no Android signer/application-ID/Firebase architecture change.

## User-visible acceptance

After updating to private Android build `0.1.0 (1000073)`:

1. tap any Monday-Sunday Week card to inspect that day's detailed routine;
2. workout days expose all exercise prescriptions and guidance;
3. rest days explicitly show no prescribed exercises;
4. long-press two open days to select a swap, review the preview, then confirm;
5. a stale synchronized local workout no longer makes today's Start action inert;
6. pending unsynchronized local workout edits remain protected if synchronization cannot complete.

## Verdict

`COMPLETE` — implementation, regression coverage, merge, exact-main CI, production Supabase deployment, Vercel ignore verification and private signed Android distribution are complete.
