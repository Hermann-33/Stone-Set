import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../app/dashboard_theme_controller.dart';
import '../../../session/dashboard_session_controller.dart';
import '../../commands/dashboard_productivity_layer.dart';
import '../../exercises/controllers/dashboard_exercise_controllers.dart';
import '../../search/dashboard_search.dart';
import '../models/dashboard_destination.dart';

abstract final class DashboardShellBreakpoints {
  static const compactMax = 720.0;
  static const expandedMin = 1120.0;
}

// Keep the old review branch index alive for generated-router compatibility,
// but remove it from every user-facing navigation surface.
const _visibleBranchIndexes = <int>[0, 1, 2, 4, 5];

List<DashboardDestination> get _visibleDestinations => <DashboardDestination>[
  DashboardDestination.overview,
  DashboardDestination.routines,
  DashboardDestination.exercises,
  DashboardDestination.activity,
  DashboardDestination.settings,
];

int _visibleIndexForBranch(int branchIndex) {
  final index = _visibleBranchIndexes.indexOf(branchIndex);
  return index >= 0 ? index : 1;
}

class DashboardAuthenticatedShell extends ConsumerWidget {
  const DashboardAuthenticatedShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readOnly =
        ref.watch(dashboardSessionControllerProvider).bootstrap?.compatibility.readOnlyMode ??
        false;
    final exerciseSearch = ref.watch(dashboardGlobalExerciseSearchProvider);
    final searchState = exerciseSearch.when(
      data: (_) => DashboardSearchFixtureState.results,
      loading: () => DashboardSearchFixtureState.loading,
      error: (_, _) => DashboardSearchFixtureState.error,
    );
    final searchResults = exerciseSearch.maybeWhen(
      data: (items) => <DashboardSearchResult>[
        for (final item in items) ...<DashboardSearchResult>[
          DashboardSearchResult(
            id: 'exercise-${item.id}',
            group: DashboardSearchGroup.exercises,
            title: item.canonicalName,
            subtitle:
                '${item.equipmentKeys.join(', ')} · ${item.isArchived
                    ? 'Archived'
                    : item.published
                    ? 'Published guidance'
                    : 'Draft guidance'}',
            location: '/exercises/${item.id}',
          ),
          if (item.latestGuidanceRevisionId != null)
            DashboardSearchResult(
              id: 'guidance-${item.latestGuidanceRevisionId}',
              group: DashboardSearchGroup.guidanceRevisions,
              title: '${item.canonicalName} guidance · Version ${item.latestGuidanceVersionNumber}',
              subtitle: 'Immutable published guidance',
              location: '/exercises/${item.id}/guidance/revisions/${item.latestGuidanceRevisionId}',
            ),
        ],
        ...DashboardSearchFixtures.unavailableFeatureResults,
      ],
      orElse: () => const <DashboardSearchResult>[],
    );
    final commands = <DashboardCommand>[
      for (final command in DashboardCommandFixtures.commands.where(
        (command) => command.id != DashboardCommandIds.openReviewQueue,
      ))
        if (readOnly && command.id == DashboardCommandIds.createExercise)
          DashboardCommand(
            id: command.id,
            label: command.label,
            description: command.description,
            icon: command.icon,
            shortcut: command.shortcut,
            enabled: false,
            disabledReason:
                'Exercise changes are unavailable while compatibility mode is read only.',
          )
        else
          command,
    ];
    return DashboardProductivityLayer(
      onOpenLocation: context.go,
      searchFixtureState: searchState,
      searchResults: searchResults,
      commands: commands,
      onCommand: (command) => _handleCommand(
        context,
        ref,
        command,
        searchState: searchState,
        searchResults: searchResults,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final callbacks = _ProductivityCallbacks(
            onSearch: () => unawaited(
              DashboardProductivityLayer.openSearch(
                context,
                onOpenLocation: context.go,
                fixtureState: searchState,
                results: searchResults,
              ),
            ),
            onCommands: () => unawaited(
              DashboardProductivityLayer.openCommandPalette(
                context,
                onCommand: (command) => _handleCommand(
                  context,
                  ref,
                  command,
                  searchState: searchState,
                  searchResults: searchResults,
                ),
                commands: commands,
              ),
            ),
            onShortcutHelp: () => unawaited(DashboardProductivityLayer.openShortcutHelp(context)),
            onCycleTheme: () => _cycleTheme(ref),
            onSignOut: () => _signOut(ref),
          );
          if (constraints.maxWidth < DashboardShellBreakpoints.compactMax) {
            return _CompactDashboardShell(
              navigationShell: navigationShell,
              callbacks: callbacks,
              readOnly: readOnly,
            );
          }
          if (constraints.maxWidth < DashboardShellBreakpoints.expandedMin) {
            return _MediumDashboardShell(
              navigationShell: navigationShell,
              callbacks: callbacks,
              readOnly: readOnly,
            );
          }
          return _ExpandedDashboardShell(
            navigationShell: navigationShell,
            callbacks: callbacks,
            readOnly: readOnly,
          );
        },
      ),
    );
  }

  void _signOut(WidgetRef ref) {
    unawaited(ref.read(dashboardSessionControllerProvider.notifier).signOut());
  }

  void _cycleTheme(WidgetRef ref) {
    final current = ref.read(dashboardThemeModeProvider);
    final next = switch (current) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
    ref.read(dashboardThemeModeProvider.notifier).select(next);
  }

  void _handleCommand(
    BuildContext context,
    WidgetRef ref,
    String command, {
    DashboardSearchFixtureState searchState = DashboardSearchFixtureState.results,
    List<DashboardSearchResult> searchResults = DashboardSearchFixtures.results,
  }) {
    switch (command) {
      case DashboardCommandIds.openRecentDraft:
        context.go('/routines/recent-draft');
      case DashboardCommandIds.openReviewQueue:
        context.go('/routines');
      case DashboardCommandIds.openSearch:
        unawaited(
          DashboardProductivityLayer.openSearch(
            context,
            onOpenLocation: context.go,
            fixtureState: searchState,
            results: searchResults,
          ),
        );
      case DashboardCommandIds.openSettings:
        context.go('/settings');
      case DashboardCommandIds.cycleTheme:
        _cycleTheme(ref);
      case DashboardCommandIds.shortcutHelp:
        unawaited(DashboardProductivityLayer.openShortcutHelp(context));
      case DashboardCommandIds.createRoutine:
        context.go('/routines/new');
      case DashboardCommandIds.createExercise:
        final readOnly =
            ref.read(dashboardSessionControllerProvider).bootstrap?.compatibility.readOnlyMode ??
            false;
        if (!readOnly) context.go('/exercises/new');
    }
  }
}

class _CompactDashboardShell extends StatelessWidget {
  const _CompactDashboardShell({
    required this.navigationShell,
    required this.callbacks,
    required this.readOnly,
  });

  final StatefulNavigationShell navigationShell;
  final _ProductivityCallbacks callbacks;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final destination = DashboardDestination.values[navigationShell.currentIndex];
    return Scaffold(
      key: const Key('dashboard-shell-compact'),
      appBar: AppBar(
        title: Text(destination.label),
        actions: <Widget>[
          _ProductivityActions(callbacks: callbacks, compact: true),
          const SizedBox(width: StoneSetSpacing.xs),
        ],
      ),
      drawer: NavigationDrawer(
        key: const Key('dashboard-primary-drawer'),
        selectedIndex: _visibleIndexForBranch(navigationShell.currentIndex),
        onDestinationSelected: (index) {
          Navigator.of(context).pop();
          _selectDestination(navigationShell, _visibleBranchIndexes[index]);
        },
        children: <Widget>[
          const _NavigationHeader(compact: true),
          for (final destination in _visibleDestinations)
            NavigationDrawerDestination(
              key: Key('dashboard-drawer-${destination.name}'),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Text(destination.label),
            ),
        ],
      ),
      body: _DashboardContent(readOnly: readOnly, child: navigationShell),
    );
  }
}

class _MediumDashboardShell extends StatelessWidget {
  const _MediumDashboardShell({
    required this.navigationShell,
    required this.callbacks,
    required this.readOnly,
  });

  final StatefulNavigationShell navigationShell;
  final _ProductivityCallbacks callbacks;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('dashboard-shell-medium'),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: NavigationRail(
                    key: const Key('dashboard-primary-rail'),
                    selectedIndex: _visibleIndexForBranch(
                      navigationShell.currentIndex,
                    ),
                    onDestinationSelected: (index) => _selectDestination(
                      navigationShell,
                      _visibleBranchIndexes[index],
                    ),
                    labelType: NavigationRailLabelType.selected,
                    leading: const Padding(
                      padding: EdgeInsets.only(bottom: StoneSetSpacing.sm),
                      child: _StoneSetMark(),
                    ),
                    destinations: <NavigationRailDestination>[
                      for (final destination in _visibleDestinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: StoneSetSpacing.sm),
                  child: _SignOutButton(
                    onPressed: callbacks.onSignOut,
                    compact: true,
                  ),
                ),
              ],
            ),
            VerticalDivider(
              width: 1,
              color: StoneSetSemanticColors.of(context).outline,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  _DesktopTopBar(
                    destination: DashboardDestination.values[navigationShell.currentIndex],
                    callbacks: callbacks,
                  ),
                  Expanded(
                    child: _DashboardContent(
                      readOnly: readOnly,
                      child: navigationShell,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedDashboardShell extends StatelessWidget {
  const _ExpandedDashboardShell({
    required this.navigationShell,
    required this.callbacks,
    required this.readOnly,
  });

  final StatefulNavigationShell navigationShell;
  final _ProductivityCallbacks callbacks;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = StoneSetSemanticColors.of(context);
    return Scaffold(
      key: const Key('dashboard-shell-expanded'),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 256,
              child: Material(
                color: colors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _NavigationHeader(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StoneSetSpacing.sm,
                        ),
                        itemCount: _visibleDestinations.length,
                        itemBuilder: (context, index) {
                          final destination = _visibleDestinations[index];
                          final branchIndex = _visibleBranchIndexes[index];
                          return _SidebarDestination(
                            destination: destination,
                            selected: branchIndex == navigationShell.currentIndex,
                            onPressed: () => _selectDestination(
                              navigationShell,
                              branchIndex,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(StoneSetSpacing.sm),
                      child: _SignOutButton(onPressed: callbacks.onSignOut),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(width: 1, color: colors.outline),
            Expanded(
              child: Column(
                children: <Widget>[
                  _DesktopTopBar(
                    destination: DashboardDestination.values[navigationShell.currentIndex],
                    callbacks: callbacks,
                  ),
                  Expanded(
                    child: _DashboardContent(
                      readOnly: readOnly,
                      child: navigationShell,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.readOnly, required this.child});

  final bool readOnly;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      if (readOnly)
        const Padding(
          padding: EdgeInsets.all(StoneSetSpacing.sm),
          child: StoneSetStatusBanner(
            kind: StoneSetStatusKind.warning,
            message:
                'Read only. Product changes are temporarily unavailable; fixture previews remain non-authoritative.',
          ),
        ),
      Expanded(child: child),
    ],
  );
}

class _NavigationHeader extends StatelessWidget {
  const _NavigationHeader({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        StoneSetSpacing.md,
        compact ? StoneSetSpacing.xl : StoneSetSpacing.lg,
        StoneSetSpacing.md,
        StoneSetSpacing.lg,
      ),
      child: Row(
        children: <Widget>[
          const _StoneSetMark(),
          const SizedBox(width: StoneSetSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Stone Set',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Training workspace',
                  style: StoneSetTextStyles.of(context).caption.copyWith(
                    color: StoneSetSemanticColors.of(context).textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoneSetMark extends StatelessWidget {
  const _StoneSetMark();

  @override
  Widget build(BuildContext context) {
    final colors = StoneSetSemanticColors.of(context);
    return Semantics(
      label: 'Stone Set',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.interactiveSurface,
            borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
            border: Border.all(color: colors.outline),
          ),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.change_history_rounded),
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final DashboardDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: StoneSetSpacing.xxs),
      child: Semantics(
        selected: selected,
        button: true,
        child: ListTile(
          key: Key('dashboard-sidebar-${destination.name}'),
          selected: selected,
          leading: Icon(selected ? destination.selectedIcon : destination.icon),
          title: Text(destination.label),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({required this.destination, required this.callbacks});

  final DashboardDestination destination;
  final _ProductivityCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StoneSetSemanticColors.of(context).surface,
        border: Border(
          bottom: BorderSide(color: StoneSetSemanticColors.of(context).outline),
        ),
      ),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: StoneSetSpacing.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    destination.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              _ProductivityActions(callbacks: callbacks),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        key: const Key('dashboard-sign-out-button'),
        onPressed: onPressed,
        icon: const Icon(Icons.logout),
        tooltip: 'Sign out',
      );
    }
    return StoneSetButton(
      key: const Key('dashboard-sign-out-button'),
      label: 'Sign out',
      icon: Icons.logout,
      kind: StoneSetButtonKind.quiet,
      onPressed: onPressed,
    );
  }
}

class _ProductivityCallbacks {
  const _ProductivityCallbacks({
    required this.onSearch,
    required this.onCommands,
    required this.onShortcutHelp,
    required this.onCycleTheme,
    required this.onSignOut,
  });

  final VoidCallback onSearch;
  final VoidCallback onCommands;
  final VoidCallback onShortcutHelp;
  final VoidCallback onCycleTheme;
  final VoidCallback onSignOut;
}

class _ProductivityActions extends StatelessWidget {
  const _ProductivityActions({required this.callbacks, this.compact = false});

  final _ProductivityCallbacks callbacks;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            key: const Key('dashboard-open-search'),
            onPressed: callbacks.onSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Search (/)',
          ),
          PopupMenuButton<_CompactAction>(
            key: const Key('dashboard-more-actions'),
            tooltip: 'Dashboard actions',
            onSelected: (action) {
              switch (action) {
                case _CompactAction.commands:
                  callbacks.onCommands();
                case _CompactAction.shortcuts:
                  callbacks.onShortcutHelp();
                case _CompactAction.theme:
                  callbacks.onCycleTheme();
                case _CompactAction.signOut:
                  callbacks.onSignOut();
              }
            },
            itemBuilder: (context) => const <PopupMenuEntry<_CompactAction>>[
              PopupMenuItem(
                value: _CompactAction.commands,
                child: ListTile(
                  leading: Icon(Icons.keyboard_command_key),
                  title: Text('Command palette'),
                ),
              ),
              PopupMenuItem(
                value: _CompactAction.shortcuts,
                child: ListTile(
                  leading: Icon(Icons.keyboard_outlined),
                  title: Text('Keyboard shortcuts'),
                ),
              ),
              PopupMenuItem(
                value: _CompactAction.theme,
                child: ListTile(
                  leading: Icon(Icons.contrast_outlined),
                  title: Text('Switch theme'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _CompactAction.signOut,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          key: const Key('dashboard-open-search'),
          onPressed: callbacks.onSearch,
          icon: const Icon(Icons.search),
          tooltip: 'Search (/)',
        ),
        IconButton(
          key: const Key('dashboard-open-command-palette'),
          onPressed: callbacks.onCommands,
          icon: const Icon(Icons.keyboard_command_key),
          tooltip: 'Command palette (Ctrl/Cmd + K)',
        ),
        IconButton(
          key: const Key('dashboard-open-shortcuts'),
          onPressed: callbacks.onShortcutHelp,
          icon: const Icon(Icons.keyboard_outlined),
          tooltip: 'Keyboard shortcuts (?)',
        ),
        IconButton(
          key: const Key('dashboard-cycle-theme'),
          onPressed: callbacks.onCycleTheme,
          icon: const Icon(Icons.contrast_outlined),
          tooltip: 'Switch theme',
        ),
      ],
    );
  }
}

enum _CompactAction { commands, shortcuts, theme, signOut }

void _selectDestination(StatefulNavigationShell navigationShell, int index) {
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
