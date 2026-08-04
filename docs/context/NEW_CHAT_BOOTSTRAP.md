# Stone Set New-Chat Bootstrap Prompt

Updated: 2026-08-04
Status: `ACTIVE REUSABLE PROMPT`
Task: `TASK-WF-002`

## Purpose

Use this prompt at the beginning of a new Stone Set conversation. It directs the agent to load the authoritative repository context before planning, advising, or changing files.

The prompt deliberately avoids duplicating detailed product rules. Those rules may evolve, and the repository must remain authoritative.

## Copy-paste prompt

```text
You are continuing work on Stone Set.

Repository: Hermann-33/Stone-Set
Default branch: main

The GitHub repository is the authoritative source. Do not rely on chat memory, previous-conversation summaries, or assumptions when repository files can be inspected. Any factual conflict must be resolved in favor of the repository according to its documented authority order.

Before answering the Stone Set task in this chat, do all of the following:

1. Access the repository and read `AGENTS.md` completely.
2. Read the mandatory context files in this exact order:
   - `docs/context/ACTIVE_CONTEXT.md`
   - `docs/context/PROJECT_BRIEF.md`
   - `docs/context/ARCHITECTURE.md`
   - `docs/context/CODEBASE_MAP.md`
   - `docs/context/ROADMAP.md`
   - `docs/context/WORKFLOW.md`
   - `docs/context/HANDOFF.md`
3. Read the accepted product baselines:
   - `docs/product/HYPERTROPHY_ROUTINE.md`
   - `docs/product/RANK_SYSTEM.md`
   - `docs/product/WEEKLY_SCHEDULING.md`
4. Read `docs/decisions/README.md` and every accepted ADR, if any exist.
5. Inspect the current branch, latest relevant commits, and the files directly affected by the requested task.
6. Treat repository facts as current only after verifying them. Do not silently preserve stale values from this prompt or earlier chats.

After loading context, give a concise context report containing:

- current project phase and maturity;
- what is implemented versus only documented;
- current accepted product/configuration baselines;
- the exact next action recorded in the repository;
- any conflict between my request and accepted boundaries.

Operating rules:

- Follow `AGENTS.md` and `docs/context/WORKFLOW.md`.
- Before changing files, provide the required pre-change summary with a task ID, scope, exclusions, protected behavior, and verification plan.
- Do not select a technology stack, scaffold code, invent architecture, or represent planned behavior as implemented unless the repository and current task explicitly authorize it.
- Do not silently modify the accepted workout routine, rank/RR system, consistency rules, penalties, scheduling rules, or free-swap rules.
- When a requested change conflicts with repository context, identify the exact conflict before editing.
- Keep documentation synchronized, inspect the final diff, commit with the task ID, and report the branch, commit, checks, risks, verdict, and exact next action.
- Use `COMPLETE`, `PARTIAL`, or `FAIL` according to the repository completion gate.

At the time this bootstrap prompt was created, the workout, rank, RR, consistency, missed-session, weekly-swap, and monthly free-swap foundations were documented, but the application workflow, architecture, stack, persistence, and implementation were not yet accepted. Verify the current repository because this status may have changed.

My task for this chat:
[PASTE THE NEW TASK HERE]
```

## Usage rule

Paste the complete block into a new conversation, replace `[PASTE THE NEW TASK HERE]` with the actual task, and require the agent to inspect the repository before proceeding.

If repository access is unavailable, the agent must say so and request the required files rather than reconstructing project state from memory.
