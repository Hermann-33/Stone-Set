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
| `TASK-IMP-013A.md` | Merged; physical device acceptance residual | Offline-first cached mobile shell, synchronization and Home rank refresh |
| `TASK-IMP-014.md` | Partial; implementation candidate green, merge/deployment pending | Make successfully published guidance/media reach newly started workouts and expose publication blockers clearly |

## Current implementation boundary

`TASK-IMP-014` is the active bounded repair under accepted `ADR-0011`.

Production read-only evidence shows:

- one guidance draft with unpublished text relative to its published revision;
- two current draft YouTube references at `preview_required`;
- no immutable guidance revision above version 1.

The implementation now exposes that precise publication blocker instead of a generic media failure and makes the latest finalized owner guidance/media bundle eligible when a **new** workout-session exercise snapshot is inserted. Immutable routine/version/week history and already-started workout snapshots remain unchanged.

Exact green implementation candidate:

```text
c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
Foundation CI 31628667732 (#382), attempt 2 — PASS
```

Final documentation changes create a new exact head and must pass Foundation CI before PR #48 is marked ready/merged. After merge, exact-main CI, production migration verification and Vercel deployment verification remain required.

`TASK-IMP-013A` merged through PR #47 at main commit `ec8fb9324ecadc90654e011f242e523e8f517ca0`; exact-main Foundation CI #372 passed. Its real-device airplane-mode acceptance remains independent of TASK-IMP-014.

ADR-0010 and ADR-0003 continue to preserve the online authoritative workout-start boundary. Offline-created workout sessions/reconciliation remain deferred to a separate TASK-IMP-013B decision.

## Independent residual boundaries

- `TASK-IMP-011`: engineering/deployment is complete; only explicitly approved exercise image/YouTube content remains. Never fabricate or scrape selections.
- `TASK-IMP-012`: permanent signer and private Firebase distribution are proven; independent key backup and one-time phone migration/install confirmation remain external gates.
- Historical Firebase releases are not fresh evidence for later mobile changes.

The original independent-review portion of `TASK-IMP-003C` is superseded. Current routine publication is direct by the owner after validation.
