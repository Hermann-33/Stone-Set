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
| `TASK-IMP-002C.md` | Approved, not executed | Fixture-only responsive dashboard shell, Overview and productivity primitives |

Planning packets record the evidence used to create or promote implementation packets. The latest
planning result is `TASK-PD-017`; packets after `TASK-IMP-002C` are not executable yet.
