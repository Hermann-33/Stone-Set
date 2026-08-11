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

`TASK-IMP-009 — Android visual system and motion modernization` is complete and merged through
pull request #31 at `e59303d5acd4dbfe6706822b100913c531dc9297`, from final head
`f3f41bd95294e73b00c10f42f24ea43c4571411c`. It modernizes presentation, accessibility and
event-driven motion only; all product, backend, persistence and authority semantics remain
protected by its packet.

Local evidence is green for 19 shared-UI tests, 51 complete non-golden mobile tests, generation
freshness, formatting, fatal-info analysis and repository checks. Linux golden workflow
`31431636004` passed and its reviewed 12-image artifact supplies the accepted candidate baselines.
Final-head Foundation CI run `31433590244` passed Flutter/Dart, mobile and dashboard golden
comparisons, Android release, Web release, repository checks and the unchanged API 24 profile.
Private Release run `31433590270` passed and produced the Android release artifacts. The Windows
host still has no Android SDK, so those Android build and performance results are CI-authoritative.

```text
Execute TASK-IMP-010
branch: codex/task-imp-010-consistency-multiplier
packet: docs/tasks/TASK-IMP-010.md
```

TASK-IMP-010 is approved to expose a server-owned base `1.00×` multiplier and remove the
authenticated Home fixture leak. It must not infer historical perfect weeks, change weekly/swap
behavior, or begin exercise-media completion. TASK-IMP-011 remains non-executable until 010 is
complete and merged and a separate packet is approved.
