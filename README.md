# Stone Set

Stone Set is a private two-user muscle-growth training system with independently managed routines and a shared normalized rank economy.

The repository is the authoritative source for product decisions, architecture, implementation state, verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Phase 0 planning: `COMPLETE`
- Phase 1 foundation: `READY — NOT STARTED`
- Application implementation: none
- External infrastructure: none
- Approved first implementation packet: [`docs/tasks/TASK-IMP-001.md`](docs/tasks/TASK-IMP-001.md)

## Accepted product baseline

- user-owned immutable routine versions;
- four through six workout days and at least one programmed rest day;
- cross-user routine review before reward activation;
- `rank-v6` and `schedule-v3`;
- equal maximum weekly RR opportunity;
- 20 ranks ending at Adonis at `5,500 RR`;
- 5/10/15-week consistency multiplier ladder;
- two weekly swaps and two bankable monthly free-swap credits;
- no RR or XP for unscheduled extra volume.

## Accepted architecture

- Flutter Android mobile app;
- separate Flutter Web dashboard;
- shared Dart packages using a native Pub workspace;
- Supabase Auth and Postgres with RLS;
- SQLite local workout drafts;
- online session start and server-authoritative finalization;
- Vercel static dashboard hosting;
- separate local, staging, and production Supabase environments;
- Supabase Pro production daily backups plus encrypted logical exports.

Nothing above is implemented yet.

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. For a new conversation, use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md).
3. Read the mandatory files under [`docs/context/`](docs/context/).
4. Read the accepted product baselines under [`docs/product/`](docs/product/).
5. Read accepted ADRs under [`docs/decisions/`](docs/decisions/).
6. For implementation, read the exact approved packet under [`docs/tasks/`](docs/tasks/).

## Exact next action

Execute `TASK-IMP-001 — Create Flutter and Supabase project foundation` on branch:

```text
codex/task-imp-001-foundation
```

The task creates scaffolding and quality gates only. It does not implement authentication, routines, workouts, rank behavior, product schema, or deployment.
