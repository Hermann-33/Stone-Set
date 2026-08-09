# Stone Set Latest Handoff

Updated: 2026-08-08

## Current task result

```text
Task ID: TASK-IMP-003B
Title: Implement private exercise media and YouTube guidance
Verdict: IMPLEMENTED — AWAITING FINAL-HEAD CI AND MERGE
Task branch: codex/task-imp-003b-exercise-media-youtube
Final head: pending
Implementation pull request: pending
Merge commit: pending
Final CI: pending
Next packet: TASK-IMP-003C — APPROVED; BLOCKED BY TASK-IMP-003B MERGE
```

The local candidate implements private media persistence/authorization, deterministic manifests,
staged Storage/Postgres publication and compensation, dashboard image processing/upload/layout and
user-initiated official YouTube preview. Exact restore, repository checks, generation freshness,
7 domain tests, 12 data tests, 23 focused dashboard tests, full fatal-info analysis, 8 CI
classifier tests, Web release build and privileged bundle scan pass. Chrome reproduced the
established bounded Windows hang; Docker/Podman and the Android SDK are absent, so browser,
Supabase reset/pgTAP/lint/Storage runtime, Android release and exact final-head path-sensitive CI
remain required CI gates.

## Implemented boundary

- local-only Supabase identity/session schema, signup denial, RLS/RPC and operator tooling;
- mobile and dashboard provisioned login, password change, session restoration/revalidation,
  revocation/disablement handling and logout/private-state clearing;
- shared semantic themes, responsive primitives and rank presentation;
- fixture-only Android Home/Week/Progress/Profile shell and rank hero;
- adaptive Web shell, Overview and productivity layers;
- fixed muscle taxonomy and owner-scoped exercise definitions;
- structured guidance drafts, optimistic concurrency and immutable published revisions/hashes;
- explicit Data API grants, RLS and narrow idempotent RPC authority;
- typed adaptive dashboard library/editor/history routes;
- private user-partitioned, non-authoritative IndexedDB recovery with conflict handling;
- private local `exercise-media` bucket configuration and intent-bound object policies;
- immutable media manifests, SQL/Dart hashes and staged publication reservations;
- dashboard image preprocessing/upload/order/cover/alt text and YouTube preview/fallback;
- bounded cleanup and database/Storage reconciliation foundations.

This candidate is not merged. Routines/review, Android media playback, schedules, workouts,
rank/wallet authority and remote infrastructure do not exist yet.

## Security boundaries

- public/anonymous signup remains disabled;
- active identity/session/password-change enforcement remains required for product mutations;
- object access, RLS and function execution are separately granted and tested;
- published revisions are immutable and user text remains structured plain text;
- browser recovery is private, user-scoped and non-authoritative;
- Storage API and Postgres publication are staged with retry/quarantine evidence, not falsely atomic;
- client image evidence is not represented as server-side byte or malware attestation;
- YouTube loads only after explicit preview and availability may change after validation;
- service-role/management credentials never enter clients, bundles, logs or Git.

## Exact next action

```text
Finalize TASK-IMP-003B
branch: codex/task-imp-003b-exercise-media-youtube
packet: docs/tasks/TASK-IMP-003B.md
action: finalize, push, open the draft PR, pass final-head CI, and merge
```

`TASK-IMP-003C` is approved as the later packet in Planning Group A but remains blocked and
non-executable until `TASK-IMP-003B` completes and merges. Do not execute later packets.
