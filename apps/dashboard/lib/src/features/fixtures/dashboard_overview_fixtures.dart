import 'package:flutter/foundation.dart';

/// Deterministic presentation states used by the bounded dashboard preview.
enum DashboardOverviewFixtureScenario {
  populated,
  firstRun,
  noAttention,
  validationBlockers,
  reviewRequested,
  rejectedRoutine,
  mediaFailure,
  saveConflict,
  upcomingActivation,
  recentActivity,
  loading,
  staleOffline,
  error,
}

enum DashboardAttentionTone { information, warning, destructive }

enum DashboardDraftKind { routine, exerciseGuidance }

enum DashboardDraftSaveState { saved, saving, offline, syncing, conflict, failed, readOnly }

enum DashboardValidationState { ready, warning, blocked, notRun }

enum DashboardActivityKind { guidance, routine, review, media, account }

enum DashboardSystemCondition { available, readOnly, offline, degraded }

@immutable
class DashboardFixtureAction {
  const DashboardFixtureAction({
    required this.label,
    required this.location,
    this.enabled = true,
    this.disabledReason,
  }) : assert(enabled || disabledReason != null);

  final String label;
  final String location;
  final bool enabled;
  final String? disabledReason;
}

@immutable
class DashboardAttentionItem {
  const DashboardAttentionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.context,
    required this.tone,
    required this.action,
  });

  final String id;
  final String title;
  final String description;
  final String context;
  final DashboardAttentionTone tone;
  final DashboardFixtureAction action;
}

@immutable
class DashboardResumeDraft {
  const DashboardResumeDraft({
    required this.id,
    required this.title,
    required this.kind,
    required this.lastEditedLabel,
    required this.saveState,
    required this.validationState,
    required this.action,
  });

  final String id;
  final String title;
  final DashboardDraftKind kind;
  final String lastEditedLabel;
  final DashboardDraftSaveState saveState;
  final DashboardValidationState validationState;
  final DashboardFixtureAction action;
}

@immutable
class DashboardPublishedRoutineSummary {
  const DashboardPublishedRoutineSummary({
    required this.name,
    required this.versionLabel,
    required this.scheduleLabel,
    required this.workoutDays,
    required this.action,
    this.upcomingName,
    this.upcomingActivationLabel,
  });

  final String name;
  final String versionLabel;
  final String scheduleLabel;
  final int workoutDays;
  final DashboardFixtureAction action;
  final String? upcomingName;
  final String? upcomingActivationLabel;
}

@immutable
class DashboardActivityItem {
  const DashboardActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.kind,
    required this.action,
  });

  final String id;
  final String title;
  final String description;
  final String timeLabel;
  final DashboardActivityKind kind;
  final DashboardFixtureAction action;
}

@immutable
class DashboardSystemStatus {
  const DashboardSystemStatus({
    required this.condition,
    required this.label,
    required this.description,
    required this.lastCheckedLabel,
  });

  final DashboardSystemCondition condition;
  final String label;
  final String description;
  final String lastCheckedLabel;
}

@immutable
class DashboardOverviewFixture {
  const DashboardOverviewFixture({
    required this.heading,
    required this.supportingText,
    required this.attentionItems,
    required this.resumeDrafts,
    required this.publishedRoutine,
    required this.activity,
    required this.systemStatus,
    required this.quickActions,
    this.previewNotice = 'Fixture preview — examples below are not saved product records.',
    this.isFirstRun = false,
  });

  final String heading;
  final String supportingText;
  final List<DashboardAttentionItem> attentionItems;
  final List<DashboardResumeDraft> resumeDrafts;
  final DashboardPublishedRoutineSummary? publishedRoutine;
  final List<DashboardActivityItem> activity;
  final DashboardSystemStatus systemStatus;
  final List<DashboardFixtureAction> quickActions;
  final String previewNotice;
  final bool isFirstRun;
}

final class DashboardFixtureException implements Exception {
  const DashboardFixtureException(this.message);

  final String message;

  @override
  String toString() => message;
}
