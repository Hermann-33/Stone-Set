# TASK-IMP-005B — Implementation Handoff

Status: `IMPLEMENTED — MAIN VALIDATING`

PR: #24

Branch: `codex/task-imp-005b-workout-guidance-media`

Base: `main` after TASK-IMP-007 merge `99c570c7b287101651e6024895d6cc2eaed552eb`

## Implemented

- Reuses the active workout session's pinned exercise and guidance revision IDs.
- Loads the exact immutable guidance revision and matching published media manifest through existing repositories.
- Creates short-lived signed URLs for private revision images only when guidance is opened.
- Adds a Guidance action to each workout exercise card.
- Opens guidance in a same-route modal sheet so workout draft, timer and scroll state remain owned by the existing logger state object.
- Renders structured text sections, private images with alt semantics, explicit empty/error/retry states, and refresh for fresh signed URLs.
- Adds validated YouTube playback through `webview_flutter 4.14.1` on Android API 24+, with autoplay disabled and no video download/reward coupling.
- Pins the new dependency in the root lockfile.
- Adds focused loader, guidance-sheet and logger-state preservation tests.

## Intentionally unchanged

- no database migration;
- no new RPC or Storage policy;
- no SQLite media schema;
- no background prefetch/cache cleanup;
- no top-level guidance route;
- no dashboard changes;
- no TASK-IMP-008 work.

## Validation

- dependency lockfile is committed;
- canonical lock-aware formatting has been applied to all 005B Dart files;
- PR #24 targets merged `main`;
- first integration CI `31385204259` exposed and cleared strict analyzer defects;
- second integration CI `31385705830` passed generated sources, formatting and strict analysis; 58 mobile tests passed and one new state-preservation test failed only because it used `tester.pageBack()` for a modal bottom sheet;
- loader and guidance-sheet tests passed on that run;
- modal state test now closes the bottom-sheet route directly with `Navigator.pop`, leaving production code unchanged;
- the test-only fix was canonical-formatted on head `89ad5124b26c9adc2fae7781a12a3880b44f337e`;
- fresh Foundation CI on this corrected head is the remaining diagnostic/acceptance gate.

Any remaining work must be a narrow fix for an actual test/Android release/API24 defect exposed by CI.
