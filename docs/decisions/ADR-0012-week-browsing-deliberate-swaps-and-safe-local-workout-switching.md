# ADR-0012: Week browsing, deliberate swaps, and safe local workout switching

## Status

Accepted

- Date: 2026-08-13
- Type: Mobile interaction and authenticated read contract
- Supersedes: none
- Preserves: ADR-0003, ADR-0007, ADR-0010, ADR-0011, schedule-v3 and rank-v6

## Context

The mobile Week surface used ordinary taps to select swap items, leaving no ordinary interaction for inspecting another day. Production evidence also showed the same Thursday/Friday pair was confirmed twice, so the second legal swap reversed the first and consumed the second weekly swap. Separately, the mobile workout controller refused to start today's requested item whenever a different local active-workout row existed, even when that local row had no unsynchronized work.

## Decision criteria

- every materialized day must be inspectable without mutating schedule state;
- swap selection must be deliberate and distinct from ordinary browsing;
- pending local workout edits must never be discarded;
- stale synchronized local workout state must not prevent an authoritative online start for today's item;
- server schedule/workout authority and immutable historical rows must remain unchanged.

## Decision

1. A normal tap on any Week item opens a read-only day detail showing its immutable prescription exercises and guidance.
2. Swap selection requires a long press on each unlocked day. Confirmation remains explicit and atomic on the server.
3. The client prevents re-entrant confirmation and clears selection immediately after server acceptance.
4. A narrow authenticated read RPC returns one owner-scoped materialized week item and prescription details. It resolves the latest finalized published guidance revision only for read-only guidance display, without changing materialized prescription history.
5. When starting a requested workout, a different local active draft is handled as follows: pending edits must synchronize first; if synchronization fails the old draft is preserved and start is blocked; if no pending edits remain the stale local row may be cleared before the requested authoritative online start.
6. Server workout-session history is not deleted, submitted or rewritten by this switching rule.

## Consequences

- ordinary Week taps no longer select swaps;
- reversing a swap remains a legal schedule-v3 action, but requires a new deliberate long-press selection and explicit confirmation;
- browsing guidance for Monday/Tuesday/etc. does not start a workout and has no reward effect;
- synchronized stale local workout state no longer makes today's Start button effectively inert.

## Security, privacy, data, and operational impact

The new RPC derives ownership from `auth.uid()`, is `security invoker`, exposes no cross-owner rows, and grants execute only to authenticated clients. No secrets or privileged credentials enter the client. Pending local workout edits remain protected from implicit deletion.

## Scope boundaries

No rank-v6, schedule-v3 economics, swap limits, routine publication, historical swap records, server workout finalization, Android signer/application ID, Firebase architecture, or offline-new-workout authorization changes.

## Rollback or supersession rule

A later change that permits offline workout creation, multiple simultaneous local active workouts, or materially changes swap semantics requires a new ADR.

## Activation evidence

Activated through PR #56 and production rollout:

```text
PR head                 d303dbd8e5a0eed25836bc10868d06cec47cb8db
PR Foundation CI        #413 / 31781422679 — PASS
merged main             d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
exact-main Foundation   #414 / 31782008565 — PASS
production migration    20260814080728_training_week_item_detail
private Android run     #73 / 31782531713 — PASS
Android release         0.1.0 (1000073), Firebase 3evhve7djjghg
```

Production post-deploy verification confirmed the detail RPC exists, is not security-definer, denies anonymous execute, grants authenticated execute, and did not change the existing counts of 7 materialized Week items, 2 workout sessions or 2 weekly swaps. The main Vercel event was canceled/ignored because no dashboard build input changed.
