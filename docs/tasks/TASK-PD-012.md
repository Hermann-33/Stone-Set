# TASK-PD-012 — Research and define the complete app and dashboard UI system

Status: `COMPLETE`
Approved by: user request on 2026-08-05
Type: external research, product planning, and implementation sequencing only

## Objective

Research current workout applications, coaching dashboards, productivity dashboards, adaptive Flutter/Material guidance, accessibility standards, and relevant Reddit feedback; then define Stone Set's complete Android app and Flutter Web dashboard UI/UX system, accept only high-value features compatible with the product, and map the full UI into implementation milestones without starting product code.

## Mandatory repository reads

1. `AGENTS.md`
2. `docs/context/ACTIVE_CONTEXT.md`
3. `docs/context/PROJECT_BRIEF.md`
4. `docs/context/ARCHITECTURE.md`
5. `docs/context/CODEBASE_MAP.md`
6. `docs/context/ROADMAP.md`
7. `docs/context/IMPLEMENTATION_PLAN.md`
8. `docs/context/UI_IMPLEMENTATION_PLAN.md`, when created
9. `docs/context/WORKFLOW.md`
10. `docs/context/HANDOFF.md`
11. `docs/product/APPLICATION_WORKFLOW.md`
12. `docs/product/AUTHENTICATION_AND_SESSION_UX.md`
13. `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`
14. `docs/product/RANK_SYSTEM.md`
15. `docs/product/WEEKLY_SCHEDULING.md`
16. `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`
17. `assets/ranks/manifest.json`
18. planned implementation packets.

## Verified starting state

- `TASK-ASSET-001` is merged into `main`.
- `TASK-PD-011` already defines the Home rank hero, full-circle progress ring, today's workout card, and initial mobile shell.
- Phase 0 remains complete.
- Phase 1 remains ready and not started.
- No Flutter application, dashboard runtime, design system, feature UI, Supabase runtime, or external infrastructure exists.
- The repository lacks a complete screen inventory, dashboard information architecture, shared UI principles, cross-surface state standard, or full UI implementation workstream.

## External research scope

Reviewed current official or first-party material covering:

- Flutter adaptive/responsive layouts, available-width branching, state preservation, keyboard and input support;
- Material canonical feed, list-detail, supporting-pane, and state patterns;
- W3C WCAG 2.2, form labels, error identification, error summaries, status messages, keyboard access, focus, and non-color communication;
- Hevy workout logging, previous values, automatic rest timer, exercise notes, PR feedback, charts, and coaching dashboard patterns;
- Fitbod contextual recommendations, previous performance, muscle/recovery presentation, preferences, and explanation needs;
- Strava calendar/training-log and filtering patterns;
- Figma autosave, offline safeguards, named checkpoints, version comparison, restore, and keyboard patterns;
- Linear search, filters, URL-addressable views, list/board/display options, command menu, draft preservation, and keyboard patterns;
- Hevy Coach and TrueCoach attention-first dashboards, activity summaries, program builders, and progress detail;
- current Reddit feedback about hidden historical data, incorrect/recommended weights without visible context, weekly planning, calendar history, reliable drafts, direct performance visibility, and exportability.

## Material findings

1. Workout logging fails when users must repeatedly leave the logger to inspect history or recommendations.
2. Previous comparable performance belongs directly beside the current target/set.
3. Marking a set complete should trigger autosave and the rest timer with minimal interaction.
4. Draft recovery is a trust feature, not optional polish.
5. The dashboard Home should prioritize unresolved work and resumable drafts rather than generic charts.
6. Long-form routine and guidance creation benefits from autosave, explicit save state, version history, diff, and mobile preview.
7. Adaptive layouts should branch by available width and use list-detail/supporting-pane structures on larger screens.
8. Search, command palette, filters, and keyboard shortcuts materially improve desktop workflows when they remain discoverable and accessible.
9. Validation must provide both an error summary and field-level repair instructions.
10. History is more useful when users can switch between calendar, list, and exercise-specific trend views.
11. Rank, penalties, progression, and recommendations need `Why?` explanations to preserve trust.
12. Social, nutrition, AI coaching, wearable, CRM, and camera-form-analysis features would broaden scope without improving the core private two-user workflow enough for MVP.

## Accepted decisions

### Mobile

- Primary destinations become Home, Week, Progress, and Profile.
- Progress supersedes the narrower History label and contains history, charts, rank, wallet, milestones, corrections, and exercise progress.
- Previous comparable and best comparable performance are available in the active logger.
- Automatic rest timer starts from set completion.
- Fast entry, next-incomplete-set navigation, persistent session header, and explicit save/sync states are required.
- History supports calendar and list views.
- First-run setup checklist is accepted.
- Data export is planned for release hardening.

### Dashboard

- Primary destinations are Overview, Routines, Exercises, Reviews, Activity, and Settings.
- Overview is attention-first and includes resumable drafts.
- Responsive shell uses drawer, rail, and persistent sidebar based on available width.
- Global search, command palette, shortcut help, autosave state, undo, structured error summary, mobile preview, version history, and version diff are accepted.
- Exercise/guidance uses adaptive list-detail.
- Routine editing uses three panes when expanded and a single-pane adaptive flow when compact.
- Review is an immutable diff-and-evidence workflow.

### Shared

- System, Dark, and Light themes are designed through semantic tokens.
- WCAG 2.2 AA-equivalent dashboard behavior and platform-equivalent mobile accessibility are release gates.
- Loading, empty, stale, offline, pending, provisional, conflict, permission, error, and recovery states are standardized.
- No continuous idle animation.
- No third-party analytics, social feed, public profile, AI coaching, nutrition, sleep, wearable, CRM, or camera-form-analysis scope is added.

## New files

- `docs/product/COMPLETE_UI_UX_SYSTEM.md`
- `docs/context/UI_IMPLEMENTATION_PLAN.md`
- `docs/tasks/TASK-PD-012.md`
- `docs/tasks/TASK-IMP-002C.md`

## Existing packet impact

- `TASK-IMP-002B` remains planned and unauthorized.
- Before approval, amend its mobile destination label from `History` to `Progress`.
- `TASK-IMP-002C` is added for the dashboard shell and fixture-driven Overview.
- Existing `TASK-IMP-003A/B/C`, `004`, `005A/B`, `006`, `007`, and `008` own the remaining feature UI alongside their corresponding domain/backend work.

## Protected boundaries

- Preserve `rank-v6`, `schedule-v3`, and all reward rules.
- Preserve server-authoritative rank, schedule, workout start, finalization, reviews, publication, and corrections.
- Preserve user ownership and RLS.
- Preserve the approved authentication/session model.
- Preserve `TASK-IMP-001` as the exact next implementation action.
- Do not claim Phase 1 or any UI milestone has started.
- Do not implement Flutter, Supabase, schemas, accounts, deployment, or external infrastructure.
- Do not add proprietary screenshots/assets or copy another product's exact UI.

## Verification

- complete mobile and dashboard information architecture is defined;
- every accepted product workflow has a corresponding screen/interaction owner;
- the workout logger minimizes context switches and preserves previous performance visibility;
- the dashboard provides adaptive navigation, attention, search, command, autosave, validation, diff, and version patterns;
- responsive, keyboard, screen-reader, text-scaling, reduced-motion, error, recovery, and performance requirements are testable;
- high-value additions are separated from rejected scope expansion;
- the implementation workstream maps all UI delivery to existing or newly planned bounded packets;
- no application code or infrastructure is introduced.

## Verdict

`COMPLETE`

Stone Set now has a complete accepted UI/UX system and implementation workstream for the Android application and Flutter Web dashboard. The exact next implementation action remains `TASK-IMP-001`.