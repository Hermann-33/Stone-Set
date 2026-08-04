# Stone Set

Stone Set is a personal muscle-growth training application currently in product discovery.

The repository is the authoritative source for product decisions, architecture, implementation state, verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Product direction: evidence-informed workout execution, progression tracking, and consistency-based rank progression for the repository owner
- Foundational product logic: complete for the accepted workout, rank, RR, consistency, penalty, scheduling, and monthly free-swap systems
- Accepted workout baseline: limited-equipment five-session hypertrophy routine with a strict 60-minute session cap
- Accepted rank baseline: 20 ranks from Bronze I to Adonis, with lifetime XP, Rank Rating, PR rewards, missed-session penalties, and resettable consistency multipliers
- Current rank configuration: `rank-v5`
- Adonis threshold: `5,500 RR`
- Rank pacing target: approximately ten months under the defined synthetic decent-consistency profile
- Accepted scheduling baseline: any two unlocked days may be swapped inside the active week, with two confirmed swaps per week
- Free-swap system: two non-expiring, uncapped credits granted monthly; one credit waives one swap's `5 RR` cost
- Technology stack: not yet selected
- Architecture: not yet selected
- Implementation: not started
- Repository governance: established
- Active phase: product discovery

## Start here

1. For a new conversation, use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md).
2. Read [`AGENTS.md`](AGENTS.md).
3. Read the mandatory files under [`docs/context/`](docs/context/).
4. Read the accepted product baselines:
   - [`docs/product/HYPERTROPHY_ROUTINE.md`](docs/product/HYPERTROPHY_ROUTINE.md)
   - [`docs/product/RANK_SYSTEM.md`](docs/product/RANK_SYSTEM.md)
   - [`docs/product/WEEKLY_SCHEDULING.md`](docs/product/WEEKLY_SCHEDULING.md)
5. Read relevant accepted decisions under [`docs/decisions/`](docs/decisions/).

Foundational product logic is complete, but implementation must not begin until the end-to-end application workflow, platform constraints, accepted architecture decisions, and first bounded implementation task have been documented.
