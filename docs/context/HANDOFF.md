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
