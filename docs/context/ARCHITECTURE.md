# Stone Set Target Architecture

Updated: 2026-08-05
Status: `ACCEPTED TARGET ARCHITECTURE — FOUNDATION IMPLEMENTED`

Detailed baselines:

- `TECHNOLOGY_BASELINE.md`
- `DATABASE_AND_SERVER_PLAN.md`
- `COMPLETE_UI_UX_SYSTEM.md`
- `IMPLEMENTATION_PLAN.md`

## 1. Current implemented system

```text
GitHub repository
  -> governance/specifications/ADRs/tasks
  -> rank-v6 emblem assets
  -> native Dart Pub workspace and one root lockfile
       -> Android-only Flutter foundation shell
       -> Web-only Flutter foundation shell
       -> domain / data / ui foundation packages
  -> local-only Supabase configuration and pgTAP runner smoke test
  -> pinned root tooling and GitHub Actions foundation CI
```

The executable shells are honest placeholders only. There is no authentication, profile,
product database schema, Storage bucket, account, product behavior, hosted Supabase/Vercel
project or deployment.

Foundation versions are pinned to Flutter 3.44.7, bundled Dart 3.12.2, Node.js 24.11.1 and
Supabase CLI 2.111.0. Root resolution, repository checks, formatting, analysis, tests, the Web
release build and security review pass locally. GitHub Actions run `31002750225` passed the Android
and Web release builds plus local Supabase start/reset/pgTAP/lint/stop. This Windows host lacks an
Android SDK and Docker-compatible runtime, so those CI-proven checks are not locally repeatable here.

## 2. Target system

```text
Flutter Android app                    Flutter Web dashboard
  Home/Week/Progress/Profile             Overview/Routines/Exercises/
  workout logger/guidance                Reviews/Activity/Settings
  SQLite draft/outbox/cache               browser draft recovery
           \                               /
            \-- shared Dart packages ----/
                 domain / data / ui
                          |
                 Supabase Auth
                 Supabase Postgres + RLS
                 Supabase Storage + RLS
                 Postgres functions/RPC
                 Supabase Cron / pg_cron
```

Deployment:

```text
Android          signed private release; later Play internal evaluation
Dashboard        Vercel static Flutter Web SPA
Backend          local -> staging -> production Supabase
CI/CD            GitHub Actions + Supabase CLI
```

## 3. Client architecture

Both clients use:

- Flutter and Dart;
- Riverpod for state/dependency injection;
- go_router typed routes;
- views/view models, repositories and services;
- immutable view/domain models;
- repository source-of-truth boundaries;
- semantic shared UI tokens and selected primitives.

Only the workspace/package dependency boundaries and neutral foundation placeholders exist in
`TASK-IMP-001`. Riverpod, go_router, feature view models, repositories, persistence services and
product models remain planned for their owning later packets.

Dependency direction:

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

Rules:

- widgets never call Supabase, SQLite, browser storage or Storage directly;
- domain has no Flutter/Supabase dependency;
- use cases exist only for genuinely complex coordination;
- no second global state/routing framework;
- public clients contain publishable configuration only;
- no client-authoritative schedule, score, wallet, review or finalization.

## 4. Android responsibilities

- native login/password-change/session guard;
- stateful Home/Week/Progress/Profile navigation;
- rank/today/week/history/progress presentation;
- workout overview and server-authoritative online start;
- set logging, timers and completion;
- SQLite active draft, immutable session snapshot and outbox;
- offline continuation and pending submission;
- WorkManager best-effort synchronization retry;
- guidance text/image cache;
- official YouTube IFrame through Android WebView;
- notification-aware rest/reminder behavior;
- swaps, wallet choice, progression, protection and corrections;
- logout/session-expiry quarantine and cache cleanup.

Android does not calculate authoritative RR, XP, PRs, penalties, wallet balances, rank, consistency or finalization.

## 5. Dashboard responsibilities

- responsive `/login`, password change, session guard and logout;
- adaptive drawer/rail/sidebar shell;
- attention Overview, search, command palette and shortcuts;
- user-owned exercise library;
- structured guidance drafts/revisions;
- image preprocessing/upload/order/alt text/history;
- YouTube normalization and official preview;
- seven-day routine drafts and validator feedback;
- independent immutable review and publication;
- mobile preview and version compare;
- browser-local draft recovery and concurrency conflicts;
- activity/settings/export surfaces.

The dashboard is a public static client; Auth/RLS/Storage policies, not the URL, protect data.

## 6. Authentication and session architecture

- same provisioned Supabase Auth accounts work on both clients;
- user sees username/password; clients derive configured internal email alias;
- public signup/social/anonymous/magic-link/recovery excluded;
- operator provisions confirmed accounts and temporary passwords through trusted tooling;
- one protected profile per Auth user;
- first login requires password change;
- session is refreshed/bootstrap-verified before private render;
- active profile and client compatibility are checked server-side;
- mobile/dashboard sessions are independent;
- dashboard logout clears private browser state;
- mobile logout resolves or discards unsynchronized work;
- involuntary expiry quarantines mobile draft for same-account reauthentication;
- operator recovery can reset requirement and revoke selected/all sessions;
- passwords/tokens never enter product tables/logs.

## 7. Postgres architecture

Schema boundaries:

```text
auth       managed identities/sessions
public     RLS-protected client tables/views/RPC
private    unexposed helpers/config/audit/job control
storage    managed Storage metadata; application read-only
cron       managed scheduled jobs
```

Domain groups:

- profiles/preferences/capabilities/compatibility;
- exercises/muscles/guidance/media/YouTube;
- routine drafts/validation/submission/review/versions;
- training weeks/items/snapshots/swaps/credit ledger;
- sessions/exercises/sets/sync/submission/results;
- performance/PR/progression;
- rank/XP/wallet/evaluation/milestones;
- protection/substitution/pain/corrections;
- activity/audit/export/lifecycle.

Guarantees:

- UUID identity;
- UTC `timestamptz` plus local date/IANA timezone evidence;
- immutable published/materialized/finalized records;
- content hashes and configuration versions;
- append-only RR/XP/wallet transactions with exact reversals;
- optimistic draft revisions;
- unique idempotency constraints;
- transaction locks for wallet/week/session/publication/finalization;
- deterministic stored allocation/evaluation results.

## 8. Authorization and server operations

- RLS enabled for every exposed private table;
- owner/reviewer/capability rules tested with anonymous and cross-user denials;
- exposed views use `security_invoker`;
- direct client writes to authoritative records denied;
- authority-changing workflows use narrow Postgres functions;
- security invoker by default;
- security definer only when required, with empty search path, qualified objects and explicit grants;
- server derives actor from `auth.uid()`, not client `user_id`;
- operator Auth administration uses service role only in trusted tooling/approved server boundary.

Atomic/idempotent workflows include account linkage, guidance publication, routine submission/review/publication, materialization, swaps, workout start/sync/submit, weekly finalization, protection/correction and export.

## 9. Scheduling and recurring operations

Supabase Cron/`pg_cron` runs bounded idempotent functions for:

- due week materialization;
- monthly free-swap grants;
- rest-item resolution;
- grace expiry;
- weekly finalization;
- draft media/export cleanup;
- job-failure recording.

Relevant application reads/bootstrap invoke catch-up operations so missed cron execution cannot permanently block state.

## 10. Android offline architecture

SQLite stores only private non-authoritative feature data:

- active session/prescription/guidance snapshot;
- set draft;
- outbox;
- pending submission;
- cache metadata.

Outbox records have idempotency key, payload version, sequence, attempts and state. Autosave is transactional. Sync occurs on foreground, connectivity regain, explicit retry, final submission and best-effort WorkManager. No continuous polling.

Starting requires connectivity. A started session can continue offline. Offline finish remains pending and cannot move authoritative rank/wallet until validation.

Feature SQLite is internal-app storage, user-scoped and migration-tested. Passwords, tokens and service credentials are excluded.

## 11. Dashboard local architecture

An IndexedDB-backed adapter protects unsaved draft work across refresh/process/network interruption.

- user/object/revision scoped;
- explicit save/offline/sync/conflict states;
- expected server revision;
- compare/recover rather than overwrite;
- cleared on logout;
- not authoritative;
- publication/review/media authority requires connectivity.

## 12. Storage and media

Private bucket: `exercise-media`.

- owner/exercise/revision/asset paths;
- JPEG/PNG/static WebP;
- six images maximum;
- 5 MB maximum processed image;
- EXIF/GPS stripped, orientation corrected, resized/re-encoded, hash recorded;
- alt text required;
- immutable published object paths/no silent overwrite;
- `owner_id` and path/bucket RLS;
- Storage API for deletion/move/copy;
- Postgres media metadata reconciled with Storage backups.

## 13. YouTube

- at most one optional YouTube reference per guidance revision;
- normalized video ID/canonical URL/start time/validation metadata;
- official dashboard embed preview;
- Android official IFrame player through WebView with valid base/Referer;
- user initiated, online only;
- no autoplay/background/download/cache/extraction/ad suppression/reward;
- failure opens clear external fallback.

## 14. Flutter Web and Vercel

Initial production build:

```text
flutter build web --release
```

Wasm is evaluated later. Multithreaded Wasm requires COOP/COEP and must prove compatibility with Supabase, YouTube, downloads and supported browsers.

Vercel:

- static artifact;
- filesystem-first SPA rewrite;
- preview protection;
- preview uses staging only;
- HTTPS/HSTS/CSP/content-type/referrer/permissions headers;
- immutable cache for hashed assets;
- no-cache/revalidation for index/bootstrap/runtime config;
- no private data/secrets in build.

## 15. Compatibility and updates

Versioned server configuration provides:

- minimum/recommended mobile/dashboard build;
- schema contract version;
- maintenance/read-only mode;
- safe message and feature flags.

Clients block incompatible mutations and show recoverable update/maintenance state. Migrations support rolling compatibility and avoid destructive one-step releases.

## 16. Observability and security

- correlation IDs across client/RPC/audit;
- structured redacted logs;
- Supabase Logs Explorer, Cron runs, Storage logs and database advisors;
- user-safe diagnostics screen;
- no passwords/tokens/raw private notes/media URLs in logs;
- no analytics/crash SDK without separate privacy/cost decision;
- ASVS 5.0 dashboard/API verification;
- MASVS Android verification;
- WCAG 2.2 AA-equivalent dashboard and Android platform accessibility;
- exact dependency pinning, secret scan and build artifact review.

## 17. Environments, CI and deployment

```text
local       Supabase CLI and synthetic data
staging     hosted non-production identities/data/media
production  Supabase Pro + Vercel production + signed Android
```

- migrations in Git only;
- clean reset/pgTAP/lint in CI;
- format/analyze/unit/widget/golden/build checks;
- one coordinated production migration pipeline;
- preview never reaches production data;
- no production secrets in CI artifacts/clients.

The implemented foundation workflow uses pinned third-party action commits, read-only repository
contents permission and checkout with persisted credentials disabled. All three jobs passed in
GitHub Actions run `31002750225`. A pre-existing rank-asset generation workflow retains writable
contents permission and unpinned major action tags; this medium workflow risk was not introduced by
`TASK-IMP-001` and is deferred as an explicit exception for later hardening.

## 18. Backup, recovery and lifecycle

- Supabase managed daily database backups;
- database backups do not include Storage bytes;
- encrypted weekly logical database and Storage exports;
- 12 weekly and 12 month-end retention;
- Storage path/size/MIME/owner/hash manifest;
- separate restore environment;
- database/Storage reconciliation;
- RPO 24 hours, RTO 4 hours;
- release and quarterly restore drills;
- authenticated CSV/JSON export;
- operator deactivation/session revocation;
- hard-delete runbook deletes Storage through API and handles immutable audit/history safely.

## 19. Deliberate exclusions

No public auth, social/public profile, nutrition/sleep/wearables, AI coach, camera form analysis, public marketplace, direct video upload, iOS initial release, offline workout start, client scoring, full offline dashboard, Realtime requirement, analytics/ads or unrestricted rewarded extra workouts.

## 20. Accepted ADRs

ADR-0001 through ADR-0006 remain accepted. `TASK-PD-013` consolidates reversible technology/data implementation details within those architecture decisions and does not require a new platform ADR.
