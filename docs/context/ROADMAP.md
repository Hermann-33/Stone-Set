# Stone Set Roadmap

Updated: 2026-08-10

Stone Set is a two-user MVP. The roadmap optimizes for functional completion and short implementation cycles rather than production-grade hardening.

## Completed

```text
Phase 0   Product/architecture planning                     COMPLETE
Phase 1   TASK-IMP-001 Foundation                           COMPLETE
Phase 2A  TASK-IMP-002A Identity/sessions                   COMPLETE
Phase 2B  TASK-IMP-002B Shared UI + Android shell/Home      COMPLETE
Phase 2C  TASK-IMP-002C Dashboard shell/Overview            COMPLETE
Phase 3A  TASK-IMP-003A Exercise library/guidance           COMPLETE
Phase 3B  TASK-IMP-003B Private media/YouTube               COMPLETE
Phase 3C  TASK-IMP-003C Routine/review/publication          COMPLETE
Phase 4   TASK-IMP-004 Weekly plans/free/paid swaps         COMPLETE
Phase 5A  TASK-IMP-005A Workout logger/SQLite/sync          COMPLETE
Phase 5B  TASK-IMP-005B Workout guidance/media playback     COMPLETE
Phase 6   TASK-IMP-006 RR/XP/rank/wallet/Progress           COMPLETE
Phase 7   TASK-IMP-007 progression/protection/corrections   COMPLETE
```

Latest completion evidence:

```text
TASK-IMP-005B
PR #24
implementation head: 21f780a71ef275be05c9ac1f007e78d41750ef81
Foundation CI: 31386145611 PASS
completion: docs/tasks/TASK-IMP-005B-COMPLETION.md
```

005B provides exact pinned workout guidance, signed private revision images, validated Android YouTube playback and same-route state preservation without adding a new backend/media schema.

## Current / only remaining required phase

### Phase 8 — TASK-IMP-008

Only deployment/release work actually required for the two users to run Stone Set:

- hosted Supabase backend using the existing migration set;
- hosted Vercel dashboard using the existing Flutter Web app;
- installable/signed Android release path;
- required environment/config values;
- minimal smoke test and rollback notes;
- basic backup/export procedure where directly useful.

Phase 8 will be aggressively simplified. Do not reintroduce staging/production duplication, enterprise observability, ASVS/MASVS programs, RPO/RTO drills, complex release automation or broad hardening unless a concrete release blocker requires it.

## Execution policy

- prepare/simplify task packets outside Codex;
- do safe implementation/deployment preparation outside Codex where possible;
- Codex is fallback rather than default;
- targeted tests during implementation;
- use existing Foundation CI instead of creating broad new matrices;
- preserve existing Auth/RLS/data-ownership boundaries;
- optimize for two known users and a minimal usable release.

## Exact next action

Merge PR #24, then prepare and execute `TASK-IMP-008` from latest `main`.
