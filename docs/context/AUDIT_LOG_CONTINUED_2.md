# Stone Set Audit Log — Continued, Volume 2

This volume continues material audit history after `docs/context/AUDIT_LOG_CONTINUED.md` and preserves all earlier audit files unchanged.

## 2026-08-05 — TASK-PD-011 — Mobile Home and radial rank-progress UI audit

### Scope

- define the base Android mobile Home hierarchy;
- make the current rank emblem the centered visual focus;
- define a circular progress bar around the emblem;
- define the Home entry point for today's scheduled workout logging flow;
- use the supplied Fortnite screenshot only as interaction and animation inspiration;
- define motion, state, accessibility, responsive, and data-authority behavior;
- place the UI into the implementation roadmap without starting Flutter code.

### Starting state

- `TASK-ASSET-001` was merged into `main`.
- Twenty `stone-set-ranks-v1` PNGs existed and were not integrated into an application.
- The accepted workflow required authenticated Home, week, rank, wallet, history, today's item, and pending state.
- No accepted mobile design system, app-shell structure, rank-ring geometry, animation contract, or base-UI implementation packet existed.
- Phase 1 remained ready and not started.

### Accepted product decisions

1. Home is the daily command surface.
2. The current rank emblem is centered in the first viewport.
3. A complete `360°` inactive circular track surrounds the emblem and remains visible at every progress value, including `0%`.
4. The active progress arc begins at 12 o'clock, advances clockwise, and equals `360° × progressFraction`.
5. At `100%`, the active ring is a seamless complete circle with no gap, doubled cap, overlap bump, or missing segment.
6. The earlier near-complete ring with a small top gap is superseded.
7. Exact RR and percentage remain visible in text and semantics.
8. Adonis displays a full ring and max-rank state.
9. The solid active ring represents finalized authoritative RR only.
10. Provisional RR uses a distinct secondary treatment and cannot change the authoritative emblem.
11. Pending local synchronization does not move the authoritative active arc.
12. The mobile shell uses Home, Week, History, and Profile destinations.
13. Home shows today's workout/rest card, a seven-day strip, lifetime XP, multiplier, free-swap balance, and conditional status banners.
14. The today's card explicitly exposes `Start workout`, `Continue workout`, `Sync workout`, and `View result` according to state.
15. `Start workout` becomes the entry point for logging the day's sets, load, repetitions, RIR, rest, and completion when workout execution is implemented.
16. A programmed rest day does not expose a rewarded unscheduled workout or manual completion action.
17. Motion is event-driven and covers entrance, increase, decrease, rank up, rank down, return from background, and reduced motion.
18. No continuous idle animation is allowed.
19. The supplied Fortnite screenshot is not committed and no proprietary artwork, exact styling, sound, particles, or choreography is copied.

### Implementation sequencing decisions

- `TASK-IMP-001` remains unchanged and foundation-only.
- Planned identity work becomes `TASK-IMP-002A`.
- `TASK-IMP-002B` owns the mobile design system, authenticated shell, fixture-driven Home, full-circle rank hero, rank asset resolver, today's-card action states, motion, and visual/accessibility tests.
- `TASK-IMP-002B` is blocked until foundation and authentication are complete and merged.
- `TASK-IMP-004` binds materialized today's item and week data into the existing Home widgets.
- `TASK-IMP-005A` makes `Start workout`, `Continue workout`, and `Sync workout` functional and binds workout, draft, set logging, timer, and synchronization state.
- `TASK-IMP-006` binds authoritative rank snapshots, provisional transactions, and rank transitions.

### Component and authority findings

- The rank hero and today's card can be built before backend integration through immutable fixture-backed view data.
- The UI component must not call Supabase directly or gain reward, workout-start, submission, or finalization authority.
- A stable rank-identity-to-asset mapping is safer than constructing filenames from display text.
- Full inactive, authoritative active, provisional, and pending visual layers prevent the client from overstating unfinalized progress.
- A dedicated exact-100% rendering path is required to avoid a seam or cap artifact in a full circular progress bar.
- Event-driven first-party drawing and animation are sufficient; no third-party animation runtime is assumed.
- Reduced motion and complete semantic labels are requirements, not later polish.

### New files

- `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`
- `docs/tasks/TASK-PD-011.md`
- `docs/tasks/TASK-IMP-002B.md`
- `docs/context/AUDIT_LOG_CONTINUED_2.md`

### Synchronized files

- `docs/context/ACTIVE_CONTEXT.md`
- `docs/context/CODEBASE_MAP.md`
- `docs/context/ROADMAP.md`
- `docs/context/IMPLEMENTATION_PLAN.md`
- `docs/context/HANDOFF.md`

### Verification

- the accepted progress formula is compatible with all `rank-v6` intervals;
- 0%, intermediate, exact 100%, threshold, and Adonis max-rank behavior are explicit;
- authoritative, provisional, pending, stale, offline, loading, error, increase, decrease, rank-up, rank-down, and reduced-motion states are defined;
- all 20 asset identities have a planned stable resolver;
- the Home hierarchy keeps today's workout action available below the dominant rank hero;
- available, active, pending, completed, rest, locked, and error today's-card states are included in the future packet;
- accessibility, 200% text scaling, semantics, reduced motion, and performance checks are included;
- later schedule, workout, and rank phases bind real data without duplicating or redesigning the base Home shell;
- no Flutter code, Supabase state, external infrastructure, proprietary screenshot, credential, personal data, or rank-rule change was introduced.

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Verdict

`COMPLETE`

Stone Set now has an accepted, implementation-ready mobile Home baseline with a full circular rank progress bar and an explicit Home entry point for today's workout logging flow. The exact next implementation action remains `TASK-IMP-001`.

---

## 2026-08-05 — TASK-PD-012 — Complete app and dashboard UI/UX research audit

### Scope

- research current workout trackers, fitness/coaching dashboards, adaptive design systems, accessibility guidance, productivity applications, and Reddit feedback;
- define the complete Android app and Flutter Web dashboard information architecture;
- identify high-value features that reduce friction, improve trust, or improve authoring/review;
- reject unrelated scope expansion;
- define complete responsive, state, accessibility, recovery, and performance standards;
- map every UI surface into bounded implementation milestones without starting code.

### Research sources reviewed

- Flutter adaptive/responsive and state-preservation guidance;
- Material canonical feed, list-detail, supporting-pane, and interaction-state patterns;
- W3C WCAG 2.2, forms, errors, focus, status messages, and keyboard guidance;
- Hevy workout logging and previous-value/rest-timer patterns;
- Hevy Coach and TrueCoach dashboard, activity, workout builder, and progress patterns;
- Fitbod previous performance, preferences, recovery context, and recommendation behavior;
- Strava Training Log calendar/filter behavior;
- Figma autosave, offline safeguards, named checkpoints, version history, compare, restore, and keyboard behavior;
- Linear search, filters, command menu, custom views, draft preservation, and keyboard behavior;
- Reddit feedback emphasizing visible history and recommendations inside workouts, weekly planning, calendar history, durable drafts, data transparency, and exportability.

### Material findings

1. Workout logging should not require leaving the logger to inspect previous performance.
2. Previous comparable and best comparable values belong beside current targets.
3. Set completion should trigger autosave and the rest timer with minimal interaction.
4. Draft recovery is a core trust requirement on both mobile and dashboard.
5. Dashboard Home should prioritize unresolved work and resumable drafts, not decorative analytics.
6. Routine/guidance editing needs explicit save state, validation summaries, version history, diff, and mobile preview.
7. Responsive dashboard domains map well to list-detail and supporting-pane layouts.
8. Search, command palette, and keyboard shortcuts improve desktop efficiency only when discoverable and accessible.
9. Errors must be textual, repair-oriented, field-linked, and preserved with entered data.
10. History is more useful with calendar, list, and exercise-specific views.
11. Rank, recommendation, lock, penalty, and validation decisions require understandable explanations.
12. Social, nutrition, sleep, wearable, AI coach, camera form analysis, CRM, and public marketplace features are not justified for the private MVP.

### Accepted mobile decisions

- Primary destinations become Home, Week, Progress, and Profile.
- `Progress` supersedes the old `History` label and contains history, charts, rank, wallet, milestones, and corrections.
- Active logger includes previous/best comparable values, progression explanation, fast numeric entry, one-tap completion, automatic rest timer, next-incomplete-set navigation, autosave, and draft recovery.
- History supports calendar and chronological list views plus filters/search.
- Exercise charts expose exact values and comparable-context explanations.
- Profile includes appearance, accessibility, alerts, cache, sessions, diagnostics, and data export.
- A first-run setup checklist is accepted.

### Accepted dashboard decisions

- Primary destinations: Overview, Routines, Exercises, Reviews, Activity, Settings.
- Navigation adapts through drawer, rail, and persistent sidebar.
- Overview is attention-first and includes resumable drafts.
- Global search, command palette, searchable shortcut help, save/offline/conflict indicators, undo, and first-run checklist are accepted.
- Exercise/guidance uses adaptive list-detail and structured sections.
- Routine authoring uses three panes when expanded and adaptive single-pane flow when compact.
- Validation summary links to exact fields.
- Review uses immutable diff, validator evidence, content hash, and explicit approval/rejection.
- Version restore creates a new draft rather than rewriting history.
- Media UI includes progress, retry, cover, reorder, alt text, YouTube preview, and mobile preview.
- User-owned CSV/JSON export is planned for release hardening.

### Shared decisions

- System, Dark, and Light themes use semantic tokens.
- Standard loading, empty, stale, offline, pending, provisional, conflict, permission, error, and recovery states are required.
- Dashboard targets WCAG 2.2 AA-equivalent behavior.
- Mobile targets platform-equivalent accessibility and TalkBack support.
- 200% text scaling, keyboard access, visible focus, reduced motion, and non-color communication are release gates.
- No continuous idle animation.
- Clients do not call Supabase directly from widgets or gain product authority.

### New files

- `docs/product/COMPLETE_UI_UX_SYSTEM.md`
- `docs/context/UI_IMPLEMENTATION_PLAN.md`
- `docs/tasks/TASK-PD-012.md`
- `docs/tasks/TASK-IMP-002C.md`

### Synchronized files

- `docs/context/ACTIVE_CONTEXT.md`
- `docs/context/CODEBASE_MAP.md`
- `docs/context/ROADMAP.md`
- `docs/context/IMPLEMENTATION_PLAN.md`
- `docs/context/HANDOFF.md`
- `docs/context/AUDIT_LOG_CONTINUED_2.md`

### Implementation sequencing

- `TASK-IMP-001` remains the exact next implementation action.
- `TASK-IMP-002A` owns identity and sessions.
- `TASK-IMP-002B` owns shared UI tokens and the mobile foundation; its old `History` label must become `Progress` before approval.
- `TASK-IMP-002C` owns the responsive dashboard shell and fixture Overview.
- `TASK-IMP-003A/B/C` own real dashboard authoring and review UI with their corresponding domain/backend behavior.
- `TASK-IMP-004` owns Week, schedule, locks, and swaps.
- `TASK-IMP-005A/B` own the logger, drafts, timers, guidance, and media.
- `TASK-IMP-006` owns Progress, history, rank, wallet, and finalization.
- `TASK-IMP-007` owns progression, substitutions, protection, and corrections.
- `TASK-IMP-008` owns release accessibility, performance, recovery, export, and operations hardening.

### Verification

- all accepted product workflows have a screen and implementation owner;
- mobile and dashboard navigation remain bounded and coherent;
- logger interaction reduces context switching and preserves previous-performance evidence;
- dashboard authoring/review supports save state, validation, diff, versions, preview, keyboard, and adaptive panes;
- authoritative, provisional, pending, stale, offline, conflict, and error distinctions remain explicit;
- accessibility, responsive, recovery, performance, and export checks are testable;
- high-value additions are separated from rejected product expansion;
- no Flutter code, Supabase state, schema, account, deployment, credential, external infrastructure, or proprietary UI asset was introduced.

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
UI-0 — COMPLETE
```

### Verdict

`COMPLETE`

Stone Set now has a complete accepted Android and dashboard UI/UX system with a phased implementation workstream. The exact next action remains `TASK-IMP-001`.
