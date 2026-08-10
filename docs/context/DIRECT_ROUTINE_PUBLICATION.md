# Direct Routine Publication

Updated: 2026-08-11
Status: `AUTHORITATIVE — SUPERSEDES ROUTINE REVIEW/APPROVAL WORKFLOW`

## Purpose

This document is the canonical override for routine publication in Stone Set.

It supersedes the routine submission/review/approval portions of:

- `docs/context/DATABASE_AND_SERVER_PLAN.md` section 8;
- `docs/tasks/TASK-IMP-003C.md` where it describes submission, reviewer decisions, approval, or reviewer-only publication;
- any release or smoke-test instructions that require a second user to review a routine.

Those older documents remain useful as implementation history, but they are not the active product policy for routine publication.

## Active lifecycle

```text
Create/Edit → Save → Validate → Publish
```

A routine owner may publish their own valid saved draft immediately.

There is no active:

- submission step;
- review queue;
- independent reviewer requirement;
- `routine_reviewer` capability requirement;
- approve/reject step;
- second-user dependency for publication.

## Authoritative server operation

The active RPC is:

```text
public.publish_routine_draft_v1(
  routine_draft_id,
  expected_revision,
  idempotency_key
)
```

Publication is:

- authenticated;
- owner-scoped;
- expected-revision checked;
- server-validated;
- idempotent;
- immutable once materialized as a routine version.

A successful call creates an immutable `routine_versions` snapshot and makes that version effective for the current training-week Monday according to the existing scheduling rules.

## Legacy structures

The following may remain in the schema temporarily for history/backward compatibility:

- `routine_submissions`;
- `routine_reviews`;
- legacy submission/review foreign keys;
- generated `/reviews` route classes that are no longer exposed in normal navigation.

They are not part of the active product workflow.

The old submission/review/publication RPC surface is revoked from authenticated application users. New application code must not depend on it.

## Client behavior

Dashboard routine authoring exposes a direct `Publish` action after a valid save.

The UI must not expose normal-user actions for:

- Submit for review;
- Review queue;
- Approve;
- Reject;
- reviewer-only Publish.

Published routine versions remain immutable. To change a published routine, create or duplicate into a new draft, edit it, validate it, and publish a new immutable version.

## Database migration

Implemented by:

```text
supabase/migrations/20260810182949_direct_routine_publication.sql
```

The migration:

- adds `publish_routine_draft_v1`;
- permits legacy approval references on routine versions to be null;
- revokes retired review workflow RPCs from application users;
- preserves legacy history instead of destructively deleting review tables.

## Production state

Hosted Supabase project:

```text
pjltldrernuvrjsnmcqg
```

Hermann's `Stone Set Hypertrophy Baseline` is already published under this model:

- routine draft: `8083603a-6252-4885-9043-d3567e09598c`;
- routine version: `2dbec440-d4eb-428d-8acc-8c7c9f4f01d5`;
- version number: `1`;
- effective training-week Monday: `2026-08-10`.

## Engineering rule

Do not reintroduce routine review/approval unless the product owner explicitly changes the policy again.

When documentation conflicts, this file plus `ACTIVE_CONTEXT.md` and `HANDOFF.md` are authoritative for routine publication.