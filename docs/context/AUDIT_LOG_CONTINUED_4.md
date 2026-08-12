# Stone Set Audit Log — Continued, Volume 4

This volume continues material audit history after `AUDIT_LOG_CONTINUED_3.md`. Earlier audit files remain unchanged and append-only.

## 2026-08-13 — TASK-IMP-013A — Offline-first cached mobile shell candidate

### Authorization and scope

- accepted decision: `ADR-0010 — Offline-first mobile cache and synchronization`;
- implementation packet: `TASK-IMP-013A`;
- branch: `agent/task-imp-013a-offline-cache`;
- pull request: #47;
- preserves ADR-0003 online authoritative workout start;
- offline-created workout sessions/reconciliation remain deferred to TASK-IMP-013B;
- no Supabase migration, new dependency, rank-v6/schedule-v3 change, signer/application-ID change or Firebase pipeline change was authorized.

### Implemented architecture

- existing `stone_set_workout.db` migrated from v1 to v2;
- existing `active_workouts` and `workout_set_drafts` preserved;
- owner-scoped `mobile_snapshots` and `mobile_sync_state` added;
- bootstrap, Week and Progress snapshots are schema-versioned and owner validated;
- Week and Progress are promoted as one coherent generation so failed partial synchronization does not replace the prior good generation;
- cached bootstrap can render the previously verified same-owner authenticated shell before network refresh;
- protected cached states do not bypass password-change, access-denied, maintenance or compatibility rules;
- one single-flight mobile synchronization controller revalidates auth, synchronizes supported pending workout edits, fetches authoritative Week/wallet and Progress/rank/history, validates ownership and commits a coherent generation;
- Home, Week and Progress are cache-first and preserve the last good cached UI after recoverable network failure;
- native Home pull-to-refresh awaits real synchronization;
- lifecycle startup/resume and accepted workout completion trigger best-effort synchronization;
- logout/session-loss private-work hooks are connected to real owner-scoped workout local state.

### Rank-refresh regression

The mounted Home regression mutates the authoritative Progress fixture from PLATINUM II / 1910 RR to PLATINUM III / 2100 RR, performs a real pull gesture and verifies the updated rank/RR appears while the same `StatefulNavigationShell` remains mounted. No application restart or root recreation is required.

### Candidate verification

Exact green runtime implementation head:

```text
51474a6e8d3157bfbdad9c9e1de3fa57a468a758
```

Foundation CI:

```text
run id       31621647343
run number   #365
conclusion   PASS
```

Applicable evidence passed:

- changed-path classification;
- documentation/repository checks;
- generated Riverpod/typed-route verification;
- locked dependency restore and pinned tool versions;
- Dart formatting;
- strict Flutter/Dart analysis;
- deterministic mobile goldens;
- affected mobile tests;
- Android release APK build;
- Android release rank-asset bundle verification;
- Android API 24 profile scenario and evidence upload.

### Test-harness corrections discovered during CI

Two candidate CI failures were test-environment dependency leaks, not production runtime failures:

1. authentication widget tests initially resolved the production SQLite snapshot store under desktop Flutter tests, causing `databaseFactory not initialized`; the harness was corrected to use `FakeMobileSnapshotStore`;
2. the normal logout test then resolved production `unsynchronizedPrivateWorkProvider`, which transitively required an initialized Supabase instance; the harness was corrected to use a no-pending-work test implementation while the dedicated pending-work logout test retained its explicit override.

The final exact candidate passed all affected mobile tests after those harness corrections.

### Security and authority review

- snapshot rows/queries are owner UUID scoped;
- cached payload ownership is validated before promotion;
- cached state remains non-authoritative;
- no local RR/XP/rank/wallet/ledger transaction is fabricated;
- definitive authentication rejection still removes protected access;
- another owner cannot see a prior owner's cache or pending workout data;
- server remains authoritative for authentication, scheduling, swaps, rewards, rank and workout finalization;
- no secret, token, private key, signing material or private data was added.

### Current verdict

`PARTIAL`

Runtime implementation and pre-merge engineering verification are complete, but the task cannot be marked complete until:

1. canonical documentation changes themselves pass Foundation CI on their exact new head;
2. PR #47 merges from that exact green head;
3. Foundation CI passes on the exact resulting `main` SHA;
4. a fresh TASK-IMP-013A Private Android Distribution run is verified and its version/build/Firebase release ID recorded;
5. the physical Android airplane-mode acceptance flow is completed on a real tester device.

Historical release `0.1.0 / 1000062 / 5j1j4rhquebu0` belongs to TASK-IMP-012 and must not be reused as fresh TASK-IMP-013A distribution evidence.

### Exact next action

Commit/synchronize the current documentation head, obtain exact-head Foundation CI success, mark PR #47 ready, merge only that exact green head, verify exact-main CI and fresh private distribution, then complete the real-device airplane-mode acceptance flow.

## 2026-08-13 — TASK-IMP-014 — Guidance/media publication freshness candidate

### Reported defect

The owner reported that media and guidance-text changes made in the Web dashboard did not update the Android workout experience even after Publish.

### Production evidence and root cause

Credential-safe aggregate reads against production project `pjltldrernuvrjsnmcqg` established:

```text
published guidance revisions                   25
highest published guidance version              1
published media manifests                      25
routine-version prescriptions                   31
routine prescriptions behind latest revision    0
started session exercises behind latest          0
editable guidance drafts                         2
drafts with unpublished text changes             1
draft YouTube references                         2
YouTube draft validation status         preview_required (2)
```

This proved two independent defects:

1. at least one owner edit remained only in a draft because the atomic guidance/media publisher rejected `preview_required`; the dashboard mapped that exact server error to a generic media failure, hiding the required remediation;
2. `start_workout_v1` originally populated `workout_session_exercises.guidance_revision_id` from the immutable routine prescription, so even a future successfully published v2 would remain invisible to new workouts while the routine still pinned v1.

The Web YouTube preview callback itself was inspected and is correctly wired: a playable official IFrame calls the controller validation method. No fake validation path was needed or authorized.

### Accepted decision

`ADR-0011 — Latest published guidance for newly started workouts` was accepted.

It preserves immutable routine/version/week evidence and immutable started-workout snapshots while allowing content-only guidance/media publication to activate at creation of a future workout-session exercise snapshot.

### Implemented repair

Dashboard:

- loaded `preview_required` state fails before publication reservation with explicit instructions to play the YouTube preview;
- server `ExerciseMediaErrorCode.previewRequired`, including expired one-hour validation evidence, maps to the same remediation;
- real IFrame playable evidence remains mandatory;
- no preview validation or owner content publication is fabricated.

Server migration:

```text
20260812180500_latest_published_guidance_for_new_workouts.sql
```

It adds private function `private.resolve_latest_workout_guidance_revision_v1()` and a `BEFORE INSERT` trigger on `public.workout_session_exercises`.

For a newly created workout-session exercise row, the resolver selects the latest owner-matching guidance revision for that exercise with a finalized media manifest. The supplied routine revision remains fallback if no eligible bundle exists. Existing rows are untouched; later publication cannot rewrite an already-started workout.

Mobile remains unchanged and continues reading the exact revision pinned in the workout-session snapshot.

### Verification

Exact green implementation candidate:

```text
c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
```

Foundation CI:

```text
run id       31628667732
run number   #382
attempt      2
conclusion   PASS
```

Passing evidence:

- repository/document checks and changed-path classification;
- generated-source and locked tool/dependency verification;
- Dart formatting;
- strict Flutter/Dart analysis;
- deterministic dashboard goldens;
- dashboard unit/widget tests;
- dashboard Chrome tests;
- production Web build;
- privileged-credential marker review;
- Local Supabase start/reset;
- Auth/private Storage lifecycle checks;
- full pgTAP suite including new guidance-publication freshness regression;
- database lint;
- clean local stack stop.

The first Local Supabase attempt encountered external Docker/Supabase image rate limiting and an upstream HTTP 502 during reset after migrations had applied. The failed job alone was retried on the identical code head; attempt 2 passed the entire database lane. No code change was made to conceal or bypass that infrastructure failure.

API 24/mobile build lanes were correctly skipped by ADR-0007 because the task changes dashboard/server behavior and no mobile runtime/performance path.

### Security/immutability review

- owner UUID constrains latest-guidance resolution;
- private trigger function is not a new client RPC surface;
- routine versions/prescriptions/materialized weeks remain immutable;
- existing workout-session exercise rows are never backfilled or rewritten;
- Android still consumes a server-pinned immutable session revision;
- no rank/schedule/reward/signing/Firebase behavior changed;
- no production draft was auto-published;
- no YouTube preview evidence was fabricated;
- no secrets or private content were added to source.

### Current verdict

`PARTIAL`

The implementation candidate is green. Remaining gates are final documentation-head CI, exact-head PR #48 merge, exact-main CI, exact committed migration deployment/verification, Vercel production deployment verification, and the owner's genuine YouTube preview + Publish action for affected drafts.

### Exact next action

Finish canonical context documentation, obtain exact-head Foundation CI success, merge PR #48 only from that green head, verify exact-main CI, deploy the exact migration through Supabase migration history, verify production trigger/function and Vercel dashboard revision, then instruct the owner to perform real preview validation and Publish the affected draft(s).
