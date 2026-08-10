# Stone Set Latest Handoff

Updated: 2026-08-10

## Current state

```text
TASK-IMP-003A — COMPLETE AND MERGED (PR #14)
TASK-IMP-003B — COMPLETE AND MERGED (PR #16)
TASK-IMP-003C — COMPLETE AND MERGED (PR #18)
TASK-IMP-004  — COMPLETE AND MERGED (PR #20)
TASK-IMP-005A — COMPLETE AND MERGED (PR #21)
TASK-IMP-006  — COMPLETE AND MERGED (PR #22)
TASK-IMP-007  — COMPLETE AND MERGED (PR #23)
TASK-IMP-005B — COMPLETE — CI VERIFIED (PR #24; merge pending completion-doc head)
TASK-IMP-008  — NEXT / ONLY REMAINING REQUIRED PHASE
```

Latest evidence:

```text
TASK-IMP-005B
implementation head: 21f780a71ef275be05c9ac1f007e78d41750ef81
Foundation CI: 31386145611 PASS
completion: docs/tasks/TASK-IMP-005B-COMPLETION.md
```

## What 005B completed

- exact pinned workout guidance from immutable session exercise/guidance IDs;
- same-route modal guidance so workout logger state is not replaced;
- structured guidance sections;
- private revision images through short-lived signed URLs with refresh/retry;
- validated YouTube playback on Android via `webview_flutter 4.14.1`;
- no autoplay/download/reward coupling;
- logger-state preservation coverage;
- no new database/media schema.

## Next task — TASK-IMP-008

Prepare a new fast packet from latest `main` after PR #24 merges.

The two-user release target should include only:

- one hosted Supabase project using the existing schema/migrations;
- one Vercel deployment for the dashboard;
- Android installable/signed release path;
- required configuration/secrets wiring;
- one basic two-user smoke path;
- concise backup/rollback/operator notes.

Do not inflate Phase 8 with separate staging/prod projects, enterprise observability, formal certification, broad hardening matrices, RPO/RTO drills, rate limiting or public-user abuse architecture unless a concrete release blocker requires it.

## Working rule

Assistant should continue owning packet creation, connected GitHub/Supabase/Vercel work, CI diagnostics, release documentation and PR handling wherever possible. Codex is fallback only for a concrete local-only Android signing/build/runtime task that cannot reasonably be handled through connected tools.
