# Stone Set Audit Log — Continued

This volume preserves `docs/context/AUDIT_LOG.md` unchanged and continues material audit history from `TASK-PD-008` onward.

## 2026-08-04 — TASK-PD-008 — Multi-user normalization activation audit

### Scope

- accept or reject the proposed daily normalized rank economy;
- activate canonical rank, scheduling, and workflow specifications if accepted;
- preserve Adonis, multipliers, swaps, free credits, history, and server authority;
- synchronize current context without implementing code.

### Accepted result

- `rank-v6` and `schedule-v3` activated;
- 4–6 workout days and 7 plan items supported;
- fixed weekly RR pools and 4:1 workout/rest allocation accepted;
- 95 RR weekly missed-workout penalty pool accepted;
- maximum two rewarded PRs per week accepted;
- failed-week threshold below 60% workout completion accepted;
- 1.46-week maximum synthetic mean variance accepted;
- application workflow promoted to accepted;
- no production migration required because no runtime or history existed.

### Verification

- all supported weekly allocations sum exactly to configured pools;
- all penalty allocations sum to 95 RR;
- Adonis at 5,500 and 5/10/15 multipliers preserved;
- swap and free-credit rules preserved;
- no code, schema, account, credential, deployment, or infrastructure introduced.

### Verdict

`COMPLETE`

The previously missing material audit entry is now preserved in the continuation volume without rewriting earlier audit history.

---

## 2026-08-04 — TASK-PL-002 — Implementation-constraint closure audit

### Scope

- research current best practices for every remaining implementation decision;
- define routine anti-triviality and review controls;
- define local draft, offline, and finalization boundaries;
- select mobile release and dashboard hosting targets;
- define Supabase production access, backup, and recovery;
- approve a bounded first implementation packet;
- close Phase 0 without implementing Phase 1.

### Material findings

1. Hard routine limits alone cannot prove hypertrophy quality; server validation and independent human review are both required.
2. Self-approval would make user-controlled normalized rewards trivial to game.
3. SQLite is suitable for structured active mobile drafts, but the server must remain authoritative.
4. Requiring an online start resolves schedule locking and session identity before offline work begins.
5. Continuous background polling is unnecessary and battery-hostile for the MVP.
6. Android-first removes an unnecessary macOS/Xcode/signing gate.
7. Flutter Web static output fits Vercel when CI owns the pinned build and deployment promotes the tested artifact.
8. Supabase Pro daily backups plus independent encrypted logical exports provide proportionate recovery; PITR is not cost-justified initially.
9. Shared operator accounts are unacceptable; two distinct owners, MFA, least privilege, and restore drills are required.

### Accepted decisions

- `routine-validator-v1` and independent reviewed publication;
- SQLite local drafts through `sqflite`;
- online session start, offline continuation, pending online finalization, and 24-hour grace;
- Android API 24+ initial release; iOS deferred;
- Vercel static dashboard hosting with staging previews and verified promotion;
- local/staging/production Supabase separation;
- Pro daily backup retention, encrypted independent exports, RPO 24 hours, RTO 4 hours;
- two Owner accounts, MFA enforcement, least privilege, and quarterly restore tests;
- approved `TASK-IMP-001` packet.

### Verification

- routine validation fixtures include invalid frequency, volume, duration, set, duplicate-alias, self-approval, changed-content, and unapproved-publication cases;
- offline workflow contains explicit source-of-truth, conflict, retry, logout, and week-close behavior;
- dashboard preview cannot use production data;
- no privileged secrets enter static clients;
- recovery has managed and independent backup paths;
- the task packet contains all mandatory execution and completion fields;
- repository documents distinguish accepted design from implemented behavior;
- no implementation or external state was created.

### Risks remaining

- actual package and service behavior must be verified again at implementation and release time;
- routine review remains partly judgment-based;
- offline start is intentionally unsupported;
- operational backup tasks require discipline until automated;
- no real-user production evidence exists.

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Verdict

`COMPLETE`

All material Phase 0 ambiguities are closed. The repository is ready for the approved foundation implementation task and nothing beyond its bounded scope.

---

## 2026-08-04 — TASK-PD-009 — Workout guidance and media planning audit

### Scope

- define workout-day explanations and exercise instructions;
- make the Flutter Web dashboard the routine and exercise-content management surface;
- define user-owned image upload and hosting;
- define YouTube link validation and embedded Android playback;
- define ownership, versioning, offline behavior, security, and recovery;
- preserve the approved foundation packet and rank economy;
- synchronize all authoritative documents without implementing code.

### Material findings

1. Vercel's static deployment output cannot persist runtime user uploads.
2. Supabase Storage is the lowest-complexity image store that preserves the accepted Auth and RLS architecture.
3. Arbitrary external image URLs introduce broken-link, tracking, hotlinking, and silent-content-replacement risk.
4. Exercise media needs immutable revision references so active and historical workouts do not change unexpectedly.
5. Content-only guidance changes can be versioned separately, but variant, equipment, prescription, progression, and PR-comparability changes remain reviewed routine changes.
6. User-owned exercise libraries prevent one user's edits from silently changing another user's routines.
7. YouTube requires official IFrame behavior, player sizing, visible controls, valid playback context, and policy-compliant WebView integration.
8. YouTube playback cannot be downloaded, cached, background-played, modified, ad-suppressed, or incentivized.
9. Essential instruction text and images need offline availability for a valid started workout; YouTube remains online-only.
10. Supabase database backups do not include Storage object bytes, so complete recovery needs a separate encrypted object export and manifest.

### Accepted product behavior

- workout title, purpose, target muscles, duration, equipment, and optional note;
- exercise explanation, primary/secondary muscles, setup, execution, cues, mistakes, safety notes, ordered images, and optional YouTube video;
- dashboard exercise library, image editor, YouTube preview, usage view, revision history, and mobile preview;
- user-owned stable exercise definitions and immutable guidance revisions;
- explicit clone rather than shared mutable cross-user content;
- content-only self-publication after validation;
- pinned guidance revisions on materialized weeks and started sessions;
- no reward or completion dependency on guidance viewing.

### Accepted media behavior

- one private `exercise-media` Supabase Storage bucket;
- 0–6 images, one cover, JPEG/PNG/static WebP, maximum 5 MB, maximum 2400-pixel longest edge;
- orientation correction, EXIF/GPS removal, optimization, content hash, required alt text, immutable object paths, and no upsert;
- one optional single-video YouTube reference per guidance revision;
- URL normalization and embedded preview before publication;
- official IFrame playback in Android WebView with valid Referer/base URL;
- privacy-enhanced mode where compatible;
- no autoplay, background play, download, caching, extraction, hidden controls, ad suppression, or rewards;
- external YouTube fallback for runtime failures.

### Accepted offline and recovery behavior

- active-session snapshot includes guidance revision identifiers and text;
- instruction images are prefetched and cached when possible;
- image or YouTube failure never blocks workout execution;
- cached private media follows logout cleanup;
- weekly and month-end independent backups include encrypted Storage object exports and manifests;
- restore drills reconcile database metadata with actual image objects.

### Files and decisions

- created `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`;
- created `ADR-0006-exercise-media-storage-and-youtube-embedding.md`;
- extended `APPLICATION_WORKFLOW.md`;
- synchronized active context, project brief, architecture, codebase map, roadmap, implementation plan, handoff, bootstrap, README, ADR index, and audit history.

### Verification

- official YouTube player, WebView, Referer, size, control, playback, and developer-policy guidance reviewed;
- official Supabase private bucket, Storage RLS, upload, MIME/size, signed/authenticated access, object ownership, and backup guidance reviewed;
- cross-user, immutable-history, deletion, clone, offline, media failure, and restore scenarios defined;
- rank, scheduling, penalties, swaps, and progression economics unchanged;
- `TASK-IMP-001` remains valid because it excludes product and media implementation;
- no code, schema, bucket, package, project, credential, media, deployment, or runtime created.

### Risks remaining

- user-authored instructional content can be inaccurate and is not medical advice;
- YouTube availability and embed permissions can change after publication;
- Storage RLS and image decoding require rigorous tests;
- active-session image cache limits require implementation tuning;
- Storage backup remains operationally separate from database backup.

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Verdict

`COMPLETE`

The requested workout explanation, muscle, image, and YouTube features are accepted and implementation-ready at the product and architecture level. The foundation task remains the exact next action.

---

## 2026-08-04 — TASK-PD-010 — Mobile and dashboard login-page audit

### Scope

- make login pages explicit for both clients;
- define shared account, provisioning, credential, session, route-guard, logout, and recovery behavior;
- preserve Supabase Auth ownership and the approved foundation boundary;
- synchronize planning documents without implementation.

### Material findings

1. Supabase password sign-in requires an email or phone identity, while Stone Set presents a username-oriented interface.
2. A deterministic operator-provisioned internal email alias preserves username UX without adding a public username resolver.
3. Both clients need explicit session restoration and route guards to prevent private-content flashes.
4. Generic errors are required to limit account enumeration.
5. A forced first-login password change is appropriate for operator-created temporary credentials.
6. Mobile logout and involuntary expiry must preserve unsynchronized workout drafts safely.
7. Public self-service recovery is unnecessary for two privately provisioned users and would require a separate contact-email workflow.

### Accepted decisions

- Android native login screen and responsive web `/login` page;
- same provisioned username/password account on both clients;
- internal Supabase email alias derived from normalized username and configured auth domain;
- no signup, social login, anonymous login, magic link, or public recovery;
- first-login password change;
- persistent sessions and protected routes;
- generic login and disabled-profile failures;
- Supabase rate limits, with CAPTCHA deferred to release hardening;
- independent mobile and dashboard sessions;
- dashboard logout cache cleanup and back-navigation privacy;
- mobile sync/stay/discard logout flow;
- same-account quarantine for drafts after involuntary session loss;
- operator-managed temporary-password recovery and optional session revocation;
- Phase 2 renamed and expanded to identity, login, sessions, profiles, and ownership.

### Verification

- both client surfaces are explicitly covered;
- passwords remain exclusively in Supabase Auth;
- no public username directory is introduced;
- no service-role key is required in either client;
- login does not alter rank, routine, media, or scheduling rules;
- `TASK-IMP-001` remains foundation-only;
- no code, project, account, credential, schema, deployment, or runtime was created.

### Risks remaining

- auth alias configuration must remain consistent across provisioning and clients;
- operator-managed recovery creates an availability dependency;
- persistent dashboard sessions require careful shared-device logout behavior;
- draft quarantine and same-account recovery require strong tests.

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Verdict

`COMPLETE`

Both login experiences and their session lifecycle are accepted and implementation-ready. The foundation task remains the exact next action.

---

## 2026-08-04 — TASK-ASSET-001 — Rank-emblem curation audit

### Scope

- select a legally reusable visual source for all 20 `rank-v6` ranks;
- create one coherent Stone Set asset system without proprietary game marks;
- commit normalized PNG masters, mapping, provenance, and review documentation;
- preserve all rank names, order, RR thresholds, and Phase 1 boundaries.

### Accepted result

- one Kenney CC0 insignia family selected and pinned by source commit;
- 20 ordered textless transparent 256 × 256 PNGs generated under `assets/ranks/`;
- shared Stone Set shield treatment and family palettes applied;
- `manifest.json` records rank, threshold, source file, palette, dimensions, visible bounds, and SHA-256;
- repository provenance, licence, asset contract, and contact sheet added;
- reproducible Python generator and GitHub Actions generation/verification added;
- no client integration or rank behavior implemented.

### Verification

- exact count and filename order passed;
- PNG signature, decode, dimensions, RGBA, transparency, and visible-bounds checks passed;
- manifest JSON and SHA-256 checks passed;
- remote pull-request file list includes all 20 images and supporting files;
- temporary upload artifacts were removed;
- no secret, credential, personal data, proprietary game logo, or gym-equipment symbol was introduced;
- Phase 1 remains ready and not started.

### Verdict

`COMPLETE`

The complete `stone-set-ranks-v1` visual asset baseline exists on the task branch and is ready for review and later application integration.

