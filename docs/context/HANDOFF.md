# Stone Set Latest Handoff

Updated: 2026-08-10

## State

All Stone Set product implementation phases are complete and merged through TASK-IMP-007 plus TASK-IMP-005B.

```text
TASK-IMP-001  COMPLETE
TASK-IMP-002A COMPLETE
TASK-IMP-002B COMPLETE
TASK-IMP-002C COMPLETE
TASK-IMP-003A COMPLETE
TASK-IMP-003B COMPLETE
TASK-IMP-003C COMPLETE
TASK-IMP-004  COMPLETE
TASK-IMP-005A COMPLETE
TASK-IMP-005B COMPLETE + MERGED (PR #24)
TASK-IMP-006  COMPLETE
TASK-IMP-007  COMPLETE
TASK-IMP-008  ACTIVE — FINAL RELEASE PR #25
```

## TASK-IMP-008 handoff

```text
branch: codex/task-imp-008-minimal-release
PR:     #25
packet: docs/tasks/TASK-IMP-008.md
runbook: docs/release/PRIVATE_RELEASE.md
```

008 is intentionally a release/configuration phase rather than another feature implementation phase.

Already completed outside Codex:

- merged the clean 005B prerequisite;
- deployed the accepted migration chain through TASK-IMP-007 to the single hosted Supabase project;
- applied the 008 release migration;
- created the private exercise-media bucket;
- activated production compatibility;
- committed production public Flutter configuration;
- added a Windows private-release build script;
- added a narrow GitHub production artifact workflow;
- wrote provisioning, Vercel, smoke, rollback and backup instructions.

## Accepted private-release shortcuts

- one Supabase project;
- one Vercel project;
- no staging;
- no Play Store/AAB;
- private APK sideload;
- existing debug signer, with same-machine repeat builds preferred;
- synthetic `@stone-set.invalid` Auth aliases and no email delivery;
- no enterprise observability/security certification;
- no formal restore/RPO/RTO programme.

## Remaining work

1. Let exact-head Foundation CI and Private Release build finish.
2. Fix only concrete release-specific failures.
3. Mark PR #25 ready and merge when green.
4. Operator performs the one-time two-user provisioning and Vercel link/deploy steps from the runbook.
5. Run the short smoke path once.

## Codex rule

Do not send 008 to Codex unless a local production APK/Web build or signing failure is demonstrated and cannot be reproduced/fixed through connected tooling. If Codex is required, give it only that named failure and require `reproduce -> narrow fix -> targeted build -> push -> stop`.
