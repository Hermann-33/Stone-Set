import 'dart:async';

import 'dashboard_overview_fixtures.dart';

/// Stateless, deterministic fixture source. It never reads browser or remote data.
final class DashboardOverviewFixtureService {
  const DashboardOverviewFixtureService();

  Future<DashboardOverviewFixture> load(DashboardOverviewFixtureScenario scenario) {
    if (scenario == DashboardOverviewFixtureScenario.loading) {
      return Completer<DashboardOverviewFixture>().future;
    }
    if (scenario == DashboardOverviewFixtureScenario.error) {
      return Future<DashboardOverviewFixture>.error(
        const DashboardFixtureException(
          'The preview could not be prepared. No saved work was changed.',
        ),
      );
    }
    return Future<DashboardOverviewFixture>.value(_fixtureFor(scenario));
  }
}

DashboardOverviewFixture _fixtureFor(DashboardOverviewFixtureScenario scenario) {
  final attention = switch (scenario) {
    DashboardOverviewFixtureScenario.firstRun => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'setup-profile',
        title: 'Finish workspace setup',
        description: 'Confirm appearance and training preferences before authoring.',
        context: 'First-run checklist',
        tone: DashboardAttentionTone.information,
        action: DashboardFixtureAction(label: 'Review settings', location: '/settings'),
      ),
    ],
    DashboardOverviewFixtureScenario.noAttention ||
    DashboardOverviewFixtureScenario.recentActivity => const <DashboardAttentionItem>[],
    DashboardOverviewFixtureScenario.validationBlockers => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'validation-blockers',
        title: 'Routine has 3 validation blockers',
        description: 'Upper / Lower Foundation needs exercise and duration corrections.',
        context: 'Draft routine',
        tone: DashboardAttentionTone.warning,
        action: DashboardFixtureAction(label: 'Resolve blockers', location: '/routines'),
      ),
    ],
    DashboardOverviewFixtureScenario.reviewRequested => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'review-requested',
        title: 'Review requested',
        description: 'A routine submission is ready for an independent review.',
        context: 'Review queue',
        tone: DashboardAttentionTone.information,
        action: DashboardFixtureAction(label: 'Open review queue', location: '/reviews'),
      ),
    ],
    DashboardOverviewFixtureScenario.rejectedRoutine => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'rejected-routine',
        title: 'Routine returned with feedback',
        description: 'Adjust the lower-body volume and submit a new immutable version.',
        context: 'Upper / Lower Foundation',
        tone: DashboardAttentionTone.destructive,
        action: DashboardFixtureAction(label: 'Read feedback', location: '/routines'),
      ),
    ],
    DashboardOverviewFixtureScenario.mediaFailure => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'media-failure',
        title: 'Media processing failed',
        description: 'The example incline-press image needs attention.',
        context: 'Exercise guidance',
        tone: DashboardAttentionTone.destructive,
        action: DashboardFixtureAction(label: 'Review exercise', location: '/exercises'),
      ),
    ],
    DashboardOverviewFixtureScenario.saveConflict => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'save-conflict',
        title: 'Draft conflict requires comparison',
        description: 'A newer example revision exists. Compare before continuing.',
        context: 'Push A guidance',
        tone: DashboardAttentionTone.warning,
        action: DashboardFixtureAction(label: 'Compare versions', location: '/exercises'),
      ),
    ],
    DashboardOverviewFixtureScenario.upcomingActivation => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'upcoming-activation',
        title: 'Routine activation is approaching',
        description: 'Upper / Lower Foundation v4 is staged for the next unlocked week.',
        context: 'Upcoming activation',
        tone: DashboardAttentionTone.information,
        action: DashboardFixtureAction(label: 'Review schedule', location: '/routines'),
      ),
    ],
    DashboardOverviewFixtureScenario.staleOffline => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'offline-preview',
        title: 'Preview is offline',
        description:
            'Showing deterministic fixture content. Authoritative actions are unavailable.',
        context: 'Connection state',
        tone: DashboardAttentionTone.warning,
        action: DashboardFixtureAction(
          label: 'Retry',
          location: '/',
          enabled: false,
          disabledReason: 'Network retry is unavailable in this fixture-only packet.',
        ),
      ),
    ],
    DashboardOverviewFixtureScenario.populated => const <DashboardAttentionItem>[
      DashboardAttentionItem(
        id: 'validation-blockers',
        title: 'Routine has 3 validation blockers',
        description: 'Upper / Lower Foundation needs exercise and duration corrections.',
        context: 'Draft routine',
        tone: DashboardAttentionTone.warning,
        action: DashboardFixtureAction(label: 'Resolve blockers', location: '/routines'),
      ),
      DashboardAttentionItem(
        id: 'review-requested',
        title: 'Review requested',
        description: 'A routine submission is ready for an independent review.',
        context: 'Review queue',
        tone: DashboardAttentionTone.information,
        action: DashboardFixtureAction(label: 'Open review queue', location: '/reviews'),
      ),
    ],
    DashboardOverviewFixtureScenario.loading ||
    DashboardOverviewFixtureScenario.error => const <DashboardAttentionItem>[],
  };

  final drafts = scenario == DashboardOverviewFixtureScenario.firstRun
      ? const <DashboardResumeDraft>[]
      : <DashboardResumeDraft>[
          DashboardResumeDraft(
            id: 'routine-draft',
            title: 'Upper / Lower Foundation',
            kind: DashboardDraftKind.routine,
            lastEditedLabel: 'Edited 18 minutes ago',
            saveState: scenario == DashboardOverviewFixtureScenario.staleOffline
                ? DashboardDraftSaveState.offline
                : DashboardDraftSaveState.saved,
            validationState: DashboardValidationState.blocked,
            action: const DashboardFixtureAction(label: 'Resume routine', location: '/routines'),
          ),
          DashboardResumeDraft(
            id: 'guidance-draft',
            title: 'Incline dumbbell press',
            kind: DashboardDraftKind.exerciseGuidance,
            lastEditedLabel: 'Edited yesterday',
            saveState: scenario == DashboardOverviewFixtureScenario.saveConflict
                ? DashboardDraftSaveState.conflict
                : DashboardDraftSaveState.saving,
            validationState: DashboardValidationState.warning,
            action: const DashboardFixtureAction(
              label: 'Resume guidance',
              location: '/exercises',
            ),
          ),
        ];

  final activity = scenario == DashboardOverviewFixtureScenario.firstRun
      ? const <DashboardActivityItem>[]
      : const <DashboardActivityItem>[
          DashboardActivityItem(
            id: 'guidance-published',
            title: 'Guidance published',
            description: 'Romanian deadlift guidance v3',
            timeLabel: 'Today, 09:42',
            kind: DashboardActivityKind.guidance,
            action: DashboardFixtureAction(label: 'Open exercise', location: '/exercises'),
          ),
          DashboardActivityItem(
            id: 'review-completed',
            title: 'Review completed',
            description: 'Upper / Lower Foundation v3 approved',
            timeLabel: 'Yesterday, 18:10',
            kind: DashboardActivityKind.review,
            action: DashboardFixtureAction(label: 'Open activity', location: '/activity'),
          ),
          DashboardActivityItem(
            id: 'routine-activated',
            title: 'Routine activated',
            description: 'Strength Base v2 became active',
            timeLabel: 'Monday, 07:00',
            kind: DashboardActivityKind.routine,
            action: DashboardFixtureAction(label: 'Open routine', location: '/routines'),
          ),
        ];

  final systemStatus = scenario == DashboardOverviewFixtureScenario.staleOffline
      ? const DashboardSystemStatus(
          condition: DashboardSystemCondition.offline,
          label: 'Offline preview',
          description: 'Fixture content is available; online actions are unavailable.',
          lastCheckedLabel: 'Last checked 6 minutes ago',
        )
      : const DashboardSystemStatus(
          condition: DashboardSystemCondition.available,
          label: 'Preview systems ready',
          description: 'Identity is active. Product services are intentionally not connected.',
          lastCheckedLabel: 'Checked just now',
        );

  return DashboardOverviewFixture(
    heading: scenario == DashboardOverviewFixtureScenario.firstRun
        ? 'Set up your training workspace'
        : 'Focus on what needs a decision',
    supportingText: scenario == DashboardOverviewFixtureScenario.firstRun
        ? 'Complete the example checklist, then start building your first routine.'
        : 'Resolve blockers first, then return to recently edited work.',
    attentionItems: List<DashboardAttentionItem>.unmodifiable(attention),
    resumeDrafts: List<DashboardResumeDraft>.unmodifiable(drafts),
    publishedRoutine: scenario == DashboardOverviewFixtureScenario.firstRun
        ? null
        : DashboardPublishedRoutineSummary(
            name: 'Strength Base',
            versionLabel: 'Published v2',
            scheduleLabel: 'Active this week',
            workoutDays: 5,
            upcomingName: scenario == DashboardOverviewFixtureScenario.noAttention
                ? null
                : 'Upper / Lower Foundation v4',
            upcomingActivationLabel: scenario == DashboardOverviewFixtureScenario.noAttention
                ? null
                : 'Activates next Monday',
            action: const DashboardFixtureAction(label: 'View routines', location: '/routines'),
          ),
    activity: List<DashboardActivityItem>.unmodifiable(activity),
    systemStatus: systemStatus,
    quickActions: const <DashboardFixtureAction>[
      DashboardFixtureAction(label: 'Create routine', location: '/routines'),
      DashboardFixtureAction(label: 'Create exercise', location: '/exercises'),
      DashboardFixtureAction(label: 'Open review queue', location: '/reviews'),
      DashboardFixtureAction(label: 'Review settings', location: '/settings'),
    ],
    isFirstRun: scenario == DashboardOverviewFixtureScenario.firstRun,
  );
}
