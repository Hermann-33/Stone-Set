# Stone Set Active Context

Updated: 2026-08-05

## Current state

Stone Set is a private two-user hypertrophy training system with accepted product, authentication, architecture, media, operations, rank assets, and complete Android/dashboard UI/UX planning baselines.

The repository contains documentation and the curated `stone-set-ranks-v1` asset set. There is no Flutter application, Supabase runtime, product schema, Storage bucket, account, Vercel project, deployment, or foundation CI.

## Active phase

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

Latest planning task: `TASK-PD-012`.

Canonical UI documents:

```text
docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md
docs/product/COMPLETE_UI_UX_SYSTEM.md
docs/context/UI_IMPLEMENTATION_PLAN.md
```

## Accepted authentication baseline

- Dedicated Android and dashboard login pages.
- Same provisioned username/password identities on both clients.
- Internal Supabase email alias derived from normalized username.
- No public signup, social login, anonymous access, magic link, or self-service recovery in MVP.
- First login requires password change.
- Sessions persist and private routes require an active profile.
- Errors remain generic.
- Dashboard logout clears private browser state.
- Mobile logout resolves unsynchronized workout data.
- Expired mobile sessions quarantine drafts until the same account reauthenticates.

## Accepted complete UI baseline

### Shared

- Semantic System, Dark, and Light themes.
- Shared colors, typography, spacing, shapes, elevation, motion, chart, focus, validation, error, loading, empty, stale, offline, pending, provisional, conflict, and recovery patterns.
- Width-driven adaptive layouts; no device-type branching.
- WCAG 2.2 AA-equivalent dashboard target and platform-equivalent mobile accessibility.
- 200% text scaling, keyboard access, visible focus, screen-reader semantics, reduced motion, non-color communication, and explicit status messages.
- No continuous idle animation.

### Android application

Primary destinations:

```text
Home | Week | Progress | Profile
```

`Progress` supersedes the narrower `History` label and contains workout history, charts, exercise progress, rank, wallet, milestones, and corrections.

Home:

- centered current-rank emblem;
- complete 360-degree inactive track visible at 0%;
- authoritative clockwise active arc and seamless 100% state;
- finalized/provisional/pending separation;
- today's Start/Continue/Sync/View result action;
- seven-day summary and key metrics.

Workout logger:

- workout overview and persistent session header;
- previous and best comparable performance visible in context;
- load, reps, RIR, set type, completion, notes;
- one-tap valid set completion;
- transactional autosave;
- automatic rest timer;
- next-incomplete-set navigation;
- progression recommendation with `Why?`;
- guidance navigation preserving fields, timers, focus, scroll, and draft state;
- offline continuation after authoritative online start;
- pending submission instead of false final rewards.

Progress:

- calendar and list history;
- filters/search;
- workout and exercise detail;
- charts with text alternatives;
- rank and wallet ledgers;
- immutable transaction, correction, penalty, decay, bonus, milestone, and configuration evidence.

Profile:

- account, units, timezone, appearance, accessibility, alerts, cache, sessions, password, export, logout, and diagnostics.

### Flutter Web dashboard

Primary destinations:

```text
Overview | Routines | Exercises | Reviews | Activity | Settings
```

- Compact drawer, medium navigation rail, expanded persistent sidebar.
- Attention-first Overview and resumable drafts.
- Global search, command palette, searchable shortcut help.
- Visible Saved/Saving/Offline/Syncing/Conflict/Failed state.
- Responsive list-detail and supporting panes.
- Exercise library and structured guidance editor.
- Media upload progress, retry, alt text, reorder, YouTube preview, mobile preview.
- Adaptive routine editor with validation summary linked to exact fields.
- Immutable review diff, approval/rejection evidence, version timeline, and duplicate-as-new-draft restore.
- Human-readable Activity and user-owned data export planning.

## Accepted high-value additions from TASK-PD-012

1. Mobile `Progress` destination.
2. Previous/best comparable performance inside the logger.
3. Automatic rest timer and next-incomplete-set action.
4. Calendar/list history.
5. Dashboard attention-first Overview.
6. Global search and command palette.
7. Discoverable keyboard shortcuts.
8. Explicit autosave/offline/conflict status.
9. Undo for reversible draft actions.
10. Validator summary linked to fields.
11. Side-by-side mobile preview.
12. Version comparison and duplicate-as-new-draft restoration.
13. First-run setup checklist.
14. User-owned CSV/JSON export planned for release hardening.
15. System/Dark/Light appearance modes.

## Explicit exclusions

No social feed, public profile, nutrition, sleep, wearable integration, AI coach/chat, camera form analysis, CRM, coach sales tools, public routine marketplace, or unrestricted unscheduled reward-bearing workouts.

## Accepted product baseline

- Two initial provisioned users; count not hardcoded.
- User-owned draft routines and immutable published versions.
- Independent review required for reward-bearing routine publication.
- `routine-validator-v1` remains authoritative.
- 4–6 workout days, 1–3 rest days, 7 plan items.
- Guidance is user-owned, immutable by revision, and pinned to weeks/sessions.
- Private exercise images in Supabase Storage; optional YouTube embed.
- `rank-v6`, `schedule-v3`, Adonis at 5,500 RR.
- RR/XP allocations, penalties, PR cap, consistency multipliers, swaps, and wallet rules unchanged.
- Unscheduled extra work earns no additional RR or XP.

## Accepted architecture

### Clients and packages

- Flutter Android API 24+ app.
- Separate responsive Flutter Web dashboard.
- Shared native Pub workspace.
- Planned ownership:
  - `apps/mobile/` for mobile composition;
  - `apps/dashboard/` for dashboard composition;
  - `packages/domain/` for pure models/rules;
  - `packages/data/` for repositories/adapters;
  - `packages/ui/` for semantic themes and shared components.

### Backend and authority

- Supabase Auth owns credentials and sessions.
- Postgres and Storage are authoritative for product data and media.
- RLS isolates owners.
- Server operations own publication, review, schedule materialization, workout start, swaps, rewards, penalties, wallet, corrections, and finalization.
- Clients never contain service-role/database secrets and never set authoritative scores.

### Local/offline

- SQLite through `sqflite` for active mobile drafts/outbox.
- Workout start requires connectivity.
- A started workout may continue offline.
- Offline finish becomes `pending_submission`.
- 24-hour post-week synchronization grace.
- Logout/cache cleanup preserves ownership and handles pending drafts explicitly.

### Hosting/operations

- Flutter Web target: Vercel static deployment.
- Local, staging, production separation.
- Production Supabase Pro target with managed database backups and independent encrypted database/Storage exports.
- RPO 24 hours, RTO 4 hours for expected scale.
- Two distinct Owner accounts, MFA, backup factors, least privilege, restore drills.

## Implemented versus documented

### Documented and accepted

Complete product behavior, authentication, architecture, rank, scheduling, exercise guidance/media, mobile UI, dashboard UI, accessibility, responsive behavior, implementation sequence, release, and operations.

### Implemented

Documentation, Git history, and the 20-rank asset set only. No client consumes the assets and no application UI exists.

## Planned packet sequence

```text
TASK-IMP-001 — Foundation — APPROVED, exact next action
TASK-IMP-002A — Identity/login/sessions — PLANNED
TASK-IMP-002B — Shared design/mobile shell — PLANNED, blocked
TASK-IMP-002C — Dashboard shell/Overview — PLANNED, blocked
```

Before `TASK-IMP-002B` approval, change its old `History` destination label to `Progress`.

## Exact next action

Execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
packet: docs/tasks/TASK-IMP-001.md
```

## Do-not-touch boundaries

- Do not claim Phase 1 or a UI milestone has started until implementation exists on its task branch.
- Do not create remote infrastructure, credentials, accounts, real media, or deployment in `TASK-IMP-001`.
- Do not implement login or feature UI in the foundation packet.
- Do not execute `TASK-IMP-002B` or `TASK-IMP-002C` before prerequisites and explicit approval.
- Do not change `rank-v6`, `schedule-v3`, Adonis at 5,500 RR, multiplier ladder, swap limit, or bankable credits.
- Do not expose another user's data through search, activity, export, fixtures, or previews.
- Do not store passwords in application tables or expose privileged credentials to clients.
