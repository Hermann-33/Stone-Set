# Stone Set Task Packets

This directory stores bounded execution packets approved for Codex or another implementation agent.

A task packet is authoritative only when:

- its status and repository state match the current execution phase;
- its prerequisites are satisfied in `ACTIVE_CONTEXT.md` and `ROADMAP.md`;
- it does not conflict with accepted ADRs or product specifications;
- the requested branch and repository state still match the packet.

Agents must inspect the repository before implementation. A packet is not permission to ignore newer repository facts.

Every packet must include the fields required by `AGENTS.md` and `docs/context/WORKFLOW.md`.

## Current packets

| Task | Status | Purpose |
|---|---|---|
| `TASK-IMP-001.md` | Complete and merged | Flutter/Dart workspace, local Supabase, quality and CI foundation |
| `TASK-IMP-002A.md` | Complete and merged | Private identity, login, sessions, profiles, ownership and operator tooling |
| `TASK-IMP-002B.md` | Complete and merged | Shared UI plus fixture-only Android shell, Home and rank hero |
| `TASK-IMP-002C.md` | Complete and merged | Fixture-only responsive dashboard shell, Overview and productivity primitives |
| `TASK-IMP-003A.md` | Complete and merged through PR #14 | Exercise library, structured guidance, immutable publication and browser recovery |
| `TASK-IMP-003B.md` | Complete and merged | Private exercise media and YouTube |
| `TASK-IMP-003C.md` | Complete and merged; review lifecycle later retired | Routine authoring and direct owner publication |
| `TASK-IMP-004.md` | Complete and merged | Weekly plans, swaps and free-swap credits |
| `TASK-IMP-005A.md` | Complete and merged | Workout logger, SQLite autosave and offline sync |
| `TASK-IMP-005B.md` | Complete and merged | Workout guidance and media playback |
| `TASK-IMP-006.md` | Complete and merged | Authoritative RR, XP, rank, wallet and Progress |
| `TASK-IMP-007.md` | Complete and merged | Progression, substitutions, protection and corrections |
| `TASK-IMP-008.md` | Complete and merged | Minimal private release |
| `TASK-IMP-009.md` | Complete and merged through PR #31 | Android visual system and motion modernization |
| `TASK-IMP-010.md` | Complete; code merged through PR #34 and production migration verified | Authoritative base consistency multiplier and Home fixture-leak correction |
| `TASK-IMP-011.md` | Partial; engineering/deployment complete, approved content pending | Exercise media authoring completion and approved production population |
| `TASK-IMP-012.md` | Partial; distribution complete, backup/phone confirmation pending | Permanent Android signing and private automatic Firebase distribution |
| `TASK-IMP-013A.md` | Partial; runtime candidate green, merge/distribution/device acceptance pending | Owner-scoped cached mobile shell, synchronization coordinator, offline Home/Week/Progress and live Home rank refresh |

## Current implementation boundary

`TASK-IMP-013A` is the active bounded mobile slice under accepted `ADR-0010`. Its runtime implementation is present on `agent/task-imp-013a-offline-cache`; exact candidate head `51474a6e8d3157bfbdad9c9e1de3fa57a468a758` passed Foundation CI run `31621647343` (#365), including mobile tests, Android release APK and Android API 24 profile.

The task is not yet complete because canonical documentation must be committed and pass exact-head CI, PR #47 must merge, exact-main CI and a fresh Private Android Distribution run must be verified, and the physical airplane-mode acceptance flow requires a real Android device.

ADR-0010 preserves ADR-0003's online authoritative workout-start boundary. Offline-created workout sessions/reconciliation remain deferred to a separate TASK-IMP-013B decision and are not authorized by 013A.

## Independent residual boundaries

- `TASK-IMP-011`: engineering/deployment is complete; only explicitly approved exercise image/YouTube content remains. Never fabricate or scrape selections.
- `TASK-IMP-012`: permanent signer and private Firebase distribution are proven; independent key backup and one-time phone migration/install confirmation remain external gates.
- The historical TASK-IMP-012 release `0.1.0 / 1000062 / 5j1j4rhquebu0` is not fresh evidence for TASK-IMP-013A.

The original independent-review portion of `TASK-IMP-003C` is superseded. Current routine publication is direct by the owner after validation.
