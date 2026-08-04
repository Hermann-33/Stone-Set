# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PL-002 — Close implementation constraints and authorize the foundation task`

## Starting state

- Phase 0 remained active.
- `rank-v6`, `schedule-v3`, workflow, Flutter clients, and Supabase architecture were accepted.
- Reward-eligible routine validation, offline behavior, mobile scope, dashboard hosting, production operations, and the first execution packet were unresolved.
- No application code or external infrastructure existed.

## Research and findings

The task reviewed current official Flutter, Dart, Supabase, Vercel, Android/iOS, and resistance-training guidance.

Findings:

1. Complex active workout drafts need structured local persistence; SQLite is the conservative mobile choice.
2. Fully offline authoritative scoring would create unjustified conflict, duplication, clock, and schedule-lock complexity.
3. Online start with offline continuation preserves usability while retaining server authority.
4. Android-first avoids a macOS/Xcode/signing dependency before the first workflow is validated.
5. Flutter Web is static output and fits Vercel previews, promotion, and rollback when built explicitly in CI.
6. Supabase Pro daily backups are proportionate; PITR's additional cost is not justified for two users and a 24-hour RPO.
7. Managed backups need independent encrypted logical exports and demonstrated restores.
8. Routine arithmetic alone cannot prove quality; server hard validation plus independent human review is required.

## Accepted decisions

### Routine eligibility

- `routine-validator-v1` accepted.
- 4–6 workout days, 1–3 rest days, and 32–100 weekly working sets.
- Each workout: 3–10 exercises, 8–20 sets, 20–60 estimated minutes, and at least one priority exercise.
- Valid set, rep, RIR, rest, ordering, equipment, and progression values.
- Independent cross-user review; self-approval prohibited.
- Reviewers approve or reject but cannot edit.
- Approval and publication verify the exact content hash.
- Every reward-bearing version change requires new review.

### Offline and local drafts

- SQLite via `sqflite`.
- Connectivity required to start and lock a workout.
- Server-started sessions may continue offline.
- Transactional autosave and idempotent outbox.
- Offline finish remains pending until backend validation.
- 24-hour post-week sync grace for valid started sessions.
- Logout blocked until unsynchronized data is synced or explicitly discarded.

### Release and hosting

- Android API 24+ initial mobile target.
- Android-only scaffold and private signed APK first release.
- iOS deferred.
- Vercel static Flutter Web dashboard.
- GitHub Actions builds and tests exact artifacts; previews use staging; production promotes a verified artifact.

### Supabase operations

- local, hosted staging, and separate production environments.
- production Supabase Pro daily backups with seven-day retention.
- no PITR initially.
- encrypted weekly logical dumps stored in private Google Drive and operator-controlled local/removable storage.
- retain 12 weekly and 12 month-end backups.
- RPO 24 hours; RTO 4 hours.
- restore before release and quarterly.
- two distinct Owner accounts, MFA enforcement, backup factors, and least privilege.

## New decisions and specifications

- `docs/product/ROUTINE_ELIGIBILITY.md`
- `ADR-0003-local-workout-drafts-and-online-finalization.md`
- `ADR-0004-android-first-and-vercel-dashboard-hosting.md`
- `ADR-0005-supabase-production-operations-and-recovery.md`

## Approved implementation packet

```text
docs/tasks/TASK-IMP-001.md
branch: codex/task-imp-001-foundation
```

The packet creates Flutter and local Supabase scaffolding, shared packages, configuration examples, tests, builds, and CI only. It explicitly excludes product features, remote projects, credentials, and deployment.

## Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

## Verification performed

- all seven previous Phase 0 blockers received accepted rules;
- anti-triviality and self-approval scenarios are required fixtures;
- offline state transitions preserve server authority;
- Android and Vercel choices align with the current development and static-client constraints;
- production backup policy includes platform and independent copies;
- operator access avoids shared accounts and requires MFA;
- task packet contains objective, reads, scope, non-goals, tests, acceptance, documentation, Git, and report requirements;
- no code, package, schema, external project, account, credential, deployment, or runtime was created.

## Known risks

- Human routine review remains subjective and requires discipline.
- Online start means a user without connectivity cannot begin a new workout.
- A pending offline completion can delay weekly finalization for up to 24 hours.
- Android-first defers iPhone access.
- Weekly logical backup and quarterly restore drills require operator action until automated.
- Supabase and Vercel costs and product behavior must be rechecked before actual purchase or deployment.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`
- Task: documentation and decision changes only.

## Exact next action

Execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
```

## Do-not-touch boundaries for the next task

- no remote Supabase or Vercel project;
- no real credentials, signing keys, or personal data;
- no authentication, product schema, routine, workout, SQLite feature, rank, wallet, or deployment implementation;
- no direct work on `main`;
- no silent change to accepted product configurations or ADRs.

## Verdict

`COMPLETE`

All implementation-blocking Phase 0 decisions are accepted, the first bounded task packet is approved, and no implementation was falsely performed.
