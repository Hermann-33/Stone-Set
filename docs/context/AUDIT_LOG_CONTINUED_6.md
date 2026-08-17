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

## 2026-08-17 — TASK-IMP-017 — Guidance publication propagation audit and E2E hardening

### Reported defect

The owner reported that guidance text/media edits saved in the dashboard did not appear in Android and requested a complete dashboard-to-app audit rather than a client-only patch.

### Production/root-cause evidence

Read-only inspection of production Supabase project `pjltldrernuvrjsnmcqg` found:

```text
guidance_revisions       25
max guidance version     1
guidance_media_manifests 25
guidance_drafts          2
published YouTube refs   0
```

Smith Squat had unpublished text changes relative to published v1. Both remaining owner drafts contained YouTube references in `preview_required` state. Therefore no immutable v2 existed for Android to load.

The audit traced all relevant boundaries:

- dashboard Save persists the mutable guidance draft only;
- explicit Publish creates/finalizes immutable guidance/media;
- the server rejects a YouTube-bearing publication unless preview validation succeeded and `validated_at` is no older than one hour;
- new workout-session exercise inserts resolve the latest owner-matching finalized guidance/media bundle;
- already-started workout snapshots remain immutable;
- mobile guidance loading requests the exact revision pinned by the server workout snapshot.

The primary defect was misleading/insufficient dashboard publication state and preflight, not a mobile cache lookup that ignored an existing v2.

### Implemented repair

Dashboard guidance publication:

- save state now says `Draft saved` rather than implying live activation;
- an above-fold publication boundary explains that Save does not update Android;
- Publish reflects authoritative media readiness;
- YouTube `preview_required`, unavailable state, missing validation evidence and validation older than one hour are blocked before publication reservation;
- the final preflight mirrors the authoritative server gate instead of relying on a later RPC rejection;
- Publish confirmation explains next-workout activation and active-session pinning;
- null/failed publication explicitly states that no app guidance version changed.

Cross-layer regression protection:

- `guidance_publication_activation_e2e.test.sql` uses the real authenticated publication RPCs twice and real `public.start_workout_v1(uuid)` calls;
- the test proves v1 is pinned by the first started workout, v2 publication does not rewrite it, and the next real workout start resolves v2;
- mobile loader coverage proves a newer revision is consumed only when the workout snapshot itself pins that newer revision and rejects mismatched bundles.

### Verification findings during implementation

The verification gate caught multiple defects in test/branch work before acceptance:

- the first database fixture read a nonexistent `revision` key instead of the returned `draftRevision`;
- an early database probe attempted to call a deliberately private trigger function as an authenticated actor and was replaced with the public real-workout-start path;
- canonical Dart formatting drift was corrected with the repository-pinned Flutter/Dart toolchain;
- a duplicate experimental mobile test containing invalid Dart string multiplication was removed in favor of strengthening the existing loader test;
- the first dashboard gate blocked only `preview_required`; audit against the authoritative server contract exposed unavailable and one-hour-expired validation as additional required blockers.

A focused Flutter run covering the final dashboard publication preflight, including unavailable and expired YouTube validation, passed before final documentation synchronization.

Final Foundation CI on the clean PR head remains required and must cover the applicable Flutter/Dart, dashboard Chrome/Web build, mobile/Android build, Local Supabase pgTAP/database lint and repository/document lanes.

### Production safety

- all production database inspection for TASK-IMP-017 was read-only;
- no owner content was auto-published;
- no preview evidence was fabricated;
- no active workout snapshot was rewritten;
- no rank, RR, consistency, penalty, schedule, swap or free-swap behavior was modified;
- no Android signer/application ID/Firebase architecture was changed.

### Pre-merge delivery boundary

PR #58 remains draft and unmerged because the owner explicitly reserved final manual acceptance before merge.

ADR-0014/TASK-IMP-016 suppresses Vercel feature/PR preview deployment, so `stone-set.vercel.app` remains production main and cannot be used to prove PR #58 before merge. Owner verification must use an explicit local/branch dashboard build against an approved test environment.

### Verdict

`PARTIAL`.

Engineering implementation and focused regressions are in place, but the repository completion gate is intentionally not satisfied until final clean-head Foundation CI passes, owner pre-merge E2E acceptance succeeds, and PR #58 is merged. TASK-IMP-014 production owner preview/publish remains a separate residual after the engineering hardening is accepted.
