# Stone Set Audit Log — Continued, Volume 6

This volume continues material audit history after `AUDIT_LOG_CONTINUED_5.md`. Earlier audit files remain unchanged and append-only.

## 2026-08-14 — TASK-IMP-015 — Week browsing, deliberate swaps and reliable workout start

### Reported defects

The owner reported three coupled mobile Week/workout problems:

1. Thursday was a rest day; after swapping it with Friday, tapping Start workout appeared to do nothing;
2. the Week tab exposed detailed routine/guidance only for the current day rather than allowing inspection of Monday-Sunday;
3. swap selection was too easy to trigger and should require a deliberate long press on each day.

### Production/root-cause evidence

Production schedule history showed the same Thursday/Friday pair had been confirmed twice. The second legal schedule-v3 swap reversed the first and consumed the second weekly swap. That history was preserved; no silent refund/deletion/rewrite was performed.

Production `public.start_workout_v1(uuid)` was inspected and does not reject a requested current-day workout merely because a different historical server workout session remains active. The mobile `WorkoutController.loadOrStart` independently rejected a different local active workout before issuing the server start request.

### Accepted decision

`ADR-0012 — Week browsing, deliberate swaps, and safe local workout switching` separates read-only Week inspection from schedule mutation and protects pending local workout data.

### Implemented repair

Mobile Week:

- normal tap opens read-only detail for any Monday-Sunday materialized Week item;
- workout days show every prescription plus guidance access;
- rest days explicitly show no prescribed exercises;
- long press on two open days selects a swap;
- explicit confirmation remains server-authoritative;
- re-entrant confirmation is blocked and selection clears after authoritative acceptance.

Mobile workout start:

- a different pending local workout must synchronize before switching;
- failed synchronization preserves the old draft and blocks the switch;
- only synchronized stale local workout state may be cleared;
- the requested workout then uses the unchanged authoritative online server start;
- no server workout-session history is deleted or rewritten.

Server read contract:

```text
supabase/migrations/20260813042000_training_week_item_detail.sql
```

`public.get_training_week_item_detail_v1(uuid)` is a security-invoker, owner-scoped authenticated read RPC. A left join preserves genuine rest-item detail. Read-only guidance may resolve the latest finalized published owner/exercise bundle, but routine/version/week history and started-workout snapshots are never rewritten.

### Verification and merge evidence

```text
PR                         #56 — MERGED
PR head                    d303dbd8e5a0eed25836bc10868d06cec47cb8db
PR-head Foundation CI      #413 / 31781422679 — PASS
runtime main               d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
exact-main Foundation CI   #414 / 31782008565 — PASS
```

Applicable gates passed:

- repository/docs hygiene;
- canonical Dart formatting;
- strict static analysis;
- mobile goldens;
- mobile unit/widget regressions for tap-vs-long-press and safe workout switching;
- Android release APK + rank asset verification;
- Android API-24 profile scenario;
- Local Supabase start/reset;
- Auth/private Storage lifecycle;
- full pgTAP, including the new RPC security/rest-day assertions;
- database lint.

During candidate verification, two Local Supabase attempts encountered external Docker/Supabase registry/upstream HTTP 502 rate limiting after migrations had applied. An identical-head retry reached the actual pgTAP suite; one test-helper portability defect (`like(...)`) was then corrected to standard `ok(... LIKE ...)`. The final exact head and exact main passed the complete database lane.

### Production Supabase deployment

Production project:

```text
pjltldrernuvrjsnmcqg
```

Migration history:

```text
20260814080728_training_week_item_detail
```

Post-deploy verification:

```text
detail RPC exists                         true
security definer                          false
anon execute                              false
authenticated execute                     true
training_week_items count                 7 (unchanged)
workout_sessions count                    2 (unchanged)
weekly_swaps count                        2 (unchanged)
```

No schedule, swap or workout-history row was rewritten.

### Vercel behavior

The runtime merge was mobile/database-only. Main Vercel deployment record:

```text
dpl_D6RgWmX6ucoy9j8eWrmfCujch1wy — CANCELED
```

The ignored-build policy therefore consumed no Flutter Web dashboard build and preserved the existing READY production dashboard.

### Private Android distribution

Private Android Distribution:

```text
workflow run            #73 / 31782531713 — PASS
commit                  d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
application ID          io.github.hermann33.stoneset
version                 0.1.0
build                   1000073
Firebase release        3evhve7djjghg
tester group            stone-set-testers
APK SHA-256             0F4C9972A0E86EF595A3926A5DCD808DF37E549646E55DF1505BFDA812A83D02
signing cert SHA-256    D2FCB14AB458AE0F77D3CC7528E09D0D3C4514A7CAA9981C7F26AD87908C2829
```

The workflow verified application ID, permanent signer, version identity and APK integrity before Firebase App Distribution.

### Security and immutability review

- the new detail RPC derives ownership from `auth.uid()`;
- anonymous execute is denied;
- no client receives privileged credentials;
- swap/payment/free-credit economics remain schedule-v3;
- historical double-swap evidence is unchanged;
- pending local workout edits cannot be silently discarded;
- server workout-session history remains authoritative and unchanged by local switching;
- online authoritative workout start remains required;
- rank-v6, routine publication, Android signer/application ID and Firebase architecture are unchanged.

### Verdict

`COMPLETE`.

Implementation, regression coverage, merge, exact-main verification, production Supabase migration, Vercel ignored-build verification and signed private Android distribution are complete. Testers must update to Android build `1000073` to receive the new mobile behavior.
