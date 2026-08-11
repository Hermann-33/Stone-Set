# ADR-0008: Materialize an editable guidance draft from an immutable revision

## Status

Accepted

- Date: 2026-08-11
- Type: Public contract, persistence workflow, and exercise-media authoring
- Supersedes: None
- Preserves: ADR-0002, ADR-0006, owner isolation, immutable published guidance/media, and direct owner publication

## Context

Published guidance and media are immutable. The dashboard can duplicate a published revision only
when an editable guidance draft already exists, because the existing 003A and 003B duplicate RPCs
require a draft ID and expected draft/media revisions. Production currently has 25 active owned
exercises with published text guidance and no editable drafts. The stale detail placeholder must be
replaced with real media actions, but those actions cannot safely manufacture draft state in the
client or mutate published rows.

## Decision criteria

- preserve immutable published guidance, manifests, and Storage objects;
- create at most one active owner-scoped draft per exercise;
- make text and media draft creation atomic and idempotent;
- use existing guidance/media tables, hashes, Storage paths, RLS, and publication operations;
- provide safe optimistic-concurrency evidence;
- expose no new cross-user read or write path.

## Options considered

### Mutate published media in place

Rejected because it destroys immutable history and can change pinned workout guidance.

### Have the dashboard synthesize rows with direct table writes

Rejected because draft creation spans text, media state, ownership, provenance, idempotency, and
privilege boundaries that must remain server authoritative.

### Reuse an unrelated exercise update to manufacture a draft

Rejected because identity updates do not own this lifecycle and published identity is locked.

### Add one versioned atomic server operation

Accepted. A narrowly granted operation creates a draft from an owned immutable guidance revision,
copies structured text and published media metadata, reuses immutable published object references,
and returns stable draft/media revision evidence.

## Decision

Add `public.create_guidance_media_draft_from_revision_v1` with an owner-scoped private
implementation. It accepts exercise ID, source guidance revision ID, expected exercise revision,
and idempotency key. It validates the active authenticated owner, locks the exercise, rejects
archived/cross-user sources, and atomically creates:

- one `guidance_drafts` row with source revision provenance and structured content;
- the corresponding `guidance_media_draft_states` row;
- draft media/image metadata copied from the immutable source manifest; and
- at most one copied YouTube reference with its existing validation evidence.

Published Storage bytes are not copied or overwritten. Draft metadata may reference immutable
source objects through the existing source-asset relationship; ordinary draft cleanup cannot delete
the published source. If a draft already exists, the operation returns a stable safe conflict or an
idempotent replay rather than replacing it. All mutation responses retain operation, replay,
correlation, source, draft, exercise and media revision evidence.

## Consequences

- Exercise detail can truthfully offer Add/Manage media for the current production dataset.
- One additive migration and matching domain/data bindings are required.
- The existing media editor, upload, preview, validation and publication pipeline remains the only
  authoring implementation.
- No routine prescription, materialized week or workout snapshot is rewritten.

## Security, privacy, data, and operational impact

The public wrapper receives EXECUTE only for `authenticated`; `PUBLIC`, `anon` and `service_role`
remain revoked unless a separately documented operator need exists. The private function uses a
hardened empty `search_path`, server-managed identity, ownership checks, active-profile/session
enforcement, bounded source rows, deterministic idempotency and safe conflict detail. RLS/object
grants remain separate controls. No signed URL, object path, secret or user ID enters durable client
state or logs.

## Scope boundaries

This decision does not authorize a second media model, public buckets, object overwrite, routine
usage UX, prescription changes, weekly/swap changes, YouTube search, arbitrary web-image ingestion,
or unapproved production media content.

## Rollback or supersession rule

The versioned public operation may be revoked and the dashboard action removed without changing
published history. Any replacement that changes ownership, object copying, sharing, or publication
semantics must supersede this ADR.

## Activation evidence

`TASK-IMP-011` implements and verifies this decision. Production deployment is permitted only from
its committed migration after final-head CI and merge.
