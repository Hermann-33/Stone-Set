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
| `TASK-IMP-001.md` | Approved, not executed | Create the Flutter, Dart workspace, local Supabase, quality, and CI foundation without product features |