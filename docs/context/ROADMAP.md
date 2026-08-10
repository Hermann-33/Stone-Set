# Stone Set Roadmap

Updated: 2026-08-10

Stone Set is a private two-user MVP. Product implementation is complete; only the final release PR remains.

## Completed product phases

```text
Phase 0   Product/architecture planning                     COMPLETE
Phase 1   TASK-IMP-001 Foundation                           COMPLETE
Phase 2A  TASK-IMP-002A Identity/sessions                   COMPLETE
Phase 2B  TASK-IMP-002B Shared UI + Android shell/Home      COMPLETE
Phase 2C  TASK-IMP-002C Dashboard shell/Overview            COMPLETE
Phase 3A  TASK-IMP-003A Exercise library/guidance           COMPLETE
Phase 3B  TASK-IMP-003B Private media/YouTube               COMPLETE
Phase 3C  TASK-IMP-003C Routine/review/publication          COMPLETE
Phase 4   TASK-IMP-004 Weekly plans/free/paid swaps         COMPLETE
Phase 5A  TASK-IMP-005A Workout logger/SQLite/sync          COMPLETE
Phase 5B  TASK-IMP-005B Workout guidance/media playback     COMPLETE + MERGED
Phase 6   TASK-IMP-006 RR/XP/rank/wallet/Progress           COMPLETE
Phase 7   TASK-IMP-007 progression/protection/corrections   COMPLETE
```

## Final phase — TASK-IMP-008

```text
Status: ACTIVE — PR #25
Branch: codex/task-imp-008-minimal-release
Mode: FAST TWO-USER PRIVATE RELEASE
```

008 contains only what is required to run the finished product:

- one hosted Supabase backend with the accepted schema;
- private media Storage bucket;
- production bootstrap configuration;
- public Flutter production defines;
- private Android APK build path;
- Flutter Web dashboard build/deploy path;
- exactly two operator-provisioned users;
- short smoke/rollback/backup instructions.

Deliberately excluded:

- staging;
- Play Store/AAB;
- custom release signing infrastructure;
- public signup/email recovery;
- enterprise observability;
- security certification programmes;
- multi-region/HA;
- formal RPO/RTO or restore drills;
- new feature development.

## Completion gate

TASK-IMP-008 is complete when PR #25 passes the existing Foundation CI and narrow Private Release build, then merges. After that, only the one-time operator actions in `docs/release/PRIVATE_RELEASE.md` remain to put the two users onto the finished application.

No TASK-IMP-009 is planned.
