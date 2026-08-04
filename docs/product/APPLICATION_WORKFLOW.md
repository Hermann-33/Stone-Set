# Stone Set End-to-End Application Workflow

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT WORKFLOW`
Tasks: `TASK-PD-008`, `TASK-PL-002`, `TASK-PD-009`

## Product surfaces

### Android Flutter app

- sign-in;
- week, rank, wallet, and history;
- workout overview and exercise guidance;
- online workout start;
- workout timers and set entry;
- SQLite local draft recovery and synchronization;
- prefetched instruction text and images for the active session;
- embedded online YouTube demonstrations;
- swaps and payment selection;
- pending, provisional, and finalized results;
- progression, protection, and corrections.

### Flutter Web dashboard

The dashboard's primary purpose is managing the user's routines and exercise guidance.

It provides:

- private routine drafting;
- workout-day summaries;
- user-owned exercise library;
- muscle targeting;
- setup, execution, cues, mistakes, and safety notes;
- exercise image upload and ordering;
- YouTube URL validation and preview;
- mobile guidance preview;
- hard routine validation feedback;
- routine submission for independent review;
- guidance and routine revision history;
- publication preview and future activation.

### Supabase backend

- identity and sessions;
- RLS-protected records;
- routine and guidance versioning;
- private exercise-media Storage;
- routine validation, review, and publication;
- weekly plans and guidance revision snapshots;
- workout synchronization;
- server-authoritative rewards, wallet, penalties, corrections, and finalization.

## 1. Account provisioning and sign-in

1. An operator creates the initial Supabase Auth users.
2. Each user receives a linked profile.
3. Public registration remains disabled.
4. Mobile and dashboard sessions use authenticated publishable-client access.
5. One ordinary user cannot read or mutate another user's private records or media.

## 2. Exercise library and guidance management

1. The user creates or selects an exercise definition in their dashboard library.
2. The user edits a guidance draft containing description, muscles, instructions, images, and an optional YouTube video.
3. The dashboard validates structured text, muscle selections, image count, MIME, size, dimensions, alt text, and YouTube URL.
4. Images are processed to remove EXIF/GPS metadata and uploaded to new immutable private Storage paths.
5. A YouTube link is normalized to a video ID and previewed in the official embedded player.
6. Publishing creates an immutable guidance revision.
7. Content-only guidance revisions may be self-published by the owning user.
8. A change affecting canonical exercise variant, equipment, set prescription, repetitions, RIR, rest, priority, progression, or PR comparability is treated as a routine change and follows routine review.
9. A user cannot silently mutate another user's exercise library; permitted content can be explicitly cloned into a new owned definition.
10. Published or historical image objects cannot be overwritten or deleted through ordinary dashboard actions.

## 3. Routine draft, validation, and review

1. The user creates a routine draft in the dashboard.
2. Each workout day includes a title, brief purpose, target muscles, estimated duration, equipment summary, and ordered exercise prescriptions.
3. Each exercise prescription references a stable exercise definition and a published guidance revision.
4. The draft is editable only by its author.
5. The server runs `routine-validator-v1` and returns structured hard errors.
6. A valid draft is submitted with an immutable content hash.
7. A different authorized user reviews the exact reward-bearing submission.
8. The reviewer may approve or reject and leave a note; the reviewer cannot edit the draft.
9. Self-approval is rejected server-side.
10. Approval stores the reviewer, validator result, content hash, and timestamp.
11. Publication reruns validation and verifies that the approved hash still matches.
12. Publication creates an immutable version effective on a future unlocked Monday.
13. Rejection leaves the current published version active.
14. Every reward-bearing change requires a new reviewed version.

## 4. Weekly materialization

At or before the reward week:

1. materialize any due monthly free-swap grant idempotently;
2. select the approved routine version effective for the week;
3. create seven dated plan items;
4. pin the workout-day guidance and exercise-guidance revision IDs;
5. store routine, validator, guidance, rank, scheduling, and timezone versions;
6. allocate daily RR, base XP, and workout penalties deterministically;
7. store immutable base schedule and pre-lock current schedule.

Later routine or guidance changes cannot rewrite a materialized week.

## 5. Mobile home

The authenticated home screen shows:

- today's workout or rest item;
- seven-day schedule and lock states;
- swaps used and remaining;
- free-swap balance;
- rank, RR, lifetime XP, multiplier, and progress;
- pending synchronization and provisional transactions;
- the next valid action.

## 6. Workout opening and guidance

Opening a workout shows:

- workout title and brief session purpose;
- primary and secondary muscle groups;
- estimated duration and equipment summary;
- ordered exercise cards;
- each exercise's cover image or neutral placeholder;
- prescribed sets, repetitions, RIR, and rest;
- a `How to perform` action.

The exercise guidance view shows:

1. short explanation;
2. primary and secondary muscles;
3. setup and execution steps;
4. ordered instruction images;
5. technique cues, common mistakes, and safety notes;
6. an embedded YouTube player when online and configured;
7. an external YouTube fallback.

Guidance opens without resetting entered sets, active timers, scroll position, or local draft state. Viewing guidance is optional and does not affect rewards.

## 7. Swap workflow

1. User selects two distinct unlocked dates.
2. Backend validates ownership, active week, locks, and remaining allowance.
3. UI previews both items, resulting order, warnings, credits, and `Pay 5 RR` option.
4. User explicitly chooses one payment instrument.
5. Backend atomically exchanges complete plan-item identities, including pinned guidance references, consumes the allowance and payment, and writes audit records.
6. Canceled preview changes nothing.
7. Swapping back is another valid paid or credited swap.

## 8. Workout start

Starting requires connectivity.

1. User opens today's workout and may inspect its guidance before starting.
2. Client requests a session start with an idempotency key.
3. Backend verifies the item is owned, current, unlocked, reward eligible, and references readable guidance.
4. Backend creates or returns the session, locks the item, and returns:
   - server session ID;
   - server start timestamp;
   - immutable prescription snapshot;
   - pinned workout and exercise guidance metadata;
   - signed or authenticated image references;
   - normalized YouTube video references;
   - previous comparable results and recommendation evidence.
5. Mobile creates the SQLite local draft keyed by user and session.
6. Mobile stores guidance text and begins prefetching instruction images.
7. Session and rest timers start.

An offline client may view previously cached content but cannot authoritatively start a new session.

## 9. Set entry and offline continuation

For each working set, the user records exercise variant, load where applicable, repetitions, RIR, status, and optional note or pain flag.

- Every completed edit is transactionally autosaved to SQLite.
- UI keystrokes may debounce for at most 500 milliseconds.
- Outbox mutations carry stable idempotency keys and payload versions.
- A valid started workout may continue without connectivity.
- Guidance text remains available offline.
- Successfully prefetched images remain available for the active session.
- Missing images show placeholders and retry controls.
- YouTube playback is explicitly unavailable offline and never blocks set logging.
- Sync occurs on foreground, connectivity regain, explicit retry, and final submit.
- Stone Set does not run continuous periodic polling.
- The cached prescription and guidance revisions cannot be altered for the active session.

## 10. YouTube playback

- The app uses the official YouTube IFrame Player API in an OS-provided Android WebView.
- The player provides a valid Referer or base URL.
- Privacy-enhanced embedding is used where compatible.
- Playback is user-initiated; there is no autoplay.
- Standard YouTube controls, branding, advertisements, and player behavior remain visible.
- The player pauses when the guidance view closes or the app backgrounds.
- Stone Set does not download, cache, background-play, extract, or reward YouTube content.
- Errors such as embedding disabled, removed, private, age-restricted, or region-blocked content produce a clear fallback to open YouTube.

## 11. Session completion

### Online completion

1. Client synchronizes pending mutations.
2. Client submits final state idempotently.
3. Backend validates prescription, sets, timestamps, completion, logging, duplication, PR evidence, and configuration versions.
4. Backend returns the authoritative completed, partial, invalid, protected, or correction-pending state and stored provisional transactions.

### Offline completion

1. Mobile records local `pending_submission`.
2. No authoritative RR, XP, PR, rank, or consistency result is shown.
3. UI displays pending synchronization.
4. On reconnection, the outbox and final submission synchronize idempotently.
5. Duplicate retries return the existing server result.

### Week-close grace

A session started before its item locked has 24 hours after Sunday 23:59 in the reward timezone to synchronize. Weekly finalization waits for started sessions until resolution or grace expiry.

## 12. Rest items

- A programmed rest item remains visible.
- No manual completion check-in is required.
- It finalizes automatically at local day close and earns its stored lower allocation.
- It has no PR or missed penalty.
- Unscheduled training on that date earns no extra RR or XP.

## 13. Weekly finalization

After the week and pending-session grace:

1. freeze the final post-swap schedule;
2. apply approved protections and corrections;
3. resolve all seven plan items;
4. apply direct missed-workout penalties;
5. calculate workout-completion ratio;
6. classify perfect, non-perfect, failed, or protected;
7. increment, freeze, or reset consistency;
8. apply multiplier top-ups, milestones, perfect-week bonus, and failed-week decay;
9. store immutable schedule, wallet, rank, routine, guidance, and evaluation snapshots.

Finalization is idempotent.

## 14. Logout and account privacy

If unsynchronized data exists, logout requires:

- synchronize now;
- remain signed in; or
- explicitly discard the draft.

After sync or discard, private local workout and cached guidance media for that account are removed. Silent account switching with another user's draft or media cache is not supported.

## 15. Progression, protection, and corrections

- Progression recommendations use comparable exercise history and double progression.
- Recommendations never silently mutate a published routine.
- Guidance changes never redefine PR comparability silently.
- Pain flags stop automatic progression for the movement and do not provide medical diagnosis.
- Protected events require an auditable reason.
- Backdated corrections reverse exact stored values and preserve transaction history.

## 16. History

Users can inspect:

- exercise definitions and guidance revisions;
- image and video references used by each revision;
- routine versions and reviews;
- weeks and swaps;
- workout sets and pinned guidance versions;
- PR evidence;
- RR/XP transactions;
- wallet grants and consumption;
- penalties, decay, milestones, protection, and corrections;
- every configuration version used.

## MVP exclusions

- public signup;
- iOS;
- coach or organization accounts;
- cross-user routine or guidance editing;
- public exercise gallery;
- direct video upload;
- non-YouTube video providers;
- YouTube search inside Stone Set;
- offline YouTube playback;
- rewards for viewing guidance;
- social, nutrition, sleep, payment, wearable, or medical-diagnosis features;
- offline workout start;
- client-side score finalization;
- historical recalculation from current formulas.
