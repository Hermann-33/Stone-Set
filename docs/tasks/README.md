# Stone Set Task Packets

This directory stores bounded execution packets approved for Codex or another implementation agent.

A task packet is authoritative only when its status/repository state match current facts, prerequisites are satisfied, and it does not conflict with accepted ADRs/product specifications. Agents must inspect the repository before implementation.

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
| `TASK-IMP-013A.md` | Merged; physical device acceptance residual | Offline-first cached mobile shell, synchronization and Home rank refresh |
| `TASK-IMP-014.md` | Partial only at owner content-publication boundary; engineering/deployment complete | Guidance/media publication feedback and latest-published activation for newly started workouts |
| `TASK-IMP-015.md` | In progress | Week day detail, long-press swaps, and reliable workout start |

## Active bounded task

`TASK-IMP-015` implements accepted ADR-0012. It adds read-only browsing for every materialized day, moves swap selection to deliberate long presses, and permits today's authoritative workout start to replace only synchronized stale local workout state. Pending local edits remain protected.

## Independent residual boundaries

- `TASK-IMP-011`: only explicitly approved exercise image/YouTube content remains; never fabricate or scrape selections.
- `TASK-IMP-012`: independent signing-key backup and phone confirmation remain external gates.
- `TASK-IMP-013A`: real-device airplane-mode acceptance remains external.
- `TASK-IMP-014`: owner preview validation/publication remains external.
- ADR-0003 continues to require online authoritative workout start; offline-created sessions remain a separate future decision.

The original independent-review portion of TASK-IMP-003C is superseded. Current routine publication remains direct by the owner after validation.
