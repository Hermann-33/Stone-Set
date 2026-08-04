# Stone Set End-to-End Application Workflow

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT WORKFLOW`
Tasks: `TASK-PD-008`, `TASK-PL-002`, `TASK-PD-009`, `TASK-PD-010`

## Product surfaces

### Android Flutter app

- native username/password login page;
- first-login password change and session restoration;
- authenticated home, week, rank, wallet, and history;
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

The dashboard has a responsive username/password login page and protected authenticated routes. Its primary purpose is managing the user's routines and exercise guidance.

It provides:

- first-login password change, session restoration, and logout;
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

- provisioned identity, password authentication, sessions, and token refresh;
- protected profiles and first-password-change state;
- RLS-protected records;
- routine and guidance versioning;
- private exercise-media Storage;
- routine validation, review, and publication;
- weekly plans and guidance revision snapshots;
- workout synchronization;
- server-authoritative rewards, wallet, penalties, corrections, and finalization.

## 1. Account provisioning

1. An operator creates each initial Supabase Auth user with a confirmed internal email alias and temporary password.
2. The alias is generated from the immutable normalized username and configured Stone Set auth domain.
3. Each Auth user receives a linked protected profile.
4. The profile begins with `must_change_password = true`.
5. Public registration, social login, anonymous login, and public invitation are disabled.
6. Credentials are delivered securely outside the application.

## 2. Client launch and login

1. The client restores any persisted Supabase session before rendering private content.
2. A valid session with an active profile routes to the authenticated home.
3. No valid session routes to the native mobile login screen or dashboard `/login` page.
4. The login page accepts username and password.
5. The username is trimmed and normalized to lowercase.
6. The client deterministically derives the operator-provisioned internal email alias.
7. The client calls Supabase Auth password sign-in.
8. On success, the client verifies the linked profile and active status.
9. Missing, disabled, or mismatched profiles are signed out immediately.
10. Login failures use a generic message and never identify whether the username exists.
11. Rate-limit responses show a neutral retry-later state.
12. An authenticated user visiting the login route is redirected to the appropriate home.

## 3. First-login password change

1. When `must_change_password` is true, every product route redirects to the password-change screen.
2. The user enters and confirms a new password.
3. The password is updated directly through Supabase Auth.
4. Password values are never stored in application tables or logs.
5. The server-controlled flag is cleared only after the update succeeds.
6. The user then enters the normal authenticated application.

## 4. Session and logout behavior

- Mobile and dashboard sessions are independent but belong to the same Auth user.
- Protected dashboard routes require a valid session and active profile.
- Mobile private screens require a valid session and active profile.
- Token refresh is handled through the Supabase client lifecycle.
- Unrecoverable refresh failure returns the client to authentication-required state.
- Dashboard logout signs out, clears private caches, and routes to `/login` without leaving private content visible through back navigation.
- Mobile logout with no unsynchronized draft signs out and clears private caches.
- Mobile logout with unsynchronized workout data requires sync, remain signed in, or confirmed discard.
- Session expiry with an unsynchronized mobile draft quarantines it until the same account reauthenticates; another account cannot read it.
- Password recovery is operator-managed in MVP and sets a temporary password plus `must_change_password`.

## 5. Exercise library and guidance management

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

## 6. Routine draft, validation, and review

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

## 7. Weekly materialization

At or before the reward week:

1. materialize any due monthly free-swap grant idempotently;
2. select the approved routine version effective for the week;
3. create seven dated plan items;
4. pin the workout-day guidance and exercise-guidance revision IDs;
5. store routine, validator, guidance, rank, scheduling, and timezone versions;
6. allocate daily RR, base XP, and workout penalties deterministically;
7. store immutable base schedule and pre-lock current schedule.

Later routine or guidance changes cannot rewrite a materialized week.

## 8. Mobile home

The authenticated home screen shows:

- today's workout or rest item;
- seven-day schedule and lock states;
- swaps used and remaining;
- free-swap balance;
- rank, RR, lifetime XP, multiplier, and progress;
- pending synchronization and provisional transactions;
- the next valid action.

## 9. Workout opening and guidance

Opening a workout shows:

- workout title and brief session purpose;
- primary and secondary muscle groups;
- estimated duration and equipment summary;
- ordered exercise cards;
- each exercise's cover image or neutral placeholder;
- prescribed sets, repetitions, RIR, and rest;
- a `How to perform` action.

The exercise guidance view shows explanation, muscles, setup, execution, ordered images, cues, mistakes, safety notes, embedded YouTube playback when available, and an external YouTube fallback.

Guidance opens without resetting entered sets, active timers, scroll position, or local draft state. Viewing guidance is optional and does not affect rewards.

## 10. Swap workflow

1. User selects two distinct unlocked dates.
2. Backend validates ownership, active week, locks, and remaining allowance.
3. UI previews both items, resulting order, warnings, credits, and `Pay 5 RR` option.
4. User explicitly chooses one payment instrument.
5. Backend atomically exchanges complete plan-item identities, including pinned guidance references, consumes the allowance and payment, and writes audit records.
6. Canceled preview changes nothing.
7. Swapping back is another valid paid or credited swap.

## 11. Workout start

Starting requires connectivity.

1. User opens today's workout and may inspect its guidance before starting.
2. Client requests a session start with an idempotency key.
3. Backend verifies the item is owned, current, unlocked, reward eligible, and references readable guidance.
4. Backend creates or returns the session, locks the item, and returns the immutable prescription, pinned guidance, image references, YouTube reference, history evidence, session ID, and server timestamp.
5. Mobile creates the SQLite local draft keyed by user and session.
6. Mobile stores guidance text and begins prefetching instruction images.
7. Session and rest timers start.

An offline client may view previously cached content but cannot authoritatively start a new session.

## 12. Set entry and offline continuation

- Every completed set edit is transactionally autosaved to SQLite.
- UI keystrokes may debounce for at most 500 milliseconds.
- Outbox mutations carry stable idempotency keys and payload versions.
- A valid started workout may continue without connectivity.
- Guidance text remains available offline.
- Successfully prefetched images remain available for the active session.
- Missing images show placeholders and retry controls.
- YouTube playback is unavailable offline and never blocks set logging.
- Sync occurs on foreground, connectivity regain, explicit retry, and final submit.
- Stone Set does not run continuous periodic polling.
- The cached prescription and guidance revisions cannot be altered for the active session.

## 13. YouTube playback

- The app uses the official YouTube IFrame Player API in an OS-provided Android WebView.
- The player provides a valid Referer or base URL.
- Privacy-enhanced embedding is used where compatible.
- Playback is user-initiated; there is no autoplay.
- Standard YouTube controls, branding, advertisements, and player behavior remain visible.
- The player pauses when the guidance view closes or the app backgrounds.
- Stone Set does not download, cache, background-play, extract, or reward YouTube content.
- Embedding errors produce a clear fallback to open YouTube.

## 14. Session completion

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

## 15. Rest items

- A programmed rest item remains visible.
- No manual completion check-in is required.
- It finalizes automatically at local day close and earns its stored lower allocation.
- It has no PR or missed penalty.
- Unscheduled training on that date earns no extra RR or XP.

## 16. Weekly finalization

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

## 17. Progression, protection, corrections, and history

- Progression recommendations use comparable exercise history and double progression.
- Recommendations never silently mutate a published routine.
- Guidance changes never redefine PR comparability silently.
- Pain flags stop automatic progression for the movement and do not provide medical diagnosis.
- Protected events require an auditable reason.
- Backdated corrections reverse exact stored values and preserve transaction history.
- Users can inspect identity-relevant profile state, guidance revisions, routine versions, weeks, workouts, transactions, protection, corrections, and every configuration version used.

## MVP exclusions

- public signup or public invitations;
- social, anonymous, magic-link, or SSO login;
- self-service email password recovery;
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