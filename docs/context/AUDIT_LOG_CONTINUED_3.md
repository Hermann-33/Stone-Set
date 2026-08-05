# Stone Set Audit Log — Continued, Volume 3

This volume continues material audit history after `AUDIT_LOG_CONTINUED_2.md` and preserves earlier audit files unchanged.

## 2026-08-05 — TASK-PD-013 — Final implementation-readiness audit

### Scope

- review every planned Android, dashboard and Supabase aspect;
- research current official implementation/security/platform guidance;
- identify unresolved planning gaps;
- choose client state/routing architecture;
- define implementation-grade relational/server plan;
- create missing identity packet;
- synchronize roadmap, implementation and UI plans;
- preserve Phase 1 as not started.

### Starting state

- product/rank/scheduling/auth/media/offline/operations decisions existed;
- complete mobile/dashboard UI plan existed;
- rank assets existed;
- foundation packet was approved but unexecuted;
- identity work was referenced as `TASK-IMP-002A` but no packet file existed;
- database entities, RPC boundaries, concurrency, cron, compatibility, lifecycle and observability were distributed assumptions rather than one canonical plan;
- mobile UI packet still named the obsolete `History` tab instead of `Progress`.

### Research reviewed

Primary current sources included:

- Flutter application architecture, offline-first, SQL, Web and deployment guidance;
- go_router and Riverpod documentation;
- Supabase Auth, RLS, functions, migrations, pgTAP, Storage, Cron, logs, backups and production guidance;
- Vercel rewrites, headers, deployment protection and production checklist;
- Android WorkManager, notifications, alarms and storage guidance;
- WCAG 2.2;
- OWASP ASVS 5.0 and MASVS.

### Accepted technology decisions

1. Flutter and Dart remain both client technologies.
2. Riverpod is the single state/DI system.
3. go_router typed routes/stateful shells own client navigation.
4. Client architecture uses views/view models, repositories and services.
5. Domain stays independent of Flutter/Supabase.
6. SQLite/sqflite stores Android active draft/snapshot/outbox data.
7. Dashboard draft recovery uses an IndexedDB-backed adapter.
8. WorkManager provides best-effort constrained retry only.
9. No continuous polling or Supabase Realtime requirement in MVP.
10. Standard Flutter Web release build is initial baseline; Wasm is evaluated later.
11. No exact-alarm permission in MVP.
12. ASVS/MASVS/WCAG are verification baselines.

### Accepted database/server decisions

- explicit `public`, unexposed `private`, managed `auth`, `storage` and `cron` boundaries;
- complete identity, guidance, routine, schedule, workout, rank and correction domains;
- UUID/timestamptz/IANA-timezone conventions;
- immutable published/materialized/finalized records;
- append-only RR/XP/wallet/audit ledgers and exact reversal links;
- RLS on every exposed private relation;
- security invoker by default and hardened security definer only where necessary;
- explicit function grants;
- unique idempotency constraints, expected draft revisions and transaction locks;
- idempotent Cron for materialization/grants/rest/grace/finalization/cleanup;
- application-triggered catch-up for missed jobs;
- client compatibility/read-only/maintenance configuration;
- structured redacted correlation logging;
- export, deactivation and hard-delete runbook;
- phase-owned migration map and pgTAP matrix.

### Accepted synchronization decisions

- online authoritative workout start;
- immutable server session snapshot;
- transactional local autosave;
- versioned outbox with sequence and idempotency;
- sync on foreground/connectivity/explicit retry/submission/background best effort;
- pending completion remains non-authoritative;
- conflict never silently discards local work;
- same-account quarantine on session loss;
- dashboard offline support protects drafts only, not authority-changing actions.

### Security/operations decisions

- no secrets/service-role in Flutter clients;
- operator Auth actions through trusted tooling only;
- no sensitive payloads in logs;
- Vercel SPA rewrites, preview protection, CSP/security headers and cache control;
- standard build before Wasm/COOP/COEP adoption;
- migrations in Git and no remote schema edits;
- Logs Explorer/Cron/advisors initial observability;
- managed DB backup plus independent encrypted DB/Storage exports;
- Storage manifest/hash reconciliation;
- RPO 24 hours, RTO 4 hours and restore drills;
- no analytics/crash SDK without a separate decision.

### Files created

- `docs/context/TECHNOLOGY_BASELINE.md`
- `docs/context/DATABASE_AND_SERVER_PLAN.md`
- `docs/context/SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md`
- `docs/context/AUDIT_LOG_CONTINUED_3.md`
- `docs/tasks/TASK-PD-013.md`
- `docs/tasks/TASK-IMP-002A.md`

### Files materially synchronized

- `docs/context/ACTIVE_CONTEXT.md`
- `docs/context/CODEBASE_MAP.md`
- `docs/context/ROADMAP.md`
- `docs/context/IMPLEMENTATION_PLAN.md`
- `docs/context/UI_IMPLEMENTATION_PLAN.md`
- `docs/context/HANDOFF.md`
- `docs/tasks/TASK-IMP-002B.md`
- `docs/tasks/TASK-IMP-002C.md`
- Pull Request #2 description/title.

### Readiness verdict

```text
Android application      ACCOUNTED FOR
Web dashboard            ACCOUNTED FOR
Database/backend         ACCOUNTED FOR
Authorization            ACCOUNTED FOR
Offline/sync             ACCOUNTED FOR
Media                    ACCOUNTED FOR
Cron/finalization        ACCOUNTED FOR
Security/accessibility   ACCOUNTED FOR
Testing/CI               ACCOUNTED FOR
Deployment/operations    ACCOUNTED FOR
Backup/lifecycle/export  ACCOUNTED FOR
```

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Exact next action

Merge planning Pull Request #2 after review, then execute `TASK-IMP-001` on `codex/task-imp-001-foundation`.

### Verdict

`COMPLETE`

Stone Set has a complete implementation-ready MVP plan. General discovery does not need to reopen unless scope or official platform evidence materially changes.

## 2026-08-05 — TASK-IMP-001 — Foundation implementation audit

### Scope

- create the native Dart Pub workspace;
- scaffold Android-only and Web-only Flutter applications;
- create neutral domain/data/ui package foundations;
- create local-only Supabase configuration and a pgTAP runner smoke test;
- add exact tool/dependency pins, root commands, hygiene checks and GitHub Actions CI;
- preserve all authentication, product, media, persistence and deployment exclusions.

### Implemented foundation

- workspace members are `apps/mobile`, `apps/dashboard`, `packages/domain`, `packages/data` and
  `packages/ui` with one root lockfile;
- mobile uses Android only, application ID `io.github.hermann33.stoneset`, API 24 and debug signing;
- dashboard uses Web only and contains the static Vercel SPA rewrite without project linkage;
- package direction is `data -> domain`, `ui -> Flutter`, `domain -> Dart SDK`;
- both applications and the neutral shared UI primitive have accessibility semantics tests;
- local Supabase contains non-secret configuration, an empty seed and one pgTAP smoke test;
- cross-platform Dart commands cover restore, formatting, analysis, tests, builds, repository checks
  and local Supabase lifecycle;
- `.github/workflows/foundation-ci.yml` contains independent repository, Flutter/Dart and Supabase jobs.

### Exact pins

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
args          2.7.0
yaml          3.1.3
test          1.31.0
flutter_lints 6.0.0
```

### Verification result

Passing local evidence:

- locked root resolution;
- machine-readable tool-version check;
- repository structure, dependency direction, generated-file and secret-path checks;
- formatting and strict analysis;
- root tooling, pure Dart and Flutter widget tests;
- Flutter Web release build;
- bounded secret/configuration/dependency security review.

Open evidence:

- Android release APK is blocked because the local host has no Android SDK/`ANDROID_HOME`;
- Supabase start/reset/pgTAP/lint is blocked because no Docker/Podman-compatible runtime exists;
- GitHub Actions CI has not run;
- final diff, commit, push and draft pull request are pending.

No APK or local database result is inferred from scaffold presence. The task and Phase 1 remain
partial until those gates succeed.

### Security and workflow review

- no secrets, credentials, accounts, personal data, signing material or private media were added;
- no Supabase/Vercel project was created, linked or deployed;
- the foundation CI uses pinned action commits, `contents: read` and checkout without persisted credentials;
- the pre-existing rank-asset workflow retains writable contents permission and unpinned major action
  tags. This medium risk was not introduced by `TASK-IMP-001` and is recorded as a deferred exception.

### Explicit non-implementation

No authentication/login/profile/session behavior, product schema/RLS, Storage, routines, guidance,
workouts, SQLite synchronization, RR/XP/rank/wallet behavior, media, YouTube playback, remote
infrastructure, deployment, production signing or iOS support is implemented.

### Verdict

`PARTIAL`

The implemented foundation is coherent and its available local checks pass, but required environment,
CI and Git/PR gates remain open.

### Exact next action

The coordinator inspects the final diff, commits and pushes `codex/task-imp-001-foundation`, opens a
draft pull request and obtains CI results. Configure an Android SDK and Docker-compatible runtime to
close the remaining local Android and Supabase gates before declaring the task complete.
