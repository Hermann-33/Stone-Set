# Stone Set Final Implementation Plan

Updated: 2026-08-06
Status: `IMPLEMENT THROUGH APPROVED PACKETS ONLY`
Latest planning task: `TASK-PD-016`

## 1. Planning status

Stone Set planning is complete for the accepted MVP.

Canonical supporting documents:

- `ARCHITECTURE.md` — system boundary and deployment model;
- `TECHNOLOGY_BASELINE.md` — Flutter/Riverpod/go_router/Supabase/platform choices;
- `DATABASE_AND_SERVER_PLAN.md` — relational domains, RLS, RPC, cron, sync and lifecycle;
- `COMPLETE_UI_UX_SYSTEM.md` — complete Android/dashboard experience;
- `UI_IMPLEMENTATION_PLAN.md` — UI workstream;
- product workflow/rank/schedule/guidance/auth specifications;
- `SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md` — coverage verdict.

The Phase 1 foundation and bounded Phase 2A identity/session runtime are complete and merged. No
later product runtime or remote infrastructure exists. The approved Phase 2B mobile presentation
packet is the next implementation action after its planning pull request merges.

## 2. Global implementation rules

Every implementation packet must:

- start from latest accepted `main` on a dedicated branch;
- reverify official tool/dependency compatibility;
- use semantic tokens, Riverpod and typed go_router routes where applicable;
- follow views/view-models, repositories and services;
- keep widgets independent of Supabase/SQLite/Storage clients;
- preserve server authority and immutable history;
- add migrations, RLS, RPC and pgTAP tests with the owning domain;
- implement loading/empty/stale/offline/pending/provisional/conflict/error states;
- support accessibility, reduced motion and responsive behavior;
- include deterministic fixtures before unavailable integrations;
- update documentation and audit evidence;
- create no external infrastructure or secrets beyond explicit scope.

## 3. Technology baseline

```text
Android and dashboard        Flutter 3.44.7 / Dart (task-start reverified)
State and DI                 Riverpod
Routing                      go_router typed routes/stateful shells
Backend                      Supabase Auth/Postgres/Storage
Authoritative operations     Postgres functions/RPC
Recurring jobs               Supabase Cron / pg_cron
Mobile local persistence     SQLite / sqflite
Mobile background retry      WorkManager integration
Dashboard draft recovery     IndexedDB-backed adapter
Dashboard hosting            Vercel static SPA
CI/CD                        GitHub Actions + Supabase CLI
Security                     OWASP ASVS 5.0 + MASVS
Accessibility                WCAG 2.2 AA-equivalent / Android semantics
```

Exact package versions are pinned by the task that first introduces them.

## 4. Phase and packet sequence

```text
Phase 1   TASK-IMP-001   Repository and quality foundation
Phase 2A  TASK-IMP-002A  Identity, sessions, profiles and ownership
Phase 2B  TASK-IMP-002B  Shared design system and Android shell/Home
Phase 2C  TASK-IMP-002C  Responsive dashboard shell and Overview
Phase 3A  TASK-IMP-003A  Exercise library and structured guidance
Phase 3B  TASK-IMP-003B  Private images and YouTube references
Phase 3C  TASK-IMP-003C  Routine editor, validation, review and publication
Phase 4   TASK-IMP-004   Weekly plans, allocations, locks, swaps and wallet grants
Phase 5A  TASK-IMP-005A  Android workout logger, SQLite and synchronization
Phase 5B  TASK-IMP-005B  Workout guidance, media cache and YouTube playback
Phase 6   TASK-IMP-006   Rank, XP, wallet, Progress and weekly finalization
Phase 7   TASK-IMP-007   Progression, substitutions, protection and corrections
Phase 8   TASK-IMP-008   Production hardening, export, deployment and recovery
```

Packets after 002C may be split only when the split preserves one coherent vertical capability and updates this plan.

# Phase 1 — Repository and quality foundation

Packet: `TASK-IMP-001`
Status: `COMPLETE AND MERGED`

## Deliverables

- native Dart Pub workspace;
- Android-only Flutter shell;
- Web-only Flutter dashboard shell;
- domain/data/ui package shells;
- exact Flutter 3.44.7 pin and root lockfile;
- local Supabase config, empty/synthetic seed and pgTAP smoke test;
- Vercel SPA rewrite file only;
- root commands for format/analyze/test/build/database checks;
- GitHub Actions for repository, Flutter and local Supabase verification;
- secret/config ignore rules and setup documentation.

## Explicit exclusions

No authentication, state/routing framework requirement, product schema, Storage, UI features, SQLite features, remote projects or deployment.

## Gate

Both apps build, local database resets/tests/lints, CI passes, no secrets, documentation reflects foundation only.

# Phase 2A — Identity, sessions, profiles and ownership

Packet: `TASK-IMP-002A`
Status: `COMPLETE AND MERGED THROUGH PR #7`

## Database/server

- profiles/preferences/capabilities/status events;
- compatibility/maintenance bootstrap;
- Auth-profile linkage;
- owner RLS and privileged-field denial;
- bootstrap and preference functions;
- trusted operator provision/reset/deactivate/revoke tooling;
- pgTAP cross-user and function-grant tests.

## Android/dashboard

- Riverpod, go_router and Supabase Flutter introduction;
- native mobile and responsive web login;
- session restoration before private render;
- first-password-change;
- protected routes/intended-route return;
- generic auth/network/rate-limit/disabled states;
- logout/cache clearing and mobile unsynchronized-work interface;
- compatibility/read-only/maintenance state.

## Gate

Two provisioned synthetic users can authenticate independently on both clients; cross-user access fails; sessions, password change, revocation and logout tests pass.

# Phase 2B — Shared design system and Android shell/Home

Packet: `TASK-IMP-002B`
Status: `PLANNED — BLOCKED BY 002A`

## Deliverables

- system/dark/light semantic design system;
- shared state, feedback and accessibility primitives;
- Home/Week/Progress/Profile stateful shell;
- all 20 rank asset mapping;
- full 360-degree inactive track and accurate active rank progress;
- fixture-driven Home, today card, week strip and metrics;
- all authoritative/provisional/pending/stale/offline/error states;
- reduced-motion and event-driven motion;
- fixture gallery, golden/semantics/performance tests.

No real schedule, workout or rank persistence.

# Phase 2C — Responsive dashboard shell and Overview

Packet: `TASK-IMP-002C`
Status: `PLANNED — BLOCKED BY 002A/SHARED UI`

## Deliverables

- compact drawer, medium rail, expanded sidebar;
- Overview/Routines/Exercises/Reviews/Activity/Settings routes;
- attention-first fixture Overview and resumable work;
- global search shell;
- command palette and shortcut help;
- save/offline/conflict status primitives;
- responsive list-detail/supporting-pane scaffolds;
- browser URL/back/forward/refresh behavior;
- accessibility, theme and golden baseline.

No product persistence.

# Phase 3A — Exercise library and structured guidance

Packet: `TASK-IMP-003A`
Status: `PLANNED`

## Database/server

- muscle taxonomy;
- exercise definitions/secondary muscles;
- guidance drafts and immutable revisions;
- revision/content hashes;
- owner RLS, clone behavior and publish functions;
- validation/optimistic concurrency;
- migration/pgTAP tests.

## Dashboard

- adaptive exercise list-detail;
- search/filter/sort;
- create/edit/archive/clone;
- structured guidance editor;
- autosave through browser draft cache and server revision checks;
- version history shell, usage and publication status;
- conflict comparison/recovery.

## Android

Read-only placeholder contracts for later pinned guidance; no editor.

# Phase 3B — Private media and YouTube

Packet: `TASK-IMP-003B`
Status: `PLANNED`

## Database/Storage/server

- guidance media metadata and YouTube reference tables;
- private `exercise-media` bucket;
- 5 MB and MIME restrictions;
- owner/path/reviewer Storage RLS;
- immutable object paths and no silent overwrite;
- upload-finalization and cleanup functions/jobs;
- Storage allow/deny and backup-manifest tests.

## Dashboard

- EXIF/GPS removal, orientation correction, resize/re-encode/hash;
- upload progress/cancel/retry;
- six-image limit, cover selection, alt text and keyboard reorder;
- YouTube URL normalization, official preview and errors;
- side-by-side mobile preview;
- media history and immutable-object explanation.

# Phase 3C — Routine editor, validation, review and publication

Packet: `TASK-IMP-003C`
Status: `PLANNED`

## Database/server

- routine drafts/days/prescriptions;
- validation runs with stable field paths;
- immutable submission snapshot/content hash;
- reviewer decision and self-review denial;
- immutable routine versions/days/prescriptions;
- future effective date/publication functions;
- RLS and concurrency tests.

## Dashboard

- routine library;
- seven-day editor;
- exercise/guidance picker;
- prescription editor/reorder/duplicate;
- live duration/set/muscle summaries;
- linked validator summary;
- mobile preview;
- submit/review/diff/approve/reject;
- version compare and duplicate-as-new-draft.

# Phase 4 — Weekly plans, allocations, locks and swaps

Packet: `TASK-IMP-004`
Status: `PLANNED`

## Database/server

- training weeks and exactly seven plan items;
- pinned routine/guidance/config snapshots;
- deterministic RR/base-XP/penalty allocation;
- schedule snapshots and locks;
- monthly credit grants and wallet ledger;
- swap preview/confirm and exact payment;
- idempotent materialization/grant cron plus catch-up;
- timezone/DST/concurrency/anti-exploit tests.

## Android

- real Week UI;
- Home today/week binding;
- item detail, allocations, locks and explanations;
- two-date swap selection, recovery warnings, before/after preview and payment choice.

## Dashboard

Published/current/upcoming schedule summary only where useful; no ordinary schedule editing.

# Phase 5A — Android workout logger and synchronization

Packet: `TASK-IMP-005A`
Status: `PLANNED`

## Database/server

- workout sessions/exercise snapshots/sets;
- sync batches/submission attempts/results;
- start/sync/submit RPCs;
- sequence/idempotency/concurrency validation;
- performance/PR evidence foundations;
- grace-expiry state and tests.

## Android

- workout overview and authoritative online start;
- active logger showing target, previous and best values;
- load/reps/RIR input and one-tap set completion;
- automatic rest timer and next-incomplete-set;
- SQLite versioned schema, transaction autosave, session snapshot and outbox;
- offline continuation;
- WorkManager best-effort network retry;
- pending submission, conflict/repair and result review;
- notification permission/rest/reminder behavior without exact alarms;
- logout/expiry quarantine fully implemented.

# Phase 5B — Workout guidance and media playback

Packet: `TASK-IMP-005B`
Status: `PLANNED`

## Android

- pinned workout/exercise guidance;
- text and image prefetch/cache for active session;
- placeholders/retry/offline state;
- official YouTube IFrame in Android WebView;
- no autoplay/download/background/reward coupling;
- guidance navigation preserves logger fields/timers/focus/scroll;
- cache cleanup and security tests.

# Phase 6 — Rank, XP, wallet, Progress and finalization

Packet: `TASK-IMP-006`
Status: `PLANNED`

## Database/server

- rank account snapshot;
- append-only RR/XP ledgers;
- PR events/cap;
- milestones/streak/multiplier;
- weekly evaluations/finalization;
- missed penalties/decay/top-ups/bonuses;
- rank snapshots and explanations;
- rest/grace/finalization cron and catch-up;
- exact idempotency/concurrency/config tests.

## Android

- Home rank hero bound to authoritative snapshot/events;
- Progress calendar/list history;
- exercise charts/PR history;
- rank ladder and calculation explanation;
- RR/XP/wallet transactions;
- milestone, penalty, decay and provisional/finalized states;
- completed workout result/history.

## Dashboard

Read-only activity/evidence views as useful; authoritative product operations remain server-side.

# Phase 7 — Progression, substitutions, protection and corrections

Packet: `TASK-IMP-007`
Status: `PLANNED`

- comparable-performance progression recommendations and `Why?` evidence;
- explicit overrides without silent routine mutation;
- pain flags without diagnosis;
- substitutions and comparability effects;
- item/full-week protection workflow;
- correction cases and exact reversal entries;
- Android/dashboard UI and audit history;
- RLS/authority/concurrency tests.

# Phase 8 — Production hardening, export and release

Packet: `TASK-IMP-008`
Status: `PLANNED`

## Environments/deployment

- hosted staging and production Supabase;
- production Vercel static deployment;
- preview deployment protection and staging-only data;
- security headers/CSP/cache policy;
- standard Flutter Web build baseline; Wasm benchmark/compatibility spike;
- signed Android release and private distribution/Play internal evaluation;
- compatibility/read-only/maintenance controls verified.

## Security/accessibility/performance

- ASVS/MASVS verification;
- RLS/Storage/function privilege audit;
- database advisors/index/query review;
- dependency/secret/artifact scanning;
- WCAG/dashboard and Android accessibility audit;
- API 24 and supported-browser performance;
- rate-limit/CAPTCHA decision;
- no sensitive logging.

## Operations/lifecycle

- Logs Explorer/Cron monitoring and alerts;
- user-safe diagnostics;
- CSV/JSON private export;
- operator deactivation/hard-delete runbook;
- managed database backups;
- encrypted logical and Storage exports;
- manifest/hash reconciliation;
- demonstrated restore drill;
- RPO 24 hours/RTO 4 hours;
- operational/runbook and rollback evidence.

## 5. Cross-cutting test suites

### Client

- domain/repository/provider/controller unit tests;
- widget, semantics and golden tests;
- router/deep-link/browser tests;
- Android integration/offline/recovery tests;
- dashboard keyboard/focus/resize/refresh/conflict tests;
- lifecycle/memory/performance checks.

### Database

- clean migration reset;
- pgTAP structure/constraints/index/RLS/functions;
- anonymous/owner/other/reviewer matrices;
- duplicate/stale/concurrent/idempotent cases;
- 4/5/6-day allocation/timezone/DST/finalization fixtures;
- Storage allow/deny;
- backup/restore reconciliation.

### End to end

- provision/login/password change;
- exercise/guidance/media;
- routine validation/review/publication;
- materialization/swap;
- start/log/offline/sync/submit;
- finalization/rank/wallet/history;
- protection/correction;
- session expiry/logout with pending data;
- staging/release/restore.

## 6. Deliberate MVP exclusions

No public signup/recovery, social features, nutrition, sleep, wearables, AI coach, form camera, marketplace, direct video upload, iOS, offline workout start, client-authoritative scoring, full offline dashboard, Realtime requirement, analytics/advertising SDK or unrestricted rewarded extra workouts.

## 7. Exact next action

After the `TASK-PD-016` planning pull request merges, execute the approved bounded mobile packet:

```text
TASK-IMP-002B — shared design system and Android shell/Home
branch: codex/task-imp-002b-mobile-shell-home
packet: docs/tasks/TASK-IMP-002B.md
```

`TASK-IMP-002C` remains unapproved and must not start.
