import 'dart:collection';

enum ExerciseArchiveFilter { active, archived, all }

enum ExercisePublicationFilter { all, draftOnly, published }

enum ExerciseLibrarySort {
  updatedDescending,
  nameAscending,
  nameDescending,
  publicationState,
}

enum ExerciseMuscleRole { primary, secondary }

final class Muscle {
  const Muscle({
    required this.id,
    required this.key,
    required this.displayName,
    required this.displayOrder,
  });

  final String id;
  final String key;
  final String displayName;
  final int displayOrder;
}

final class ExerciseMuscleSelection {
  const ExerciseMuscleSelection({required this.muscle, required this.role, required this.position});

  final Muscle muscle;
  final ExerciseMuscleRole role;
  final int position;
}

final class GuidanceContentV1 {
  GuidanceContentV1({
    required this.shortExplanation,
    Iterable<String> setupSteps = const <String>[],
    Iterable<String> executionSteps = const <String>[],
    Iterable<String> techniqueCues = const <String>[],
    Iterable<String> commonMistakes = const <String>[],
    Iterable<String> safetyNotes = const <String>[],
  }) : setupSteps = UnmodifiableListView<String>(List<String>.of(setupSteps)),
       executionSteps = UnmodifiableListView<String>(List<String>.of(executionSteps)),
       techniqueCues = UnmodifiableListView<String>(List<String>.of(techniqueCues)),
       commonMistakes = UnmodifiableListView<String>(List<String>.of(commonMistakes)),
       safetyNotes = UnmodifiableListView<String>(List<String>.of(safetyNotes));

  static const int schemaVersion = 1;

  final String shortExplanation;
  final List<String> setupSteps;
  final List<String> executionSteps;
  final List<String> techniqueCues;
  final List<String> commonMistakes;
  final List<String> safetyNotes;
}

final class ExerciseDefinition {
  ExerciseDefinition({
    required this.id,
    required this.userId,
    required this.canonicalName,
    required this.normalizedName,
    required this.variantKey,
    required Iterable<String> equipmentKeys,
    required Iterable<ExerciseMuscleSelection> muscles,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.clonedFromExerciseId,
    this.latestGuidanceRevisionId,
    this.latestGuidanceVersionNumber,
    this.currentDraft,
  }) : equipmentKeys = UnmodifiableListView<String>(List<String>.of(equipmentKeys)),
       muscles = UnmodifiableListView<ExerciseMuscleSelection>(
         List<ExerciseMuscleSelection>.of(muscles),
       );

  final String id;
  final String userId;
  final String canonicalName;
  final String normalizedName;
  final String? variantKey;
  final List<String> equipmentKeys;
  final List<ExerciseMuscleSelection> muscles;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final String? clonedFromExerciseId;
  final String? latestGuidanceRevisionId;
  final int? latestGuidanceVersionNumber;
  final GuidanceDraft? currentDraft;

  bool get isArchived => archivedAt != null;
  bool get hasPublishedGuidance => latestGuidanceRevisionId != null;

  List<ExerciseMuscleSelection> get primaryMuscles => List<ExerciseMuscleSelection>.unmodifiable(
    muscles.where((selection) => selection.role == ExerciseMuscleRole.primary),
  );

  List<ExerciseMuscleSelection> get secondaryMuscles => List<ExerciseMuscleSelection>.unmodifiable(
    muscles.where((selection) => selection.role == ExerciseMuscleRole.secondary),
  );
}

final class GuidanceDraft {
  const GuidanceDraft({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.content,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.baseGuidanceRevisionId,
  });

  final String id;
  final String exerciseId;
  final String userId;
  final String? baseGuidanceRevisionId;
  final GuidanceContentV1 content;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class GuidanceRevision {
  GuidanceRevision({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.versionNumber,
    required this.content,
    required this.canonicalName,
    required this.variantKey,
    required Iterable<String> equipmentKeys,
    required Iterable<ExerciseMuscleSelection> muscles,
    required this.contentHash,
    required this.revisionHash,
    required this.publishedAt,
    this.supersedesRevisionId,
  }) : equipmentKeys = UnmodifiableListView<String>(List<String>.of(equipmentKeys)),
       muscles = UnmodifiableListView<ExerciseMuscleSelection>(
         List<ExerciseMuscleSelection>.of(muscles),
       );

  final String id;
  final String exerciseId;
  final String userId;
  final int versionNumber;
  final GuidanceContentV1 content;
  final String canonicalName;
  final String? variantKey;
  final List<String> equipmentKeys;
  final List<ExerciseMuscleSelection> muscles;
  final String contentHash;
  final String revisionHash;
  final String? supersedesRevisionId;
  final DateTime publishedAt;
}

final class ExerciseLibraryQuery {
  ExerciseLibraryQuery({
    this.search,
    this.archive = ExerciseArchiveFilter.active,
    this.publication = ExercisePublicationFilter.all,
    Iterable<String> equipmentKeys = const <String>[],
    Iterable<String> muscleKeys = const <String>[],
    this.sort = ExerciseLibrarySort.updatedDescending,
    this.page = 1,
    this.pageSize = 25,
  }) : equipmentKeys = UnmodifiableListView<String>(List<String>.of(equipmentKeys)),
       muscleKeys = UnmodifiableListView<String>(List<String>.of(muscleKeys)) {
    if (page < 1 || pageSize < 1 || pageSize > 100) {
      throw ArgumentError('Exercise library page bounds are invalid.');
    }
  }

  final String? search;
  final ExerciseArchiveFilter archive;
  final ExercisePublicationFilter publication;
  final List<String> equipmentKeys;
  final List<String> muscleKeys;
  final ExerciseLibrarySort sort;
  final int page;
  final int pageSize;
}

final class ExerciseLibraryPage {
  ExerciseLibraryPage({
    required Iterable<ExerciseLibraryItem> items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  }) : items = UnmodifiableListView<ExerciseLibraryItem>(List<ExerciseLibraryItem>.of(items));

  final List<ExerciseLibraryItem> items;
  final int page;
  final int pageSize;
  final int totalCount;

  bool get hasNextPage => page * pageSize < totalCount;
}

final class ExerciseLibraryItem {
  ExerciseLibraryItem({
    required this.id,
    required this.userId,
    required this.canonicalName,
    required this.normalizedName,
    required this.variantKey,
    required Iterable<String> equipmentKeys,
    required Iterable<String> primaryMuscleIds,
    required Iterable<String> secondaryMuscleIds,
    required this.published,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.clonedFromExerciseId,
    this.draftId,
    this.draftRevision,
    this.latestGuidanceRevisionId,
    this.latestGuidanceVersionNumber,
  }) : equipmentKeys = UnmodifiableListView<String>(List<String>.of(equipmentKeys)),
       primaryMuscleIds = UnmodifiableListView<String>(List<String>.of(primaryMuscleIds)),
       secondaryMuscleIds = UnmodifiableListView<String>(List<String>.of(secondaryMuscleIds));

  final String id;
  final String userId;
  final String canonicalName;
  final String normalizedName;
  final String? variantKey;
  final List<String> equipmentKeys;
  final List<String> primaryMuscleIds;
  final List<String> secondaryMuscleIds;
  final bool published;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final String? clonedFromExerciseId;
  final String? draftId;
  final int? draftRevision;
  final String? latestGuidanceRevisionId;
  final int? latestGuidanceVersionNumber;

  bool get isArchived => archivedAt != null;
}

final class GuidanceRevisionPage {
  GuidanceRevisionPage({
    required Iterable<GuidanceRevision> items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  }) : items = UnmodifiableListView<GuidanceRevision>(List<GuidanceRevision>.of(items));

  final List<GuidanceRevision> items;
  final int page;
  final int pageSize;
  final int totalCount;
}
