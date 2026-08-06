# Stone Set System Implementation Readiness Audit

Updated: 2026-08-05
Status: `COMPLETE — READY FOR BOUNDED IMPLEMENTATION`
Task: `TASK-PD-013`

## 1. Audit objective

Verify that the implementation plan accounts for every material aspect of:

- the Android application;
- the Flutter Web dashboard;
- Supabase Auth, Postgres and Storage;
- local persistence and synchronization;
- authoritative product operations;
- accessibility, security, testing, deployment, observability and recovery.

This audit does not claim that the system is implemented. It verifies that the intended system is sufficiently specified to proceed through bounded implementation packets without inventing core architecture during coding.

## 2. Research method

The audit compared the repository's accepted product and architecture documents with current primary guidance from:

- Flutter application architecture, offline-first, SQL persistence, routing, testing and web deployment documentation;
- Riverpod and go_router documentation;
- Supabase Auth, RLS, functions, migrations, database testing, Storage, Cron, logs, backups and production guidance;
- Vercel routing, headers, deployment protection and production guidance;
- Android background-work, notifications, alarm and storage guidance;
- W3C WCAG 2.2;
- OWASP ASVS 5.0 and MASVS.

The earlier UI research also reviewed established workout, coaching and productivity products and community feedback. Competitor behavior is used only as design evidence; no proprietary UI or code is copied.

## 3. Verdict

```text
Product behavior              ACCOUNTED FOR
Android application           ACCOUNTED FOR
Flutter Web dashboard         ACCOUNTED FOR
Authentication/sessions       ACCOUNTED FOR
Database domains              ACCOUNTED FOR
RLS and privileges            ACCOUNTED FOR
Atomic server operations      ACCOUNTED FOR
Offline/synchronization       ACCOUNTED FOR
Storage/media                  ACCOUNTED FOR
Scheduling/cron               ACCOUNTED FOR
Rank/wallet/finalization       ACCOUNTED FOR
Accessibility                 ACCOUNTED FOR
Security                      ACCOUNTED FOR
Testing/CI                    ACCOUNTED FOR
Deployment/versioning         ACCOUNTED FOR
Observability                 ACCOUNTED FOR
Backup/restore                ACCOUNTED FOR
Export/account lifecycle      ACCOUNTED FOR
```

The system is ready to move from planning into `TASK-IMP-001` foundation work. Later packets still require prerequisite verification and exact dependency/version checks before authorization.

## 4. Gap found and closed

Before this audit, Stone Set had detailed product workflows, UI specifications and phase ownership, but no single implementation-grade definition of:

- database domains and relationships;
- server RPC/function catalogue;
- RLS policy model;
- concurrency and idempotency;
- scheduled jobs and catch-up paths;
- synchronization state machines;
- data retention/export/deletion;
- client compatibility controls;
- observability and operator tooling;
- selected state-management/routing architecture.

The gap is closed by:

- `docs/context/TECHNOLOGY_BASELINE.md`;
- `docs/context/DATABASE_AND_SERVER_PLAN.md`;
- `docs/tasks/TASK-IMP-002A.md`;
- synchronized implementation and UI plans.

## 5. Android application coverage

### Identity and bootstrap

Covered:

- native username/password login;
- persisted session restoration before private rendering;
- active profile verification;
- mandatory first-password-change;
- generic errors and rate limits;
- session expiry and same-account draft quarantine;
- app compatibility/maintenance bootstrap;
- logout with pending-draft resolution.

### Navigation and presentation

Covered:

- Home, Week, Progress and Profile stateful branches;
- typed deep routes for workout, guidance, results, rank and corrections;
- route/scroll state restoration;
- full-circle rank progress;
- all loading/offline/stale/pending/provisional/error states;
- themes, reduced motion, text scaling and semantics.

### Workout execution

Covered:

- online authoritative start;
- immutable prescription/guidance snapshot;
- previous/best comparable performance;
- set/load/repetitions/RIR logging;
- transactional SQLite autosave;
- rest timer and background-safe timestamp reconstruction;
- guidance without losing logger state;
- offline continuation;
- idempotent outbox;
- pending submission and 24-hour grace;
- result and correction flows.

### Platform integration

Covered:

- internal app storage;
- WorkManager best-effort retry only;
- contextual notification permission;
- no exact-alarm permission;
- optional rest/reminder notifications;
- private cache cleanup;
- Android API 24+;
- signed private release and later Play testing.

## 6. Dashboard coverage

### Authentication and routing

Covered:

- responsive `/login`;
- protected routes and intended-route return;
- browser back/forward/direct URLs;
- compact drawer, medium rail and expanded sidebar;
- URL-backed list/detail selection;
- safe logout and cache clearing.

### Productivity shell

Covered:

- attention-first Overview;
- resumable drafts;
- search;
- command palette;
- shortcut help;
- visible save/offline/conflict states;
- responsive list-detail/supporting panes;
- keyboard and screen-reader operation.

### Authoring and review

Covered:

- exercise library;
- structured guidance editor;
- media upload, validation, alt text and ordering;
- YouTube validation/preview;
- mobile preview;
- seven-day routine editor;
- live duration/volume context;
- linked validation errors;
- immutable submission/diff/review;
- version history and duplicate-as-new-draft restoration.

### Browser persistence and release

Covered:

- IndexedDB-backed recovery adapter;
- optimistic-concurrency conflicts;
- private cache cleanup;
- standard Flutter Web release baseline;
- Vercel SPA routing, security headers and cache rules;
- staging-only previews;
- Wasm evaluation deferred until cross-origin compatibility passes.

## 7. Database and backend coverage

### Domain completeness

Planned domains cover:

- profiles/preferences/capabilities;
- client compatibility;
- exercises/muscles/guidance/media/YouTube;
- routine drafts/validation/submission/review/versions;
- training weeks/plan items/snapshots/swaps/credits;
- sessions/exercises/sets/sync/submissions/results;
- performance/PR/progression;
- rank/XP/wallet/weekly evaluation/milestones;
- protections/pain/substitutions/corrections;
- activity/audit/export/lifecycle.

### Integrity

Covered:

- UUID identity;
- explicit timezone/date handling;
- immutable published/finalized history;
- content hashes;
- append-only ledgers and exact reversals;
- unique idempotency constraints;
- row locks/advisory locks where required;
- optimistic draft revision checks;
- deterministic allocation and stored configuration versions.

### Authorization

Covered:

- RLS for every exposed private table;
- owner and reviewer boundaries;
- direct authoritative writes denied;
- security-invoker views;
- explicit RPC grants;
- security-definer hardening;
- Storage owner/path policies;
- anonymous/cross-user negative tests.

### Recurring operations

Covered:

- week materialization;
- monthly grants;
- rest resolution;
- grace expiry;
- weekly finalization;
- draft/export cleanup;
- job history and catch-up operations.

## 8. Security and privacy coverage

Covered:

- service-role separation;
- no passwords/tokens in product tables or logs;
- publishable client configuration only;
- TLS and web security headers;
- ASVS/MASVS verification baselines;
- dependency and secret scanning;
- private Storage and signed/authenticated media access;
- redacted correlation logging;
- no analytics or crash telemetry without a separate decision;
- no private data in preview/staging or Git;
- operator provisioning/recovery in trusted tooling only.

Accepted risk:

- SQLite is not application-level encrypted in MVP. Data is minimized, kept in Android internal storage, scoped by user and cleared/quarantined under strict rules. This risk is reviewed again during mobile security hardening. Credentials and tokens are excluded from the feature database.

## 9. Accessibility coverage

Covered:

- dashboard WCAG 2.2 AA-equivalent target;
- visible and unobscured focus;
- full keyboard operation and no traps;
- field errors plus linked summaries;
- status-message announcements;
- meaningful labels and instructions;
- non-color state communication;
- 200% text scaling;
- reduced motion;
- Android semantics and touch targets;
- image alt text;
- accessible drag/reorder alternatives.

## 10. Test coverage plan

### Client

- unit tests for domain and presentation state;
- repository/service tests with fakes;
- provider tests;
- widget, semantics and golden tests;
- route/deep-link tests;
- Android integration/offline/recovery tests;
- browser keyboard/focus/refresh/resize tests;
- performance and lifecycle profiling.

### Database

- clean migration reset;
- pgTAP structure/constraint/index tests;
- RLS allow/deny tests;
- RPC state/concurrency/idempotency tests;
- timezone/DST/allocation/finalization fixtures;
- Storage policy tests;
- restore/reconciliation tests.

### End to end

- provision -> login -> password change;
- guidance -> routine -> review -> publication;
- materialize -> swap -> workout -> sync -> result;
- week finalization -> rank/wallet/history;
- correction/protection;
- logout/session expiry with and without pending drafts;
- staging deployment and signed Android release.

## 11. Operations and recovery coverage

Covered:

- local/staging/production isolation;
- migrations in Git only;
- coordinated production deployment;
- compatibility/read-only controls;
- preview protection;
- Supabase Logs/Cron/advisors;
- correlation IDs and diagnostics;
- managed database backups;
- independent logical and Storage exports;
- hash manifest and restore reconciliation;
- RPO 24 hours and RTO 4 hours;
- restore drill before release and quarterly thereafter;
- two Supabase owners with MFA and backup factors.

## 12. Features intentionally not planned

The absence of these is deliberate rather than an oversight:

- public signup or public recovery;
- social feed/public profiles;
- nutrition/sleep tracking;
- wearables;
- AI coach/chat;
- camera form analysis;
- direct video upload;
- public marketplace;
- offline workout start;
- client-authoritative rewards;
- unrestricted unscheduled rewarded workouts;
- iOS initial release;
- full offline dashboard publication;
- Supabase Realtime in MVP;
- analytics/advertising SDKs.

## 13. Implementation readiness gates

Before each task becomes `APPROVED`, verify:

1. prerequisites are merged;
2. official dependency/tool compatibility is current;
3. the task starts from latest `main`;
4. no accepted decision conflicts exist;
5. migrations and UI ownership remain bounded;
6. tests and rollback/recovery are defined;
7. no secrets or external infrastructure are implied outside scope.

## 14. Exact continuation

1. Phase 1 and `TASK-IMP-001` are complete and merged.
2. `TASK-IMP-002A` began after PR #6 merged but is partial because its approved exact dependency
   graph is unsatisfiable under Flutter 3.44.7/Dart 3.12.2.
3. Approve a coordinated compatible dependency amendment, update the packet and resume 002A on
   `codex/task-imp-002a-identity-sessions`.
4. Do not execute 002B or 002C until 002A passes every acceptance gate and merges.

No new product discovery phase is required. The current blocker is a bounded dependency-baseline
decision supported by official package constraints and local resolver evidence.
