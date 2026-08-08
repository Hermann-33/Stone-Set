# TASK-IMP-003B — Implement private exercise media and YouTube guidance

Status: `APPROVED — NOT EXECUTED`

## Approval and activation boundary

This packet is approved for execution only after `TASK-IMP-003A` is complete and merged into the
branch point used for implementation. At approval time that prerequisite is satisfied through pull
request #14 and merge commit `eb59a3b4707ff12c154594408f1f7902555f39e0`.

The implementation agent must re-check that merge, the current repository authority, the clean
working tree and the exact dependency/tool versions before changing files. If the prerequisite or an
accepted decision no longer matches, stop and report the conflict rather than silently changing this
packet.

Approval does not mean media, Storage policies, YouTube preview, Android playback, routines, remote
infrastructure or production operations already exist.

## Objective

Extend the merged exercise/guidance vertical with owner-scoped private images and one optional
validated YouTube reference per immutable guidance revision. Deliver the dashboard authoring and
preview workflow, local Supabase metadata and Storage authorization, deterministic media contracts,
and the tests needed to prove ownership, privacy, immutability, failure recovery and policy
compliance.

The result must preserve the `TASK-IMP-003A` text-content hash and immutable revision contracts. It
must not add Android playback; that belongs to `TASK-IMP-005B`.

## Mandatory repository reads

Before implementation, read the current versions of:

1. `AGENTS.md`;
2. `docs/context/ACTIVE_CONTEXT.md`;
3. `docs/context/PROJECT_BRIEF.md`;
4. `docs/context/ARCHITECTURE.md`;
5. `docs/context/CODEBASE_MAP.md`;
6. `docs/context/ROADMAP.md`;
7. `docs/context/WORKFLOW.md`;
8. `docs/context/HANDOFF.md`;
9. `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`;
10. `docs/product/APPLICATION_WORKFLOW.md`;
11. the current database/server and implementation plans identified by `CODEBASE_MAP.md`;
12. `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`;
13. `docs/decisions/ADR-0004-android-first-and-vercel-dashboard-hosting.md`;
14. `docs/decisions/ADR-0005-supabase-production-operations-and-recovery.md`;
15. `docs/decisions/ADR-0006-exercise-media-storage-and-youtube-embedding.md`;
16. `docs/decisions/ADR-0007-path-sensitive-ci-gates.md`;
17. `docs/tasks/TASK-IMP-003A.md` and its merged implementation; and
18. the current repository threat model and active audit volume.

Use the `supabase`, `supabase-postgres-best-practices`,
`flutter-apply-architecture-best-practices`, `dart-add-unit-test`,
`flutter-add-widget-test`, `dart-run-static-analysis` and bounded
`security-threat-model` skills where their scopes apply. Use official current primary evidence for
Storage, Flutter Web and YouTube behavior. Do not add unrelated design or framework skills.

## Verified starting state

The planning review verified:

```text
TASK-IMP-003A                   COMPLETE AND MERGED
TASK-IMP-003A pull request      #14
TASK-IMP-003A merge commit      eb59a3b4707ff12c154594408f1f7902555f39e0
Phase 2A                       COMPLETE
Phase 2B                       COMPLETE
Phase 2C                       COMPLETE
Flutter                        3.44.7
Dart                           3.12.2
Node.js                        24.11.1
Supabase CLI                   2.111.0
Dart dependency ownership      one root workspace lockfile
Supabase foundation            local-only
Exercise/guidance              merged structured authoring and immutable publication
Exercise media                 not implemented
YouTube guidance               not implemented
Remote Supabase/Vercel         not provisioned
```

Reverify these facts at implementation start. Do not infer a remote project, production bucket,
deployed Edge Function, backup target, credential or secret from the local foundation.

## Reviewed compatibility evidence and exact pins

The following exact direct dependencies are approved for this task:

```text
image          4.9.1
file_selector  1.1.0
web            1.1.1
```

Preserve the existing exact `supabase_flutter 2.17.1` dependency. It supplies the Storage client; do
not add a second Storage package. Do not add a YouTube wrapper. Implement the dashboard preview with
Flutter's official `HtmlElementView`, `package:web` and the official YouTube IFrame Player API so the
accepted parameters, lifecycle and privacy boundary remain explicit.

The review found:

- `image 4.9.1` supports current Dart and Web image decoding/encoding. Because it can decode
  multi-frame formats, the implementation must separately reject GIF, APNG, animated WebP and every
  other multi-frame input rather than assuming the package makes them safe.
- `file_selector 1.1.0` is Flutter-maintained, supports Web and is compatible with the repository's
  Dart SDK.
- `web 1.1.1` is Dart-maintained, compatible with the repository's Dart SDK and is the current typed
  browser API used by Flutter's Web-content guidance.
- Standard Supabase uploads are appropriate for the accepted processed-image ceiling of 5 MB;
  uploads must use a new immutable path with `upsert: false`.

Reverify these pins and APIs against current official package metadata at implementation start if
the official evidence has changed. Preserve exact versions in the one root workspace lockfile. Do
not introduce overrides or an additional lockfile.

Official evidence reviewed on 2026-08-08:

- <https://supabase.com/changelog?types=breaking-change>
- <https://supabase.com/docs/guides/storage/security/access-control>
- <https://supabase.com/docs/guides/storage/security/ownership>
- <https://supabase.com/docs/guides/storage/schema/design>
- <https://supabase.com/docs/guides/storage/buckets/fundamentals>
- <https://supabase.com/docs/guides/storage/uploads/standard-uploads>
- <https://supabase.com/docs/guides/local-development/cli/config>
- <https://supabase.com/docs/guides/local-development/overview>
- <https://supabase.com/docs/reference/dart/storage-from-upload>
- <https://docs.flutter.dev/platform-integration/web/web-content-in-flutter>
- <https://developers.google.com/youtube/iframe_api_reference>
- <https://developers.google.com/youtube/player_parameters>
- <https://pub.dev/packages/image/versions>
- <https://pub.dev/packages/file_selector/versions>
- <https://pub.dev/packages/web/versions>

## Required branch and Git behavior

Use:

```text
branch: codex/task-imp-003b-exercise-media-youtube
```

Requirements:

- branch from the current main line containing the `TASK-IMP-003A` merge;
- do not work directly on `main`;
- do not rewrite history;
- preserve unrelated user changes and stop if a dirty tree overlaps this scope;
- every commit message contains `TASK-IMP-003B`;
- inspect the complete diff before publication;
- push the branch and open a draft pull request;
- make the pull request ready and merge only after every required final-head gate passes; and
- report branch, commits, pull request, checks, merge state and exact residual risk.

## Architecture and ownership

### Canonical ownership

- Supabase Postgres owns media metadata, ordering, lifecycle state, immutable revision associations,
  hashes, authorization and idempotent operation results.
- The private Supabase Storage bucket `exercise-media` owns processed image bytes only.
- The dashboard owns file selection, browser-side preprocessing, upload progress and the authoring
  preview. Browser-derived hashes, dimensions and sanitization claims remain client evidence; the
  database may validate their shape and agreement with Storage metadata but must not describe them
  as server-attested inspection of object bytes.
- YouTube owns video bytes, streaming, player controls, advertising and availability. Stone Set owns
  only the normalized reference and validation snapshot.
- Published guidance revisions remain immutable. Media cannot be retroactively attached to an
  already-published revision; the user must duplicate it as a new draft and publish a new revision.

### Compatibility with the 003A hash contract

Do not silently redefine or rewrite the merged `guidance-content-v1` or guidance revision hash.
Introduce a versioned canonical `guidance-media-manifest-v1` containing the ordered image evidence
and optional YouTube evidence, then persist:

- a deterministic media-manifest hash; and
- a deterministic bundle hash over the existing immutable guidance revision hash plus that manifest
  hash.

The SQL and Dart encoders must have byte-for-byte parity. The manifest must use stable key order,
explicit null/absence rules and an explicit empty-manifest representation. Migration of existing
text-only revisions must not mutate their historical content or revision hashes. If the existing
schema cannot support this additive contract without changing an accepted public or persistence
decision, stop and create the required superseding ADR before implementation.

## Exact database scope

Create the minimum migration-managed public/private-schema objects needed for the following
contracts. Names may follow existing repository conventions, but the semantics are mandatory and
must be documented in the migration and data layer.

### 1. Draft image metadata and immutable revision associations

Persist, at minimum:

- UUID identity and owner user ID;
- exercise definition and guidance draft ownership;
- immutable guidance revision association after publication;
- bucket ID and immutable object path;
- MIME type, byte size, decoded width and height;
- SHA-256 of the final processed bytes;
- required alt text, zero-based display position and cover flag;
- lifecycle state and timestamps;
- optimistic draft/media revision; and
- server-created correlation/idempotency evidence.

Enforce at the database boundary:

- zero to six images per draft/revision;
- no duplicate position;
- at most one cover and exactly one cover when a published manifest has images;
- JPEG, PNG or static WebP only;
- processed byte size greater than zero and at most 5 MB;
- longest decoded edge at most 2400 pixels;
- shortest decoded edge at least 320 pixels;
- exactly 32 bytes/64 lowercase hexadecimal characters of SHA-256 according to the chosen storage
  representation;
- nonblank, bounded alt text before publication;
- immutable owner, exercise, bucket, path, hash, decoded dimensions and published association; and
- no ordinary update or delete of published history.

Draft metadata may be edited only through narrow operations. Publication must copy/pin an immutable
ordered association into the new guidance revision inside the same Postgres transaction as the
guidance publication. Do not mutate existing revision rows merely to add media.

### 2. Upload intents and lifecycle

Use short-lived server-created upload intents. Each intent binds one authenticated active owner to
an exercise, guidance draft, generated asset ID, exact bucket, exact object path, allowed MIME,
maximum byte size, expiration and one-use lifecycle state. The client must not choose another owner
root or convert an expired/consumed intent into a usable one.

Use separate immutable path namespaces:

```text
pending:   <owner-user-id>/<exercise-definition-id>/drafts/<guidance-draft-id>/<asset-id>.<extension>
published: <owner-user-id>/<exercise-definition-id>/revisions/<guidance-revision-id>/<asset-id>.<extension>
```

Never overwrite an existing object. Publication/finalization may copy a verified pending object to
its final revision path only through the Storage API; direct SQL mutation of `storage.objects` is
forbidden. A final object path is immutable. If an implementation-supported API cannot safely copy
and verify the object, stop rather than weakening the path contract.

The implementation must explicitly model that Storage API work and a Postgres transaction are not
one atomic transaction:

1. create the bounded intent;
2. upload processed bytes to the new pending path with `upsert: false`;
3. finalize the draft asset only after database-side validation of the Storage row's owner, path,
   size and MIME plus the submitted digest/dimension contract;
4. begin publication with a short-lived server-created reservation that binds the expected draft
   and media revisions to exact new final paths;
5. copy the verified pending objects to those reserved paths through the authenticated Storage API;
6. finalize publication in one Postgres transaction that locks and revalidates the draft,
   reservation, media set, final Storage rows and expected revisions before committing the guidance
   revision and immutable manifest rows;
7. if a Storage or database step fails, keep the draft unpublished and record a retryable,
   non-secret state; and
8. quarantine/reconcile orphaned pending or copied objects without deleting referenced published
   bytes.

The UI must never claim upload or publication success before the required byte and metadata states
are both verified. Retries must be idempotent and return the original safe result where applicable.
An abandoned reservation must expire safely without making its copied objects publishable.
Postgres cannot decode the private object bytes in this design: the client-generated digest,
dimensions and metadata-stripping result are integrity/reconciliation evidence, not an authorization
claim or server-side malware scan. Document and test this proof boundary, and do not make a security
decision from those client-editable facts. Logs and replay rows must not contain bytes, data URLs,
signed URLs, alt text, full guidance text or raw YouTube input.

### 3. YouTube draft and revision references

Persist at most one optional YouTube reference per guidance draft and per immutable guidance
revision:

```text
provider = youtube
video_id
canonical_watch_url
optional_start_seconds
title_snapshot
thumbnail_url_snapshot
validation_status
validated_at
```

Normalize ordinary watch URLs, `youtu.be` links, Shorts links and valid single-video embed URLs.
Reject non-HTTPS inputs, arbitrary or deceptive hosts, credentials, fragments, playlist-only URLs,
empty/ambiguous IDs, unsupported parameters and values that do not resolve to exactly one valid
video ID. Normalize case and query semantics only where YouTube defines them; video IDs themselves
must not be lowercased.

A new or changed reference may publish only after a user-initiated preview successfully initializes
the official IFrame Player for the normalized video and the stored validation snapshot is current
for that exact draft revision. The implementation must document how the title and thumbnail
snapshots are obtained from supported current evidence without introducing a secret client API key.
If current official APIs do not support a proposed snapshot mechanism, keep the field nullable and
record the limitation; do not scrape YouTube HTML or invent availability proof.

Availability may change after validation. The contract must represent unavailable, embedding
disabled, network failure and player error states without corrupting or silently deleting history.
The dashboard must provide a canonical external YouTube fallback.

### 4. Narrow operations

Implement narrowly scoped, versioned operations consistent with existing 003A conventions for:

- creating/returning an upload intent;
- finalizing a verified pending upload;
- editing alt text, ordering and cover choice on an owned draft;
- removing/quarantining an unreferenced owned draft asset;
- saving, validating and removing an owned draft YouTube reference;
- reading owned draft and immutable revision media manifests;
- beginning and finalizing publication of a new guidance revision with its immutable media
  manifest; and
- identifying/marking bounded cleanup candidates for later Storage API deletion.

Do not silently change the existing publication RPC contract. Add an explicitly versioned media-aware
operation or a backward-compatible versioned request. Require expected draft/media revision,
idempotency key and correlation ID where the operation mutates state. Stale conflicts return safe
machine-readable current revision evidence. Errors disclose no other user's existence, path, media
metadata, signed URL or guidance content.

Cleanup foundations are authorized, but remote scheduling is not. Cleanup must use an age threshold,
batch bound, deterministic locking and skip-locked semantics where appropriate. It must never delete
published/referenced objects and must perform byte deletion through the Storage API rather than SQL.

## Data API, grants, RLS and Storage policy boundary

Treat these as separate controls:

```text
Data API object access
RLS row authorization
function EXECUTE privilege
Storage object policy
```

For every new table, view, sequence and function:

- enable RLS on every exposed table;
- grant only the minimum object privileges to intended roles;
- revoke unintended `PUBLIC`, `anon` and `authenticated` access;
- revoke default function execution and regrant only the exact safe entry points;
- use `security_invoker` for exposed views;
- set a safe explicit `search_path` for privileged functions;
- qualify referenced relations;
- explicitly document whether `service_role` needs access instead of granting it by habit; and
- test object-level denial separately from row-level denial.

All user paths must use `TO authenticated`, indexed ownership predicates based on
`(select auth.uid())`, the existing active-profile/session enforcement and server-managed
authorization data. Do not use `auth.role()` or editable `user_metadata`. Deny unauthenticated,
anonymous-Auth, cross-user, disabled-profile, must-change-password, global-revocation and
selected-session-revocation paths.

Create the local private bucket through supported Supabase local configuration/seed mechanisms:

```text
bucket: exercise-media
public: false
file size limit: 5 MB
allowed MIME: image/jpeg, image/png, image/webp
```

Do not create custom tables or functions in the managed `storage` schema. Do not directly insert,
update or delete Storage object metadata. Migration-managed policies on `storage.objects` must:

- restrict every operation to bucket `exercise-media`;
- use the current `owner_id` column, not deprecated `owner`;
- require the first path segment to equal `(select auth.uid())::text`;
- verify all path identifiers against an active owned upload intent or immutable permitted manifest,
  not trust path text alone;
- allow INSERT only for an active unused pending intent and an exact new path;
- provide no client UPDATE/upsert path;
- allow SELECT only to a user authorized for the referenced owned draft/revision;
- allow deletion only for owned, unreferenced pending/quarantined assets in an authorized cleanup
  path; and
- deny anonymous, cross-user, enumeration and published-object deletion.

Private object delivery must use authenticated downloads or short-lived signed URLs. Signed URLs
must be audience-bounded where supported, short-lived, regenerated on demand, excluded from durable
state, logs, errors, analytics, browser storage and tests. No public URL or public bucket is allowed.
Service-role credentials may exist only in trusted server/operator tooling and never in Flutter
assets, Dart defines, browser bundles, logs, CI artifacts or committed files.

## Image processing contract

The dashboard must process each selected file before upload:

1. reject empty input and enforce the 5 MB input ceiling before decode;
2. perform bounded header/preflight checks for format, frame count and dimensions before allocating
   a full decoded raster where the selected codec permits;
3. reject corrupt, unsupported, multi-frame, implausibly large-dimension or decompression-bomb
   inputs with a stable failure rather than exhausting the browser;
4. run expensive decode/resize/encode work outside the interactive UI path where supported, with a
   documented time/memory failure boundary and cancellation;
5. decode and verify that declared MIME, decoded format and extension agree;
6. correct orientation;
7. strip EXIF, GPS, comments, profiles and other unnecessary metadata;
8. resize so the longest edge is at most 2400 pixels while preserving aspect ratio;
9. reject a result whose shortest edge is below 320 pixels;
10. re-encode deterministically to JPEG, PNG or static WebP;
11. reject a processed result above 5 MB;
12. compute SHA-256 over the exact uploaded bytes; and
13. discard source bytes and object URLs as soon as they are no longer needed.

Reject SVG, GIF, APNG, animated WebP, HEIC/HEIF as a final asset, HTML/script-capable payloads,
polyglots detectable by the chosen decoder, MIME mismatches and direct video uploads. Do not trust
filename or browser-reported MIME alone. Add fixtures that prove EXIF/GPS and animation are removed
or rejected. Document unavoidable codec limitations and do not claim byte-level metadata stripping
without a test that inspects the final bytes.

## Dashboard scope

Extend the 003A guidance editor and detail/history surfaces with:

- zero-to-six image selection, preprocessing, upload progress, cancellation and bounded retry;
- keyboard-accessible reorder, cover choice, required alt text, removal and replacement;
- explicit object and metadata lifecycle states;
- optional YouTube paste, normalization, start time, user-initiated preview, replace/remove and
  canonical external fallback;
- immutable published media history and a clear duplicate-as-draft path;
- a responsive mobile-shaped guidance preview for authoring review only; and
- safe conflict recovery using the server's current draft/media revision.

Render explicit loading, empty, processing, uploading, retrying, cancelled, offline, permission,
stale-conflict, unavailable-video, failed, read-only and published-immutable states. A failed byte,
metadata or publication operation must not render as complete.

Do not persist private image bytes, blob/object URLs, signed URLs or YouTube player state in
IndexedDB. Draft recovery may retain only the safe media IDs and non-sensitive authoring fields
required to reconcile with the server. Revoke browser object URLs and dispose IFrame listeners/view
registrations when their widget lifecycle ends.

The YouTube player must:

- load only after an explicit preview action, so merely opening the editor does not contact YouTube;
- use the official HTTPS IFrame Player API with a correct `origin` when JavaScript control is used;
- use `autoplay=0` and never background play;
- preserve standard controls, branding, advertisements and player behavior;
- use responsive 16:9 layout and never fall below YouTube's documented minimum viewport;
- never download, proxy, cache, extract, re-host or reward video/audio; and
- show an understandable error plus `Open in YouTube` fallback.

Meet existing dashboard accessibility and quality boundaries: keyboard completion, logical focus,
visible focus, semantic labels and errors, alt-text guidance, 200% text scaling, reduced motion,
responsive compact/medium/expanded layouts and no pointer-only reorder interaction.

## Backup, restore and reconciliation foundations

Database backups do not contain Storage object bytes. Add bounded manifest/reconciliation support
that can enumerate expected private objects with object path, owner, immutable revision, MIME, size
and SHA-256 without exposing signed URLs or credentials. Tests must detect:

- metadata with a missing object;
- an unexpected unreferenced object;
- size/MIME/hash mismatch;
- an expired pending upload; and
- an object incorrectly referenced across owners.

This task does not deploy remote backup jobs or claim a completed production restore drill. Full
production backup/export/restore automation remains in `TASK-IMP-008`.

## Explicit non-goals

Do not implement:

- Android image rendering, download/cache or YouTube WebView playback (`TASK-IMP-005B`);
- routine authoring, review or publication (`TASK-IMP-003C`);
- schedules, swaps, grants, workout logging, offline SQLite sync, scoring, rank, wallet or progress;
- YouTube search, Data API keys, playlist support or non-YouTube providers;
- direct video upload, transcoding, proxying, downloading, caching or re-hosting;
- arbitrary external image URLs, a public bucket or public media URLs;
- remote Supabase/Vercel provisioning, Edge Function deployment, domains, credentials or paid
  services;
- production backup scheduling or a production restore drill; or
- changes to the accepted Android-first/Vercel deployment model.

## Acceptance criteria

The task is acceptable only when all of the following are true:

1. the local `exercise-media` bucket is private, constrained to accepted MIME/size limits and
   reproducibly created from repository configuration;
2. zero-to-six processed images and at most one YouTube reference can be authored for an owned
   guidance draft;
3. published media manifests are immutable and linked only to a newly published guidance revision;
4. old 003A content/revision hashes remain unchanged and SQL/Dart media and bundle hashes have exact
   parity;
5. file format, dimensions, metadata stripping, animation rejection, size, hash, alt text, order and
   cover rules are enforced and tested;
6. Storage policies and database RLS deny anonymous, cross-user, revoked, disabled and
   password-change-required access;
7. clients cannot overwrite paths, bypass upload intents, mutate Storage metadata directly or delete
   published objects;
8. the staged Storage/Postgres failure contract is implemented, retryable and never misrepresented
   as atomic;
9. YouTube input is normalized to one safe video ID and must pass user-initiated official-player
   preview before new-reference publication;
10. the dashboard handles upload, conflict, offline and player failures without leaking private URLs
    or claiming false success;
11. no secret/service credential or private media URL enters source, bundles, logs, IndexedDB, CI
    artifacts or committed fixtures;
12. reconciliation identifies missing, orphaned and mismatched media without deleting referenced
    history;
13. no Android playback, routine behavior or remote infrastructure enters the diff; and
14. all applicable final-head CI gates pass.

## Required verification

### Dependencies and generated source

- exact root dependency restore and single-lockfile verification;
- exact pin and license/source review;
- generated-code freshness;
- formatting and `git diff --check`;
- strict analysis with no warnings; and
- no dependency override or unapproved transitive capability.

### Database and Storage

- local Supabase clean start/reset and migration replay from zero;
- migration rollback/replay evidence where repository tooling supports it;
- database lint;
- local bucket existence, private flag, MIME and 5 MB limit verification;
- pgTAP constraint, hash parity, function privilege, object-grant and RLS allow/deny tests;
- anonymous, anonymous-Auth, owner, cross-user, disabled-profile, must-change-password, global
  revocation and selected-session-revocation tests;
- upload-intent expiry, reuse, wrong path, wrong owner, wrong bucket, wrong MIME and oversize denial;
- Storage INSERT/SELECT/DELETE policy tests and explicit UPDATE/upsert denial;
- published update/delete and cross-revision mutation denial;
- stale expected-revision and idempotent replay tests;
- publish race/concurrency and six-image/cover/order constraints;
- partial Storage/DB failure, retry, quarantine and reconciliation tests; and
- missing/orphaned/mismatched-object manifest tests.

### Domain, data and image processing

- unit tests for supported and deceptive YouTube URL forms, canonical URL and start-time bounds;
- canonical SQL/Dart empty/image/YouTube manifest and bundle-hash vectors;
- image fixtures for JPEG, PNG, static WebP, EXIF/GPS, orientation, corrupt/empty input, MIME/extension
  mismatch, oversize dimensions/bytes, undersize dimensions, GIF, APNG and animated WebP;
- proof that final encoded bytes contain no accepted-test EXIF/GPS payload;
- upload/finalize/retry/cancel and safe error mapping tests;
- safe signed-URL expiry/non-persistence tests; and
- regression tests for the unchanged 003A content/revision hash contract.

### Dashboard and browser

- unit and widget tests for selection, processing, progress, cancellation, retry, order, cover, alt
  text, replacement, removal, read-only history and duplicate-as-draft;
- widget tests for every required loading/error/offline/conflict/permission state;
- keyboard, focus, semantics, 200% text-scale, reduced-motion and responsive layout tests;
- Chrome tests for `HtmlElementView` lifecycle, explicit-load privacy boundary, normalized IFrame
  parameters, player success/error, external fallback, object-URL revocation and refresh recovery;
- IndexedDB inspection proving no bytes, object URLs, signed URLs or player state are persisted;
- dashboard release Web build; and
- built-bundle scan for service keys, tokens, secrets, private URLs and unsafe player configuration.

### Final regression and CI

- all affected shared/domain/data/dashboard tests;
- existing 003A exercise/guidance regressions;
- Android compile/contract regression only if shared contracts used by Android changed;
- no API 24 profile run unless the final diff changes mobile runtime or performance-sensitive shared
  code;
- path-sensitive CI routing tests so database/dashboard/shared paths cannot bypass their required
  jobs;
- one complete path-appropriate final-head CI run after implementation, tests and documentation are
  finalized;
- complete diff, changed-path, secret/personal-data and client-bundle review; and
- clean-tree verification after commit.

During development, run targeted affected tests. Do not repeatedly run full repository suites after
small edits. For a clear hosted-runner flake, follow the repository's bounded single-job rerun policy
without weakening a functional or security threshold.

## Required documentation updates

After successful implementation, update only canonical documents whose facts changed:

- mark `TASK-IMP-003B` complete and record exact implementation/check evidence in this packet;
- update `ACTIVE_CONTEXT.md`, `CODEBASE_MAP.md`, `ROADMAP.md` and `HANDOFF.md` for the implemented
  media modules and exact next action;
- update `ARCHITECTURE.md` only if an already-accepted media fact needs its concrete implementation
  recorded;
- append a material result to the active audit volume without rewriting history; and
- keep `TASK-IMP-003C` non-executable until its 003B merge prerequisite is met and reverified.

Do not churn product documents or accepted ADRs merely to restate unchanged decisions. If execution
requires changing an accepted architecture, public contract, persistence ownership, authorization,
external integration or deployment decision, stop and create a superseding ADR before code.

## Completion report

Return:

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task: TASK-IMP-003B
Branch:
Commits:
Pull request:
Merge commit:

003A prerequisite verification:
Dependency and compatibility result:
Private bucket result:
Image processing result:
Storage lifecycle/compensation result:
Database/RLS/grants result:
Manifest/hash result:
YouTube normalization/preview result:
Dashboard result:
Backup/reconciliation foundation:
Security review findings:
Accessibility findings:

Tests:
Database/pgTAP:
Chrome:
Web release build:
Android regression:
CI:

Files changed:
Runtime files changed:
Dependency/lockfile changes:
Supabase files changed:
Remote Supabase changed:
Secrets/private-URL review:
Diff review:

Residual risks:
Exact next action:
```

A `COMPLETE` verdict requires all applicable behavior, persistence, security, accessibility,
verification, documentation, Git, push, pull-request and final-head CI gates to pass. Use `PARTIAL`
only for a genuine remaining required gate, and `FAIL` for an unreconciled boundary violation or
failed required verification.
