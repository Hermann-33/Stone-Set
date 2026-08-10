# Stone Set Task Packets

This directory stores bounded execution packets approved for Codex or another implementation agent.

A task packet is authoritative only when:

- its status is `APPROVED`;
- its prerequisites are satisfied in `ACTIVE_CONTEXT.md` and `ROADMAP.md`;
- it does not conflict with accepted ADRs or product specifications;
- the requested branch and repository state still match the packet.

Agents must still inspect the repository before implementation. A packet is not permission to ignore newer repository facts.

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
| `TASK-IMP-009.md` | Approved; not executed | Android visual system and motion modernization |

Planning packets record the evidence used to create or promote implementation packets. The latest
merged planning result is `TASK-PD-020`; `TASK-PD-021` records the subsequent explicit approval.
Higher current authority records all planned work through `TASK-IMP-008` as complete. The original
independent-review portion of `TASK-IMP-003C` is superseded; current routine publication is direct
by the owner after validation.

`TASK-PD-020` records the merged current-state mobile visual audit and bounded packet. `TASK-PD-021`
records the product owner's explicit approval. `TASK-IMP-009` is the next executable packet after
the approval change reaches accepted `main`. Direct owner routine publication remains authoritative.
