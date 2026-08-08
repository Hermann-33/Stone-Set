import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

enum DashboardSearchFixtureState { results, loading, empty, error }

enum DashboardSearchGroup {
  routines('Routines'),
  routineVersions('Routine versions'),
  exercises('Exercises'),
  guidanceRevisions('Guidance revisions'),
  reviews('Reviews'),
  activity('Activity');

  const DashboardSearchGroup(this.label);

  final String label;
}

@immutable
class DashboardSearchResult {
  const DashboardSearchResult({
    required this.id,
    required this.group,
    required this.title,
    required this.subtitle,
    required this.location,
  });

  final String id;
  final DashboardSearchGroup group;
  final String title;
  final String subtitle;
  final String location;
}

abstract final class DashboardSearchFixtures {
  static const unavailableFeatureResults = <DashboardSearchResult>[
    DashboardSearchResult(
      id: 'routine-strength-foundation',
      group: DashboardSearchGroup.routines,
      title: 'Strength foundation',
      subtitle: 'Preview fixture — routine authoring is unavailable',
      location: '/routines/strength-foundation',
    ),
    DashboardSearchResult(
      id: 'routine-version-v3',
      group: DashboardSearchGroup.routineVersions,
      title: 'Strength foundation · Version 3',
      subtitle: 'Preview fixture — routine versions are unavailable',
      location: '/routines/strength-foundation/versions/3',
    ),
    DashboardSearchResult(
      id: 'review-lower-body',
      group: DashboardSearchGroup.reviews,
      title: 'Lower-body volume adjustment',
      subtitle: 'Preview fixture — routine review is unavailable',
      location: '/reviews/lower-body-volume',
    ),
    DashboardSearchResult(
      id: 'activity-publication',
      group: DashboardSearchGroup.activity,
      title: 'Guidance publication recorded',
      subtitle: 'Preview fixture — activity persistence is unavailable',
      location: '/activity/guidance-publication',
    ),
  ];

  static const results = <DashboardSearchResult>[
    DashboardSearchResult(
      id: 'routine-strength-foundation',
      group: DashboardSearchGroup.routines,
      title: 'Strength foundation',
      subtitle: 'Draft routine · Fixture',
      location: '/routines/strength-foundation',
    ),
    DashboardSearchResult(
      id: 'routine-version-v3',
      group: DashboardSearchGroup.routineVersions,
      title: 'Strength foundation · Version 3',
      subtitle: 'Published fixture version',
      location: '/routines/strength-foundation/versions/3',
    ),
    DashboardSearchResult(
      id: 'exercise-incline-press',
      group: DashboardSearchGroup.exercises,
      title: 'Incline dumbbell press',
      subtitle: 'Chest · Dumbbells · Fixture',
      location: '/exercises/incline-dumbbell-press',
    ),
    DashboardSearchResult(
      id: 'guidance-squat-v2',
      group: DashboardSearchGroup.guidanceRevisions,
      title: 'High-bar squat guidance · Version 2',
      subtitle: 'Published fixture revision',
      location: '/exercises/high-bar-squat/guidance/2',
    ),
    DashboardSearchResult(
      id: 'review-lower-body',
      group: DashboardSearchGroup.reviews,
      title: 'Lower-body volume adjustment',
      subtitle: 'Review requested · Fixture',
      location: '/reviews/lower-body-volume',
    ),
    DashboardSearchResult(
      id: 'activity-publication',
      group: DashboardSearchGroup.activity,
      title: 'Guidance publication recorded',
      subtitle: 'Recent activity · Fixture',
      location: '/activity/guidance-publication',
    ),
  ];
}

class DashboardSearchDialog extends StatefulWidget {
  const DashboardSearchDialog({
    required this.onOpenLocation,
    this.fixtureState = DashboardSearchFixtureState.results,
    this.initialQuery = '',
    this.results = DashboardSearchFixtures.results,
    super.key,
  });

  final ValueChanged<String> onOpenLocation;
  final DashboardSearchFixtureState fixtureState;
  final String initialQuery;
  final List<DashboardSearchResult> results;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onOpenLocation,
    DashboardSearchFixtureState fixtureState = DashboardSearchFixtureState.results,
    String initialQuery = '',
    List<DashboardSearchResult> results = DashboardSearchFixtures.results,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => DashboardSearchDialog(
      onOpenLocation: onOpenLocation,
      fixtureState: fixtureState,
      initialQuery: initialQuery,
      results: results,
    ),
  );

  @override
  State<DashboardSearchDialog> createState() => _DashboardSearchDialogState();
}

class _DashboardSearchDialogState extends State<DashboardSearchDialog> {
  late final TextEditingController _queryController;
  late final FocusNode _searchFocus;
  int _selectedIndex = 0;

  List<DashboardSearchResult> get _filteredResults {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.results;
    return widget.results
        .where(
          (result) =>
              result.title.toLowerCase().contains(query) ||
              result.subtitle.toLowerCase().contains(query) ||
              result.group.label.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _searchFocus = FocusNode(debugLabel: 'dashboard-search-input');
  }

  @override
  void dispose() {
    _queryController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _moveSelection(int delta) {
    final results = _filteredResults;
    if (results.isEmpty) return;
    setState(() => _selectedIndex = (_selectedIndex + delta) % results.length);
    if (_selectedIndex < 0) setState(() => _selectedIndex += results.length);
  }

  void _openSelected() {
    final results = _filteredResults;
    if (results.isEmpty) return;
    _open(results[_selectedIndex.clamp(0, results.length - 1)]);
  }

  void _open(DashboardSearchResult result) {
    Navigator.of(context).pop();
    widget.onOpenLocation(result.location);
  }

  void _queryChanged(String _) {
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;
    final countLabel = '${results.length} ${results.length == 1 ? 'result' : 'results'}';
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _moveSelection(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _moveSelection(-1),
        const SingleActivator(LogicalKeyboardKey.enter): _openSelected,
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: AlertDialog(
        key: const Key('dashboard-search-dialog'),
        titlePadding: const EdgeInsets.fromLTRB(
          StoneSetSpacing.xl,
          StoneSetSpacing.xl,
          StoneSetSpacing.xl,
          StoneSetSpacing.sm,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          StoneSetSpacing.xl,
          0,
          StoneSetSpacing.xl,
          StoneSetSpacing.xl,
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                child: Text('Search Stone Set', style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            IconButton(
              key: const Key('dashboard-search-close'),
              tooltip: 'Close search',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 680,
          height: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: const Key('dashboard-global-search-input'),
                controller: _queryController,
                focusNode: _searchFocus,
                autofocus: true,
                onChanged: _queryChanged,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Search routines, exercises, reviews, and activity',
                  hintText: 'Type to filter fixture results',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: StoneSetSpacing.sm),
              Semantics(
                liveRegion: true,
                label: countLabel,
                child: ExcludeSemantics(
                  child: Text(countLabel, style: StoneSetTextStyles.of(context).caption),
                ),
              ),
              const SizedBox(height: StoneSetSpacing.xs),
              Expanded(child: _buildBody(context, results)),
              const SizedBox(height: StoneSetSpacing.sm),
              Text(
                'Use ↑ and ↓ to move, Enter to open, and Esc to close.',
                style: StoneSetTextStyles.of(context).caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<DashboardSearchResult> results) {
    if (widget.fixtureState == DashboardSearchFixtureState.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: 'Search results loading',
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (widget.fixtureState == DashboardSearchFixtureState.error) {
      return const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.error,
        title: 'Search is unavailable',
        message: 'This fixture could not load. Close search and try again.',
      );
    }
    if (widget.fixtureState == DashboardSearchFixtureState.empty || results.isEmpty) {
      return const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.empty,
        title: 'No matching fixtures',
        message: 'Try a routine, exercise, review, or activity term.',
      );
    }

    final grouped = <DashboardSearchGroup, List<DashboardSearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.group, () => <DashboardSearchResult>[]).add(result);
    }
    return ListView(
      key: const Key('dashboard-search-results'),
      children: <Widget>[
        for (final group in DashboardSearchGroup.values)
          if (grouped[group] case final groupResults?) ...<Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: StoneSetSpacing.sm,
                top: StoneSetSpacing.sm,
                bottom: StoneSetSpacing.xxs,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  '${group.label} · ${groupResults.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            for (final result in groupResults)
              Builder(
                builder: (context) {
                  final index = results.indexOf(result);
                  return StoneSetSelectableRow(
                    key: Key('dashboard-search-result-${result.id}'),
                    title: result.title,
                    subtitle: result.subtitle,
                    selected: index == _selectedIndex,
                    onSelect: () => _open(result),
                    leading: Icon(_iconFor(result.group)),
                    trailing: const Icon(Icons.arrow_forward),
                  );
                },
              ),
          ],
      ],
    );
  }

  IconData _iconFor(DashboardSearchGroup group) => switch (group) {
    DashboardSearchGroup.routines => Icons.view_week_outlined,
    DashboardSearchGroup.routineVersions => Icons.history_outlined,
    DashboardSearchGroup.exercises => Icons.fitness_center_outlined,
    DashboardSearchGroup.guidanceRevisions => Icons.menu_book_outlined,
    DashboardSearchGroup.reviews => Icons.rate_review_outlined,
    DashboardSearchGroup.activity => Icons.timeline_outlined,
  };
}
