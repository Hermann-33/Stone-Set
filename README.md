# Stone Set

Stone Set is a personal muscle-growth training application currently in product discovery.

The repository is the authoritative source for product decisions, architecture, implementation state, verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Product direction: evidence-informed workout execution, progression tracking, and consistency-based rank progression for the repository owner
- Accepted workout baseline: limited-equipment five-session hypertrophy routine with a strict 60-minute session cap
- Accepted rank baseline: 20 ranks from Bronze I to Adonis, with lifetime XP, Rank Rating, PR rewards, missed-session penalties, and resettable consistency multipliers
- Accepted scheduling baseline: any two unlocked days may be swapped inside the active week, with two swaps per week and a `-5 RR` cost per confirmed swap
- Technology stack: not yet selected
- Architecture: not yet selected
- Implementation: not started
- Repository governance: established
- Active phase: product discovery

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. Read the mandatory files under [`docs/context/`](docs/context/).
3. Read the accepted product baselines:
   - [`docs/product/HYPERTROPHY_ROUTINE.md`](docs/product/HYPERTROPHY_ROUTINE.md)
   - [`docs/product/RANK_SYSTEM.md`](docs/product/RANK_SYSTEM.md)
   - [`docs/product/WEEKLY_SCHEDULING.md`](docs/product/WEEKLY_SCHEDULING.md)
4. Read relevant accepted decisions under [`docs/decisions/`](docs/decisions/).

No implementation should begin until the product workflow, initial boundaries, accepted architecture decisions, and first bounded implementation task have been documented.