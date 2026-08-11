# Stone Set Latest Handoff

Updated: 2026-08-11

## State

Stone Set product implementation and the minimal private release are complete. The dashboard is hosted on Vercel and connected to the single hosted Supabase project.

Production dashboard:

```text
https://stone-set.vercel.app
```

Supabase project:

```text
pjltldrernuvrjsnmcqg
```

## Routine workflow override

The original TASK-IMP-003C review/approval lifecycle has been intentionally removed from the active product.

Current supported flow:

```text
Create/Edit
   ↓
Save
   ↓
Validate
   ↓
Publish immediately
```

There is no active routine submission queue, independent reviewer, approval/rejection step, reviewer capability requirement, or second-user dependency.

Publication is owner-scoped, revision-checked, idempotent, server-validated, and writes an immutable `routine_versions` snapshot. The active RPC is `public.publish_routine_draft_v1`.

Legacy submission/review tables and generated review routes may remain temporarily as inert history/backward-compatibility structures. The old review RPCs are revoked from authenticated application users and must not be used by new code.

## Production routine state

Hermann's `Stone Set Hypertrophy Baseline` has already been published under the direct-publication model:

- routine draft: `8083603a-6252-4885-9043-d3567e09598c`;
- published version: `2dbec440-d4eb-428d-8acc-8c7c9f4f01d5`;
- version number: `1`;
- effective training-week Monday: `2026-08-10`.

## Release topology

- one Supabase project;
- one Vercel project;
- no staging;
- private Android APK sideload;
- existing private-release GitHub workflow;
- never expose service-role/database secrets.

## Engineering rule

Do not reintroduce routine review/approval workflow unless the product owner explicitly asks for it. Future routine work should preserve direct owner publication and immutable published versions.

## Latest completed task and exact next action

`TASK-IMP-010 — Authoritative consistency multiplier` is complete. PR #34 merged final head
`3e1e98e522d2d160e1bafca33b8a66bf0e468cb6` at
`12eb3010064a7e17774c5c1ce564badce8b68d6a`. Foundation CI `31460872770` and Private Release
`31460872700` passed.

The exact committed migration was applied through Supabase migration history to production project
`pjltldrernuvrjsnmcqg` and recorded as `20260811054519_authoritative_consistency_multiplier`.
Credential-safe verification confirms one account at authoritative `1.00`, a numeric `1.00` in the
progress payload, the exact accepted-value constraint/default, enabled RLS, authenticated select-only
access, anonymous denial and no client execution grant on the private payload helper. No credentials
or user IDs were printed or committed.

```text
Execute TASK-IMP-012
branch: codex/task-imp-012-private-android-distribution
packet: docs/tasks/TASK-IMP-012.md
```

TASK-PD-024 accepts ADR-0009. The next task creates permanent Android release signing, trusted
mobile-path distribution after successful CI, and a private Firebase tester channel. It changes no
product behavior or Supabase. Firebase/gcloud authentication and GitHub release secrets were absent
at approval; complete engineering first and stop only at an exact authorization/backup/tester gate.

The approved packet reuses the existing TASK-IMP-003B media stack and implements ADR-0008 because
all 25 active production exercises have immutable text guidance but no editable draft or media.
Preserve direct owner routine publication, routine usage, prescriptions, scoring, history and all
weekly/swap behavior. Populate only approved media; never scrape images or invent YouTube choices.

PR #38 merged exact final head `d23605261d4b3288ac20c16a476f84e250082d06` as
`2abf3493f0d0169f090ecf082fcf273d12fe1af5`; all required CI passed. Production records the merged
migration as `20260811064653_create_guidance_media_draft_from_revision_v1`, and a rollback smoke
proved the authenticated owner flow without retaining data. Inventory is still 25 text-only
exercises with no draft or media.

Independent TASK-IMP-011 content action: provide or approve the cover image file and explicitly selected YouTube URL for
each exercise in the TASK-IMP-011 checklist. Then use Dashboard → Exercises → exercise → Add media,
review/validate, and publish. Never fabricate or scrape selections.
