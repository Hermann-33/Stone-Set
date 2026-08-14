# Stone Set Latest Handoff

Updated: 2026-08-14

## Latest engineering result

```text
TASK-IMP-015 — Week day detail, deliberate swaps, reliable workout start
ADR-0012
PR #56 — MERGED
main d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
Foundation CI #414 / 31782008565 — PASS
production Supabase 20260814080728_training_week_item_detail
private Android #73 / 31782531713 — PASS
release 0.1.0 (1000073), Firebase 3evhve7djjghg
```

TASK-IMP-015 is complete and deployed.

## Behavior now live

Week:

- tap any Monday-Sunday day to inspect that materialized day's detailed routine;
- workout days show prescriptions and guidance access;
- rest days explicitly show no prescribed exercises;
- tap is read-only and never selects a swap;
- long-press two open days to select a swap, review the preview, then explicitly confirm;
- confirmation is guarded against re-entrant duplicate submission.

Workout start:

- a different synchronized stale local workout is cleared locally before the normal authoritative online start;
- a different pending local workout must synchronize first;
- failed synchronization preserves pending local work and blocks the switch instead of discarding data;
- server workout-session history is not deleted or rewritten.

## Production backend evidence

`public.get_training_week_item_detail_v1(uuid)` is live in Supabase project `pjltldrernuvrjsnmcqg` under migration history:

```text
20260814080728_training_week_item_detail
```

Verified:

```text
function exists          true
security definer         false
anon execute             false
authenticated execute    true
training_week_items      7 (unchanged)
workout_sessions         2 (unchanged)
weekly_swaps             2 (unchanged)
```

The RPC is owner-scoped by `auth.uid()`, supports rest items with a left join, and performs no schedule/workout mutation.

## Android delivery

The exact merged runtime main was permanently signed, identity/integrity verified and distributed to `stone-set-testers`:

```text
commit              d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
application ID      io.github.hermann33.stoneset
version             0.1.0
build               1000073
Firebase release    3evhve7djjghg
```

A tester must update/install build `1000073` to receive the mobile Week/workout behavior.

## Vercel

This task had no dashboard build input. Main deployment record `dpl_D6RgWmX6ucoy9j8eWrmfCujch1wy` resolved `CANCELED` under the ignored-build policy, preserving the existing READY production dashboard and conserving Vercel quota.

## Independent residuals

- TASK-IMP-014: affected owner guidance/media drafts still require genuine YouTube preview validation and explicit Publish.
- TASK-IMP-013A: real-device airplane-mode acceptance remains separate.
- TASK-IMP-012: signing-key backup/phone confirmation remains separate.
- Do not rewrite the historical double swap, fabricate a swap refund, discard pending local workout data, fabricate media preview evidence or auto-publish owner content.
