# Stone Set Architecture

Updated: 2026-08-14
Status: `ACCEPTED CURRENT ARCHITECTURE`

Durable decisions are recorded under `docs/decisions/`. Where historical planning documents differ, accepted ADRs and the current task/product records are authoritative.

## 1. System topology

```text
Flutter Android app                    Flutter Web dashboard
  Home / Week / Progress / Profile       Overview / Routines / Exercises / Activity / Settings
  workout execution + guidance            guidance/media + routine authoring/publication
  SQLite active work + read cache          browser-local draft recovery
              \                              /
               \---- shared Dart packages --/
                         domain / data / ui
                                |
                          Supabase Auth
                          Postgres + RLS/RPC
                          private Storage + RLS
```

Production topology:

```text
Android          permanently signed private Firebase App Distribution
Dashboard        Vercel-hosted Flutter Web SPA
Backend          single hosted Supabase project pjltldrernuvrjsnmcqg
CI               GitHub Actions + pinned Flutter/Dart/Node/Supabase CLI
```

There is no staging environment in the current private-release topology. Public clients contain only publishable Supabase configuration; service-role/database/signing/backup credentials remain outside client source.

## 2. Client architecture

Both clients use Flutter/Dart, Riverpod and go_router with repository/service boundaries.

Dependency direction:

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

Rules:

- widgets do not own server/storage authority;
- domain has no Flutter/Supabase dependency;
- Riverpod is the application state/DI system;
- go_router owns navigation;
- server-owned schedule/reward/publication/finalization state is never calculated authoritatively in the clients.

## 3. Authentication/session architecture

- provisioned Supabase Auth accounts are shared across mobile/dashboard;
- public signup/social/anonymous/magic-link/recovery are excluded;
- operator provisioning/recovery stays in trusted tooling;
- profile activity, password-change requirement and compatibility are server-checked;
- mobile/dashboard sessions are independent;
- credentials/tokens never enter product tables/logs.

Under ADR-0010, a previously verified same-owner Android session may render an owner-scoped cached protected read shell before a network refresh. Cached state cannot bypass password-change, access-denied, maintenance or incompatibility states and remains non-authoritative.

## 4. Android persistence and synchronization

`stone_set_workout.db` contains:

- durable active-workout/set drafts;
- owner-scoped bootstrap/Week/Progress read snapshots;
- synchronization generation/freshness/error metadata.

Android behavior:

- first-ever authentication remains online-only;
- workout start remains server-authoritative and online under ADR-0003;
- an already-started workout can continue from local durable state offline;
- Home/Week/Progress are cache-first after a valid prior bootstrap;
- one single-flight coordinator revalidates auth, synchronizes supported pending workout edits, then refreshes authoritative Week/wallet and Progress/rank/history;
- failed refresh preserves the last good owner-scoped cache generation;
- Home/Week/Progress pull-to-refresh await the coordinator;
- startup/resume/workout completion trigger best-effort synchronization;
- local state never fabricates RR/XP/rank/wallet/ledger authority.

Under ADR-0012, when the user requests a different workout than a locally active draft:

1. pending local edits must synchronize first;
2. failed synchronization preserves the old draft and blocks switching;
3. only a synchronized stale local row may be cleared;
4. the requested workout then uses the existing authoritative online `start_workout_v1` flow;
5. server workout-session history is never deleted, submitted or rewritten by local switching.

Offline creation/reconciliation of a new workout session is not authorized by ADR-0010/ADR-0012 and remains a separate future decision.

## 5. Guidance/media authoring and publication

Exercise guidance is owner-scoped and versioned as immutable published revisions. Image bytes live in private Supabase Storage; Postgres owns metadata, ordering, hashes, YouTube references, media manifests and publication state.

Dashboard draft flow:

```text
editable guidance/media draft
  -> validate text/media
  -> real YouTube preview evidence when a video reference exists
  -> atomic immutable guidance revision + finalized media manifest
```

YouTube rules:

- normalized YouTube video ID/canonical URL only;
- official IFrame preview in dashboard;
- successful playable preview required for publication of a video reference;
- preview validation evidence expires server-side after the accepted window;
- no autoplay/background/download/cache/audio extraction/ad suppression;
- no client may fabricate playable evidence.

TASK-IMP-014 makes a loaded `preview_required` condition explicit in the dashboard and maps the same server error for missing/expired evidence to actionable remediation. The server remains authoritative.

## 6. Guidance activation for workout sessions

ADR-0011 separates **historical routine prescription evidence** from **content-only guidance activation for a future workout**.

Rules:

1. Routine versions, routine prescriptions and materialized training-week rows remain immutable and retain the guidance revision selected when they were published/materialized.
2. Published guidance/media revisions remain immutable.
3. When a new `workout_session_exercises` row is created, the server resolves the latest owner-matching published guidance revision for that exercise that has a finalized media manifest.
4. If no eligible finalized bundle exists, the immutable routine prescription revision remains the fallback.
5. The resolved revision is written once into the workout-session snapshot.
6. A later publication never rewrites an already-started workout-session snapshot.
7. Android loads guidance/media by the exact session-pinned revision; it does not perform a client-side `latest` lookup.

## 7. Routine, Week browsing and scheduling authority

Current routine lifecycle is direct owner publication:

```text
Create/Edit → Save → Validate → Publish
```

The retired independent reviewer/approval workflow must not be reintroduced without a new explicit product decision.

Postgres remains authoritative for:

- immutable routine versions;
- training-week materialization;
- locks/swaps/free credits/wallet effects;
- workout start/sync/submit/finalization;
- RR/XP/rank/PR/penalty/progression state.

ADR-0012 separates Week **inspection** from Week **mutation**:

- a normal tap opens read-only detail for any Monday-Sunday materialized item;
- workout detail returns immutable prescription values and guidance access;
- rest items remain inspectable and contain no prescribed exercises;
- swap selection requires long press on each open day followed by explicit confirmation;
- read-only detail uses `public.get_training_week_item_detail_v1(uuid)`, a security-invoker owner-scoped RPC;
- the RPC may resolve the latest finalized guidance revision for display only; it does not rewrite the routine prescription, materialized Week item or any started workout snapshot.

`rank-v6` and `schedule-v3` remain protected invariants. The historical double swap remains immutable/auditable and was not silently refunded or rewritten.

## 8. Postgres/RLS/server operation boundaries

Schema boundaries:

```text
auth       managed identities/sessions
public     RLS-protected client relations and narrow RPCs
private    unexposed helpers/config/audit/job functions
storage    managed private object metadata
cron       managed scheduled operations where used
```

Guarantees:

- immutable UUID ownership;
- RLS on exposed private data;
- server derives actor from Auth context rather than client-supplied owner ID;
- security invoker by default;
- hardened security-definer functions only when required;
- explicit grants;
- idempotency/revision checks/transaction locks on authority-changing workflows;
- immutable published/materialized/finalized history;
- append-only reward/wallet history with exact reversal semantics.

TASK-IMP-014's guidance resolver is a private insert trigger, not a new client mutation surface, and is constrained by exercise owner UUID.

TASK-IMP-015's `get_training_week_item_detail_v1(uuid)` is a narrow read surface: `security invoker`, owner predicate derived from `auth.uid()`, no anonymous execute grant, authenticated execute only. Production migration history: `20260814080728_training_week_item_detail`.

## 9. Storage/media security

Private bucket: `exercise-media`.

- immutable owner/exercise/revision/asset paths;
- authenticated Storage/RLS access;
- no public bucket URLs;
- images are processed/re-encoded with metadata removed before upload;
- published objects are not silently overwritten;
- database metadata and Storage bytes are backed up/reconciled independently;
- YouTube video bytes are never uploaded, proxied, downloaded or cached by Stone Set.

## 10. Dashboard hosting

Production dashboard:

```text
https://stone-set.vercel.app
```

The Flutter Web app is a static Vercel deployment with SPA routing. Auth/RLS/Storage policies protect private data; the URL itself is not an authorization boundary.

Under ADR-0014, feature/PR Vercel deployments are suppressed with a globstar rule; only `main` is enabled. `ignore-build.sh` cancels unaffected main events before the Flutter Web build. TASK-IMP-015 was mobile/database-only, so its main Vercel record was canceled/ignored and the existing READY production dashboard remained unchanged.

## 11. Android release architecture

Android application identity and permanent signer are fixed by ADR-0009. Private distribution uses Firebase App Distribution after trusted exact-main CI.

TASK-IMP-015 private distribution evidence:

```text
commit              d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
version/build       0.1.0 (1000073)
application ID      io.github.hermann33.stoneset
Firebase release    3evhve7djjghg
workflow            Private Android Distribution #73 / 31782531713 — PASS
```

The workflow verified the permanent signing certificate, application ID, version and APK integrity before distribution.

## 12. Verification architecture

Foundation CI is fail-closed and path-sensitive under ADR-0007.

Applicable lanes include:

- repository/document checks;
- generated source freshness;
- locked dependency/tool verification;
- Dart formatting and strict analysis;
- unit/widget/Chrome/golden tests;
- Android or Web release builds selected by changed paths;
- Local Supabase start/reset/Auth/Storage lifecycle/pgTAP/lint;
- API 24 only for qualifying mobile runtime/performance paths.

A failed external runner/service startup is not treated as a product success, but an identical-head retry may establish the missing lane if no code changed and the actual checks then pass.

TASK-IMP-015 passed exact PR-head Foundation CI #413 and exact-main Foundation CI #414, including mobile tests, Android release build, API-24, Local Supabase reset/Auth/Storage/full pgTAP/lint.

## 13. Accepted ADRs relevant to current behavior

- ADR-0001 — Flutter client platforms.
- ADR-0002 — Supabase backend/Auth/persistence.
- ADR-0003 — local workout drafts and online finalization/start.
- ADR-0004 — Android-first and Vercel dashboard hosting.
- ADR-0005 — production operations/recovery.
- ADR-0006 — exercise media/YouTube.
- ADR-0007 — path-sensitive CI.
- ADR-0008 — guidance revision draft materialization.
- ADR-0009 — private Android distribution.
- ADR-0010 — offline-first mobile cache/synchronization.
- ADR-0011 — latest finalized published guidance for newly started workouts.
- ADR-0012 — Week browsing, deliberate swaps and safe local workout switching.
- ADR-0014 — main-only Vercel Git deployment with feature/PR suppression.

## 14. Deliberate exclusions

No public/social auth, public profiles/marketplace, direct video upload, iOS initial release, client-authoritative scoring, unrestricted offline workout start, full offline dashboard, analytics/ads, or automatic guidance publication/YouTube validation.
