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
TASK-IMP-007  — COMPLETE — CI VERIFIED (PR #23; merge pending final docs head)
TASK-IMP-005B — IMPLEMENTING (PR #24; required before 008)
```

Latest implementation evidence:

```text
TASK-IMP-007
implementation head: 5342b260353169533fac265e95fddd158cc21f51
Foundation CI: 31383285750 PASS
completion: docs/tasks/TASK-IMP-007-COMPLETION.md
```

## Current implementation mode

Stone Set is a two-user application. Optimize for functionality and speed. Keep existing Auth/RLS/data ownership. Avoid enterprise hardening and broad extra matrices unless a real defect requires them.

## TASK-IMP-005B handoff

```text
task: TASK-IMP-005B
branch: codex/task-imp-005b-workout-guidance-media
PR: #24
packet: docs/tasks/TASK-IMP-005B.md
mode: FAST TWO-USER MVP
```

005B is intentionally backend-free unless CI proves an existing read capability is missing.

Reuse:

- active `WorkoutExercise.exerciseDefinitionId`;
- active pinned `WorkoutExercise.guidanceRevisionId`;
- `ExerciseGuidanceReadRepository.getGuidanceRevision`;
- `ExerciseMediaReadRepository.getRevisionManifest`;
- `ExerciseMediaReadRepository.createImageAccessUrl`.

Implemented/expected in #24:

- same-route Guidance modal from every workout exercise card;
- pinned structured guidance text;
- private revision images through short-lived signed URLs;
- validated YouTube playback with `webview_flutter 4.14.1` on Android API 24+;
- no autoplay/download/reward coupling;
- logger state preserved while guidance opens/closes;
- focused loader/widget/state-preservation tests.

Deliberately excluded:

- new database/media schema;
- offline video;
- background media jobs;
- custom disk cache;
- top-level guidance route;
- dashboard changes;
- release/deployment work (008).

## Working rule

Finish and merge PR #23 first. Retarget existing PR #24 to `main`; do not create another 005B branch or PR. Use Foundation CI to identify concrete Dart/WebView/API24 failures and patch those directly. Codex is fallback only for a genuine local-only runtime defect.

After #24 merges, TASK-IMP-008 is the only remaining required phase.
