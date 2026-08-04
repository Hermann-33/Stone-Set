# Stone Set Complete App and Dashboard UI/UX System

Updated: 2026-08-05
Status: `ACCEPTED PRODUCT UI/UX BASELINE`
Task: `TASK-PD-012`

## 1. Purpose

This document defines the complete user-interface and interaction baseline for:

- the Android Stone Set application;
- the responsive Flutter Web management dashboard;
- shared design-system components;
- cross-surface loading, error, synchronization, accessibility, motion, and data-authority behavior.

It extends `MOBILE_HOME_AND_RANK_PROGRESS_UI.md`. That document remains authoritative for the detailed Home rank hero and full-circle RR progress ring. This document owns the rest of the application and dashboard interface.

The objective is not to imitate one existing product. Stone Set combines proven patterns from workout trackers, coaching dashboards, high-productivity web applications, adaptive Material layouts, and accessibility guidance into one coherent system tailored to a private two-user hypertrophy workflow.

## 2. Research basis

The decisions were informed by current official product documentation and community feedback from:

- Flutter adaptive and responsive design guidance;
- Material 3 adaptive canonical layouts and interaction states;
- W3C WCAG 2.2 form, error, focus, status-message, and keyboard guidance;
- Hevy workout logging and Hevy Coach dashboard/workout-builder behavior;
- Fitbod workout-history, exercise-preference, recovery, and recommendation transparency patterns;
- Strava Training Log calendar/filter patterns;
- Figma autosave and version-history patterns;
- Linear search, filters, custom views, keyboard shortcuts, contextual panels, and temporary draft behavior;
- TrueCoach and other coaching-dashboard attention and activity patterns;
- Reddit feedback emphasizing visible historical performance, fewer context switches, reliable drafts, weekly planning, calendar history, data transparency, and exportability.

Research is advisory. Stone Set preserves its own accepted product rules, server authority, private-user model, scheduling, and rank economy.

## 3. Product-interface principles

### 3.1 Next valid action first

Every primary screen must make the user's next valid action obvious.

Examples:

- Home: start or continue today's workout;
- active workout: complete the current set or move to the next exercise;
- dashboard overview: resume a draft or resolve a blocking validation/review item;
- review screen: approve, reject, or return to the exact changed field.

### 3.2 Never lose entered work

Any meaningful draft must have visible persistence state.

- Mobile workout edits save transactionally to SQLite.
- Dashboard editors autosave validated draft changes.
- Closing, refreshing, resizing, navigating, or temporary network loss must not silently discard work.
- Destructive actions require confirmation or a reversible undo where possible.
- The UI distinguishes `Saving`, `Saved`, `Offline`, `Syncing`, `Conflict`, and `Failed to save`.

### 3.3 Show context where decisions occur

Users should not leave the current task merely to retrieve information required for that task.

During a workout, each exercise exposes:

- previous comparable performance;
- prescribed target;
- best comparable result when useful;
- progression recommendation and explanation;
- exercise instructions and safety notes;
- active rest timer.

During routine editing, the dashboard exposes:

- validation status;
- weekly volume context;
- estimated session duration;
- affected muscles;
- mobile preview;
- version and publication state.

### 3.4 Explain why

Any recommendation, penalty, rank change, validation failure, lock, or blocked action must have an understandable explanation.

The interface must support `Why?`, `How calculated`, or an equivalent details action for:

- progression recommendations;
- routine-validator failures;
- rank changes and decay;
- missed-workout penalties;
- provisional versus finalized RR;
- schedule locks;
- review requirements;
- substitutions and protection states.

### 3.5 Preserve authority boundaries

The UI never implies that client state is authoritative when it is not.

Distinct treatments are required for:

- authoritative server state;
- provisional server transactions;
- locally pending data;
- stale cached state;
- optimistic non-authoritative edits;
- historical snapshots.

### 3.6 Progressive disclosure

Show the minimum information required for the immediate decision, with clear access to deeper detail.

Examples:

- the set row shows previous and target values; charts live in exercise detail;
- Home shows three key metrics; full ledgers live in Progress;
- the dashboard overview shows only unresolved attention items and resumable drafts;
- advanced routine-validator evidence opens in a supporting pane.

### 3.7 Adaptive by available space and input

Layouts branch by actual available width, not device labels.

- compact widths use one-column navigation and full-screen detail;
- medium widths use navigation rail and optional supporting pane;
- expanded widths use persistent sidebar and list-detail or three-pane editing;
- mouse, touch, keyboard, screen reader, and text scaling are all first-class inputs.

### 3.8 Accessibility is a release gate

WCAG 2.2 AA-equivalent behavior is the minimum dashboard target. Mobile follows platform accessibility semantics and equivalent contrast, touch-target, focus, text-scaling, reduced-motion, and non-color communication requirements.

### 3.9 Brand restraint

Stone Set is dark, focused, and game-influenced, but it is not a game interface pasted onto a training tool.

- rank color is reserved for progression and meaningful emphasis;
- permanent glow, particles, exaggerated gradients, and decorative motion are avoided;
- data entry remains calm and high-contrast;
- visual density increases only where it improves comparison.

## 4. Shared information architecture

## 4.1 Mobile primary navigation

The authenticated Android application uses four destinations:

1. **Home** — current rank, today's action, weekly status, synchronization, and summary metrics;
2. **Week** — full seven-day schedule, locks, swaps, and item detail;
3. **Progress** — history calendar, exercise progress, rank/wallet ledger, milestones, and corrections;
4. **Profile** — account, preferences, units, theme, accessibility, cache, export, and logout.

`Progress` supersedes the narrower `History` destination label. Workout history remains a first-class section inside Progress.

Contextual routes are not permanent tabs:

- workout overview;
- active workout logger;
- exercise guidance;
- workout result;
- rank detail;
- exercise progress detail;
- swap preview;
- protection/correction detail;
- password change and session-resolution flows.

## 4.2 Dashboard primary navigation

The responsive Flutter Web dashboard uses:

1. **Overview** — attention items, resumable drafts, publication state, recent activity, and quick actions;
2. **Routines** — routine library, drafts, published versions, scheduling, and mobile preview;
3. **Exercises** — exercise definitions, guidance revisions, images, videos, usage, and history;
4. **Reviews** — submitted routine reviews, exact diffs, validator evidence, approval, and rejection;
5. **Activity** — publication, review, media, routine, guidance, and account-relevant audit events;
6. **Settings** — profile, units, timezone, appearance, accessibility, data export, and session controls.

Media management remains contextual to Exercises rather than becoming a separate top-level destination in MVP.

The dashboard does not include social feeds, chat, client-sales tools, lead management, or multi-coach administration.

## 5. Shared visual system

### 5.1 Theme modes

The component system supports:

- `System`;
- `Dark`;
- `Light`.

Dark is Stone Set's brand-default presentation. Theme choice is user-configurable and stored per account where appropriate. All semantic tokens must work in all three modes from the first implementation, even if dark receives the primary visual-polish effort.

### 5.2 Color roles

Use semantic roles, not screen-specific colors:

- canvas background;
- surface;
- raised surface;
- interactive surface;
- outline;
- strong text;
- muted text;
- disabled;
- success;
- warning;
- destructive;
- information;
- focus ring;
- authoritative;
- provisional;
- pending;
- stale;
- rank-family colors.

Rank colors never replace error, warning, or focus semantics.

### 5.3 Typography roles

- rank display;
- page title;
- section title;
- card title;
- body;
- compact body;
- data value;
- table value;
- label;
- caption;
- button;
- code/identifier.

Numeric workout fields use tabular figures where available.

### 5.4 Spacing and shape

- 4 dp base spacing grid;
- 8, 12, 16, 20, 24, 32, and 48 dp primary increments;
- comfortable mobile cards;
- denser desktop tables and editors;
- medium card radii;
- compact chips;
- consistent 1 dp and 2 dp borders;
- minimum 48 dp mobile touch targets;
- minimum 24 CSS-pixel dashboard pointer targets, with larger targets for primary controls.

### 5.5 Motion

Motion categories:

- micro feedback: 100–180 ms;
- standard transition: 180–300 ms;
- emphasized state transition: 300–500 ms;
- rank transition: owned by the dedicated rank-hero specification.

No continuous idle animation. Reduced-motion mode removes sweeps, parallax, scale travel, and nonessential morphing.

### 5.6 Icons

Use one consistent outlined/filled icon family available in Flutter/Material. Do not mix unrelated icon libraries. Every icon-only control requires a tooltip and semantic label.

### 5.7 Charts

Charts must:

- show exact values on focus/tap/hover;
- include text summaries;
- support keyboard navigation on web where practical;
- avoid relying on color alone;
- allow time-range selection;
- show units explicitly;
- distinguish missing, provisional, and corrected data;
- avoid misleading smoothed lines by default.

## 6. Mobile application specification

## 6.1 Home

Home follows `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` and includes:

- quiet header;
- current-rank emblem inside the always-visible 360-degree progress track;
- finalized RR progress;
- conditional provisional/pending banner;
- today's workout/rest card;
- seven-day strip;
- consistency multiplier, lifetime XP, and free-swap balance;
- compact insight card only when actionable.

The insight card may show one of:

- a new progression recommendation;
- a pending synchronization issue;
- an upcoming lock;
- a consistency milestone;
- a recently applied rank adjustment with explanation.

It must not become an infinite feed.

## 6.2 Week

### Core layout

- sticky week header with date range and reward timezone;
- previous/current/next week navigation where permitted;
- seven vertically ordered day cards on compact widths;
- selected-day supporting pane on larger widths;
- clear workout/rest, lock, swap, active, pending, completed, protected, and failed states;
- stored RR/XP allocation and possible penalty disclosed in item detail;
- current day visually emphasized without color-only dependence.

### Actions

- open today's workout;
- preview a future item;
- open a completed result;
- enter swap selection mode;
- inspect lock reason;
- inspect pinned routine/guidance version;
- view protection status.

### Swap interaction

- select exactly two eligible dates;
- show before/after schedule preview;
- show allowance and payment impact;
- require explicit payment selection;
- provide cancel without mutation;
- announce successful atomic swap;
- retain stable day identities and content in the preview.

## 6.3 Workout overview

Before starting, show:

- workout title and purpose;
- target muscles;
- estimated duration;
- exercise count and total prescribed sets;
- equipment summary;
- important workout note;
- exercise list with thumbnail/placeholder;
- sets, reps, RIR, rest, priority, and previous comparable result;
- validation/connectivity status;
- `Start workout` primary action.

The overview provides an optional `Review changes since last time` panel when the published routine or guidance revision changed.

## 6.4 Active workout logger

This is the highest-friction-risk surface and must minimize interaction cost.

### Persistent session header

Display:

- workout name;
- elapsed time;
- completed sets / total sets;
- current synchronization state;
- compact rest timer when active;
- finish action.

### Exercise card

Each exercise card includes:

- exercise name and media thumbnail;
- primary target muscle;
- prescribed set count, rep range, RIR, and rest;
- persistent exercise note/cue;
- previous comparable performance summary;
- best comparable performance where helpful;
- progression recommendation with `Why?`;
- `How to perform` action;
- ordered set rows.

### Set row

Each set row supports:

- set number and type;
- target values;
- previous comparable values;
- editable load;
- editable repetitions;
- editable RIR;
- completion toggle;
- invalid-value feedback;
- corrected/overridden indicator;
- optional note.

On completing a set:

- autosave immediately;
- start the prescribed rest timer;
- move focus logically to the next editable field or set;
- keep the completed row editable;
- show PR feedback only when server rules permit a provisional indication.

### Fast-entry behavior

- prefill from the prescription or accepted progression recommendation;
- optionally copy an edited load to following incomplete sets after explicit user action;
- numeric keyboard opens automatically on mobile;
- next/previous field actions follow load → reps → RIR → completion;
- one tap marks a valid entered set complete;
- long press is never required for core logging;
- accidental completion can be undone.

### Rest timer

- starts automatically on set completion;
- remains visible in the session header and notification/lock-screen surface where platform support is later accepted;
- supports +15 seconds, -15 seconds, pause, and skip;
- uses haptic/audio notification according to preferences;
- never blocks data entry.

### Exercise navigation

- collapsed completed exercises remain visible;
- the user can jump between exercises without losing edits;
- the app preserves scroll position, focused exercise, timers, and draft state when guidance opens;
- a compact `Next incomplete set` action is available.

### Finish flow

Before submission, show:

- incomplete or invalid sets;
- completion percentage;
- duration;
- notes;
- pending offline status;
- explicit finish/submit action.

Finishing offline creates `Pending submission`, not an authoritative reward result.

## 6.5 Exercise guidance

Guidance opens as:

- a full-screen route on compact widths;
- a sheet/supporting pane on sufficiently large widths when the active logger remains readable.

Sections:

- overview;
- primary and secondary muscles;
- setup;
- execution;
- cues;
- common mistakes;
- safety notes;
- ordered images;
- optional YouTube player;
- current prescription summary;
- close/back to exact workout position.

Use a table of contents for long guidance. Media failure never hides text instructions or blocks workout logging.

## 6.6 Workout result

States:

- pending synchronization;
- validating;
- provisional;
- finalized;
- partial;
- invalid;
- protected;
- correction pending.

Finalized result shows:

- completion classification;
- RR change;
- XP change;
- rewarded PRs;
- rank progress before/after;
- notable progression evidence;
- duration and set summary;
- reason/details links;
- `View in Progress` action.

The screen must not celebrate a provisional or local-only result as final.

## 6.7 Progress

Progress combines historical evidence and current progression.

### Default overview

- current rank and next threshold;
- RR trend and transaction summary;
- lifetime XP;
- consistency streak and multiplier;
- weekly completion trend;
- recent PRs;
- selected time range.

### History views

Provide:

- calendar view;
- chronological list view;
- filters for workout/rest, completion state, exercise, PR, rank transaction, correction, and protection;
- month and year navigation;
- selected-day detail;
- search by workout or exercise name.

### Exercise progress

For each exercise:

- previous comparable result;
- best comparable result;
- load and rep history;
- estimated strength trend only when defined by accepted product rules;
- completed set volume;
- PR timeline;
- comparable-context explanation;
- corrections clearly marked.

### Rank and wallet

- rank ladder with current position;
- full-circle progress hero in compact form;
- RR transaction ledger;
- penalties, decay, bonuses, milestones, and corrections;
- free-swap credit balance and ledger;
- calculation details;
- immutable configuration version shown in transaction detail.

## 6.8 Profile and settings

Sections:

- account and username;
- units and per-exercise overrides where accepted;
- reward timezone;
- appearance: system/dark/light;
- text size and reduced motion guidance;
- haptic and timer-alert preferences;
- cache and offline storage status;
- session/device information;
- change password;
- data export;
- logout with draft-resolution workflow;
- app version and diagnostics.

No user-editable field grants authorization.

## 6.9 First-run and empty states

After authentication, a concise setup checklist may show:

1. confirm units and timezone;
2. create exercise guidance in the dashboard;
3. create a routine;
4. submit and obtain review;
5. wait for activation/materialization;
6. start the first scheduled workout.

The checklist disappears when complete and remains accessible from Help. It is not a gamified reward source.

## 7. Dashboard specification

## 7.1 Adaptive shell

### Compact web width

- top app bar;
- modal navigation drawer;
- single-pane content;
- detail opens as a route or full-screen dialog.

### Medium width

- navigation rail;
- list-detail where useful;
- supporting pane may be dismissible.

### Expanded width

- persistent labeled sidebar;
- main content max-width and grid;
- list-detail or three-pane editor;
- contextual right supporting pane;
- keyboard-first operation.

Navigation selection, filters, draft state, scroll position, and open detail should survive safe window resizing.

## 7.2 Global dashboard shell features

### Global search

Search across:

- routines;
- routine versions;
- exercises;
- guidance revisions;
- reviews;
- activity events.

Results are grouped by type, keyboard navigable, and permission filtered.

### Command palette

`Ctrl/Cmd + K` opens contextual actions such as:

- create routine;
- create exercise;
- open recent draft;
- search;
- open review queue;
- publish guidance;
- submit routine;
- switch theme;
- view shortcuts.

Commands that mutate state still show required confirmation/validation.

### Keyboard shortcuts

Provide a searchable shortcut reference. Initial shortcuts:

- `/` focus search;
- `Ctrl/Cmd + K` command palette;
- `N` create context-appropriate item when not typing;
- `Ctrl/Cmd + S` save named checkpoint or force draft sync where meaningful;
- `Esc` close modal/pane or cancel transient mode;
- `?` open shortcut/help overlay;
- arrow keys and Enter navigate list-detail views.

Shortcuts must never override text-editing conventions.

### Save-state indicator

Persistent editor status:

- Saved;
- Saving;
- Offline — changes stored locally;
- Syncing;
- Conflict — review required;
- Failed — retry.

### Undo and destructive actions

- reorder, remove-from-draft, and reversible local deletion use undo where safe;
- published immutable content is never silently deleted;
- destructive confirmation states exactly what is affected;
- focus returns to a logical location after completion.

## 7.3 Overview

The dashboard Overview is attention-first, not a generic analytics wall.

Order:

1. `Needs attention`;
2. `Resume work`;
3. current published routine and upcoming activation;
4. recent activity;
5. compact system status;
6. quick actions.

### Needs attention

Examples:

- routine submitted for review;
- routine rejected with feedback;
- validation blockers;
- missing exercise guidance;
- broken/failed media processing;
- draft conflict;
- upcoming routine activation;
- account/session issue.

Each item provides one direct resolution action.

### Resume work

Show recently edited drafts with:

- type;
- name;
- last edited time;
- save state;
- validation state;
- direct resume action.

### Recent activity

Display concise immutable events:

- guidance published;
- routine submitted, approved, rejected, published, or activated;
- media uploaded/failed;
- review completed;
- correction/protection event relevant to the user.

## 7.4 Routine library

Features:

- list and card views;
- search;
- filters by draft/submitted/approved/published/archived;
- sort by updated, name, activation, and status;
- clear active/upcoming indicators;
- duplicate as new draft;
- folder/tag organization only if library size later justifies it;
- empty state with create action.

Do not expose hidden user data across owners.

## 7.5 Routine editor

### Expanded three-pane structure

- left: seven-day/day-template outline;
- center: selected workout-day editor;
- right: validation, volume, duration, mobile preview, and publication status.

### Compact structure

- day outline becomes a top selector;
- editor is single pane;
- validation/preview opens as a route, sheet, or tab.

### Day editor

Fields:

- title;
- purpose;
- target muscles;
- estimated duration;
- equipment summary;
- workout note;
- ordered exercise prescriptions.

Exercise prescription includes:

- exercise/guidance identity;
- sets;
- repetitions/range;
- RIR;
- rest;
- priority;
- progression/comparability metadata;
- contextual notes.

### Authoring improvements

- drag-and-drop reorder with keyboard move alternative;
- duplicate exercise prescription;
- duplicate workout day;
- collapse/expand all;
- exercise search with muscle/equipment filters;
- recent/favorite exercises;
- live duration and set-count estimate;
- muscle-volume summary;
- inline validator feedback;
- validation summary linking to exact fields;
- mobile preview;
- unsaved-change and autosave status;
- named checkpoints before major edits;
- compare against current published version.

### Publication state

A persistent state bar shows:

- Draft;
- Valid with warnings;
- Blocked;
- Submitted;
- Rejected;
- Approved;
- Scheduled;
- Published;
- Active;
- Superseded.

Actions are limited to those valid for the current immutable state.

## 7.6 Exercise library

Use adaptive list-detail.

### List/table

Columns or card fields:

- exercise name;
- canonical variant;
- equipment;
- primary muscles;
- guidance publication state;
- media completeness;
- routine usage count;
- last updated.

Features:

- search;
- filters;
- sort;
- keyboard navigation;
- selected-item detail pane;
- create custom exercise;
- explicit clone where permitted;
- usage links.

### Exercise detail

Tabs or sections:

- Overview;
- Guidance;
- Media;
- Usage;
- Versions;
- Activity.

## 7.7 Guidance editor

Use structured sections rather than one long unstructured document.

Sections:

- description;
- muscles;
- setup;
- execution;
- cues;
- mistakes;
- safety notes;
- images and alt text;
- YouTube reference;
- mobile preview.

Features:

- autosave;
- section completion indicators;
- live validation;
- image upload progress and retry;
- drag reorder with keyboard alternative;
- cover image selection;
- alt-text requirement;
- YouTube URL normalization and preview;
- side-by-side mobile preview on expanded widths;
- content-only publication action;
- explanation when a change requires routine review;
- version history and compare.

## 7.8 Review queue and review screen

### Queue

- submitted items only;
- owner;
- submission time;
- validator status;
- affected week/activation target;
- status;
- direct open action.

### Review screen

Use a focused comparison layout:

- submission summary;
- validator result;
- immutable content hash;
- side-by-side or inline diff from prior published version;
- changed prescriptions highlighted;
- changed guidance identity/revision highlighted;
- volume and duration change summary;
- mobile preview;
- reviewer note;
- approve/reject actions.

Self-approval is unavailable and explained. Rejection requires a useful note. Approval shows exactly which hash/version is being approved.

## 7.9 Version history

Every routine and guidance detail exposes a timeline with:

- version/checkpoint identity;
- author;
- timestamp;
- state;
- note/description;
- content hash where relevant;
- compare;
- preview;
- duplicate as new draft.

Published history is immutable. Restore creates a new draft rather than rewriting history.

## 7.10 Activity and audit

Activity is human-readable and filterable.

Filters:

- routines;
- guidance;
- media;
- reviews;
- publication;
- account/session-relevant events;
- corrections/protections visible to the owner.

Each event shows:

- actor;
- action;
- object;
- timestamp;
- state before/after when useful;
- link to detail;
- configuration/version evidence when relevant.

This view does not expose privileged security logs or another user's private data.

## 7.11 Dashboard settings and data export

Settings include the same user preferences as mobile where applicable.

Add a self-service export action for the user's own data:

- routines and versions;
- exercise definitions and guidance metadata;
- workout history;
- RR/XP/wallet transactions;
- protections and corrections;
- profile/preferences;
- media manifest references.

Initial formats:

- human-readable CSV files inside a ZIP for tabular history;
- JSON for versioned structured records;
- no passwords, tokens, private object bytes, or another user's data.

Export generation is server-authoritative and auditable. It may be deferred to release hardening, but the settings entry and architecture are planned now.

## 8. Shared state patterns

Every data surface defines:

- initial loading;
- refreshing;
- empty;
- partial data;
- stale cache;
- offline;
- saving;
- saved;
- pending synchronization;
- provisional;
- conflict;
- permission denied;
- not found;
- recoverable error;
- terminal error.

Skeletons should resemble final structure and must not pulse indefinitely under reduced motion.

## 9. Validation and error behavior

### Forms and editors

- errors are written in text;
- errors appear beside the field and in a summary for multi-field submission failures;
- the summary links/focuses the exact field;
- errors explain how to correct the issue;
- warnings are visually and semantically distinct from blockers;
- validation does not erase entered values;
- server failures preserve the draft;
- success uses a non-blocking status message rather than an unnecessary modal.

### Mobile workout errors

Invalid set fields remain editable and visible. Finishing with invalid/incomplete data presents a review list linking to each exercise/set.

### Network errors

- state is explicit;
- retry is local to the failed operation;
- repeated global snackbars are avoided;
- offline-capable tasks remain usable;
- online-required tasks explain why connectivity is required.

## 10. Accessibility requirements

### Shared

- 200% text scaling without loss of essential content;
- non-color state indicators;
- logical focus and reading order;
- visible keyboard focus;
- no keyboard traps;
- reduced motion;
- adequate contrast;
- semantic headings/landmarks;
- status messages announced without stealing focus;
- form labels and instructions remain available after entry;
- charts have textual alternatives;
- drag-and-drop has keyboard alternatives.

### Mobile

- minimum 48 dp touch targets;
- TalkBack labels for set state, timer, rank progress, and synchronization;
- numeric inputs expose units;
- haptics are supplementary;
- active timer alerts are configurable.

### Dashboard

- WCAG 2.2 AA target;
- full keyboard operation for core workflows;
- focus moves to error summaries and dialogs correctly;
- tables expose headers and selected state;
- resizable layouts do not obscure content;
- hover-only information has focus/tap alternatives.

## 11. Performance and reliability requirements

### Mobile

- no full-page rebuild for timer ticks or rank animation;
- active workout autosave does not block typing;
- images use placeholders and bounded cache;
- long histories paginate or virtualize;
- no network dependency for rank emblems;
- app restores active route, draft, timer context, and scroll position after process recreation where feasible.

### Dashboard

- route-level code splitting where appropriate;
- virtualized long tables/lists;
- debounced search and autosave;
- optimistic reorder only with rollback;
- image processing does not freeze the main thread;
- filters and selected item are URL-addressable where safe;
- drafts survive reload and temporary network failure;
- editor panes avoid whole-page rerenders.

## 12. High-value additions accepted by this task

The following additions are accepted because they materially reduce friction or improve trust:

1. Mobile `Progress` destination replacing the narrower `History` label.
2. Previous comparable performance visible directly in the workout logger.
3. Best comparable performance and progression explanation available in context.
4. Automatic rest timer triggered by set completion.
5. `Next incomplete set` navigation.
6. Calendar and list history views.
7. Dashboard attention-first Overview.
8. Dashboard global search.
9. Dashboard command palette and searchable keyboard shortcuts.
10. Visible autosave/offline/conflict state.
11. Undo for reversible draft operations.
12. Structured validator summary linking to exact fields.
13. Side-by-side mobile preview while authoring.
14. Routine/guidance version comparison and duplicate-as-new-draft restore behavior.
15. First-run setup checklist.
16. User-owned data export planned for release hardening.
17. System/dark/light appearance modes through semantic tokens.

## 13. Explicit exclusions

The complete UI plan does not add:

- social feed, followers, likes, or comments;
- public profiles;
- nutrition tracking;
- sleep tracking;
- body-composition recommendations;
- wearable integration;
- AI-generated coaching/chat;
- automatic form analysis from camera video;
- public routine marketplace;
- coach sales, lead, billing, or client-management CRM;
- unrestricted unscheduled reward-bearing workouts;
- public signup;
- client-authoritative RR or rank calculation.

These would materially broaden the product and require separate evidence and decisions.

## 14. Testing matrix

Each UI milestone must cover applicable combinations of:

- compact, medium, and expanded widths;
- touch, mouse, and keyboard;
- dark, light, and system themes;
- 100%, 150%, and 200% text scaling;
- normal and reduced motion;
- loading, empty, populated, stale, offline, pending, provisional, error, and conflict states;
- both provisioned users with strict ownership isolation;
- Android API 24 baseline and current Android target;
- current supported Chromium-based dashboard browser and keyboard navigation;
- screen-reader semantics;
- route restoration and draft recovery.

## 15. Ownership and implementation boundaries

- shared tokens and primitives belong in `packages/ui/`;
- pure presentation/domain models belong in `packages/domain/` where appropriate;
- mobile composition and navigation belong in `apps/mobile/`;
- dashboard composition and navigation belong in `apps/dashboard/`;
- clients consume repositories/adapters rather than calling Supabase directly from widgets;
- server authority, RLS, immutable versions, and ledger rules remain unchanged;
- screen specifications do not authorize backend behavior before its implementation packet.

## 16. Decision status

This is an accepted product-interface baseline. No new architecture ADR is required because the plan remains inside the accepted Flutter, Supabase, RLS, SQLite, and server-authoritative architecture.

Implementation sequencing is defined in `docs/context/UI_IMPLEMENTATION_PLAN.md`.