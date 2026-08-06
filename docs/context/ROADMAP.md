# Stone Set Roadmap

Updated: 2026-08-06

## Completion rule

A phase is complete only when its applicable application, dashboard, database, authorization, synchronization, testing, accessibility, security, documentation, deployment and recovery gates are implemented and evidenced.

## Phase 0 — Product, architecture and implementation planning

Status: `COMPLETE`

Completed planning tasks include:

- product/routine/rank/scheduling definition;
- authentication/session UX;
- Android, dashboard and Supabase architecture;
- media and YouTube policy;
- offline and synchronization model;
- rank-emblem asset set;
- complete Android/dashboard UI system;
- technology/dependency baseline;
- implementation-grade database/server plan;
- final system readiness audit;
- bounded packets for foundation, identity, mobile shell and dashboard shell.

Planning verdict:

```text
Every material MVP surface and system boundary is accounted for.
No general discovery phase remains before foundation implementation.
```

## Phase 1 — Repository and quality foundation

Status: `COMPLETE`
Packet: `TASK-IMP-001 — COMPLETE AND MERGED`

Implemented and verified on `codex/task-imp-001-foundation`:

- Flutter 3.44.7/Dart 3.12.2 native Pub workspace and one root lockfile;
- Android-only and Web-only accessible placeholder shells;
- domain/data/ui foundation packages and focused tests;
- local Supabase configuration, empty seed and pgTAP runner smoke test;
- Node.js 24.11.1 and Supabase CLI 2.111.0 project-local pins;
- cross-platform restore/format/analyze/test/build/database commands;
- least-privilege GitHub Actions foundation workflow;
- non-secret configuration templates and repository hygiene checks;
- no product feature implementation.

Passing local gates:

- locked resolution and tool-version checks;
- repository structure/dependency/secret checks;
- formatting and strict analysis;
- all Dart and Flutter tests;
- Flutter Web release build;
- bounded security review.

Completion evidence and local parity note:

- pull request #5 is merged at `3d0830767fd5320f33a4b7a209d937d2b59f7a6e`;
- GitHub Actions run `31003516689` passed repository, Flutter/Dart, Android/Web build and local
  Supabase lifecycle gates;
- this Windows host still requires an Android SDK and Docker/Podman for full local CI parity.

## Phase 2A — Identity, sessions, profiles and ownership

Status: `COMPLETE ON DRAFT PR #7 — PENDING REVIEW AND MERGE`
Packet: `TASK-IMP-002A — EXECUTED AND VERIFIED`

- provisioned Supabase identities;
- profiles/preferences/capabilities;
- mobile and dashboard login/password change;
- session restoration/guards/logout/revocation;
- compatibility/maintenance bootstrap;
- trusted operator account tooling;
- RLS and cross-user tests.

## Phase 2B — Shared design system and Android shell/Home

Status: `PLANNED`
Packet: `TASK-IMP-002B`

- Riverpod/go_router mobile presentation foundation;
- Home, Week, Progress and Profile;
- rank assets and 360-degree progress hero;
- fixture Home/today/week/metrics;
- themes, state patterns, accessibility, motion and golden baseline.

## Phase 2C — Responsive dashboard shell and Overview

Status: `PLANNED`
Packet: `TASK-IMP-002C`

- drawer/rail/sidebar adaptive shell;
- Overview/Routines/Exercises/Reviews/Activity/Settings;
- attention queue and resumable work;
- search, command palette and shortcut help;
- save/offline/conflict states;
- responsive primitives and browser navigation.

## Phase 3A — Exercise library and structured guidance

Status: `PLANNED`
Packet: `TASK-IMP-003A`

- muscles/exercises;
- guidance drafts/revisions;
- owner RLS and publish/clone/versioning;
- adaptive exercise/guidance dashboard UI;
- browser draft recovery and concurrency.

## Phase 3B — Private media and YouTube

Status: `PLANNED`
Packet: `TASK-IMP-003B`

- private Storage bucket/policies;
- immutable image metadata/paths;
- preprocessing/upload/alt text/order/cover;
- YouTube normalization/official preview;
- mobile preview, cleanup and backup manifest.

## Phase 3C — Routine validation, review and publication

Status: `PLANNED`
Packet: `TASK-IMP-003C`

- seven-day routine drafts/prescriptions;
- validator runs/field paths/content hashes;
- immutable submission and independent review;
- published future-effective versions;
- three-pane/compact editor, diff and version history.

## Phase 4 — Weekly planning, allocations, swaps and grants

Status: `PLANNED`
Packet: `TASK-IMP-004`

- materialized training weeks/seven plan items;
- pinned routine/guidance/config snapshots;
- deterministic RR/XP/penalty allocation;
- locks/snapshots/swaps/payment;
- credit ledger/monthly grants;
- cron and catch-up;
- real Home/Week binding.

## Phase 5A — Android workout execution and synchronization

Status: `PLANNED`
Packet: `TASK-IMP-005A`

- online authoritative start;
- active logger with previous/best/target;
- set/load/reps/RIR/rest and completion;
- SQLite draft/snapshot/outbox;
- offline continuation and pending submission;
- WorkManager best-effort retry;
- result, conflict, logout/expiry quarantine.

## Phase 5B — Workout guidance and media playback

Status: `PLANNED`
Packet: `TASK-IMP-005B`

- pinned guidance in active workout;
- text/image prefetch and cache;
- official YouTube IFrame/WebView;
- offline/failure states;
- logger-state preservation and cache cleanup.

## Phase 6 — Rank, XP, wallet, Progress and finalization

Status: `PLANNED`
Packet: `TASK-IMP-006`

- RR/XP append-only ledgers;
- rank account/snapshots;
- PRs, consistency, milestones, penalties and decay;
- weekly evaluation/finalization cron/catch-up;
- Progress calendar/history/charts/rank/wallet/explanations;
- authoritative Home rank binding.

## Phase 7 — Progression, substitutions, protection and corrections

Status: `PLANNED`
Packet: `TASK-IMP-007`

- double-progression recommendation/evidence;
- explicit override;
- pain flag/substitution;
- item/full-week protection;
- exact correction/reversal workflow and history.

## Phase 8 — Production hardening and release

Status: `PLANNED`
Packet: `TASK-IMP-008`

- hosted staging/production Supabase;
- Vercel preview/production with rewrites/headers/CSP/cache/protection;
- signed Android release;
- compatibility/read-only/maintenance controls;
- ASVS/MASVS/RLS/Storage/accessibility/performance audit;
- logs/cron/advisors/diagnostics;
- CSV/JSON export and account lifecycle runbook;
- managed DB plus independent DB/Storage backups;
- restore drill and RPO/RTO evidence.

## Current position

```text
Phase 0 — COMPLETE
Phase 1 — COMPLETE
Phase 2A — COMPLETE ON DRAFT PR #7, PENDING MERGE
```

## Exact next action

Review and merge draft pull request #7, then perform post-merge verification and separately approve
the next bounded packet.

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
```

The verified 002A sources, migration and tooling are not on `main` until pull request #7 merges.
`TASK-IMP-002B` and `TASK-IMP-002C` remain planned and are not executable.

## Reopening rule

Planning reopens only when product scope changes or current official platform/security evidence invalidates an accepted assumption. Implementation discoveries are resolved inside the owning bounded packet unless they alter architecture or product behavior.
