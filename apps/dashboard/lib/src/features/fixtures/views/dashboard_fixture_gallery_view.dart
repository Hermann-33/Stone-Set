import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../commands/dashboard_productivity_layer.dart';
import '../../overview/views/dashboard_overview_view.dart';
import '../../search/dashboard_search.dart';
import '../../shell/models/dashboard_destination.dart';
import '../../shell/views/dashboard_destination_placeholder.dart';
import '../../status/dashboard_save_status.dart';
import '../dashboard_overview_fixtures.dart';

class DashboardFixtureGalleryView extends StatelessWidget {
  const DashboardFixtureGalleryView({required this.scenario, super.key});

  /// Accepts route strings as well as typed scenarios for focused widget previews.
  final Object scenario;

  @override
  Widget build(BuildContext context) {
    final name = switch (scenario) {
      DashboardOverviewFixtureScenario value => value.name,
      String value => value,
      _ => scenario.toString(),
    };
    final overviewScenario = _parseOverviewScenario(name);
    if (overviewScenario != null) {
      return DashboardOverviewView(scenario: overviewScenario);
    }

    final destination = _parseDestination(name);
    if (destination != null) {
      return DashboardDestinationPlaceholder(
        destination: destination,
        fixtureId: 'gallery-$name',
      );
    }

    final searchState = _parseSearchState(name);
    if (searchState != null) {
      return _SearchFixturePreview(state: searchState);
    }

    if (_matches(name, 'command-palette', 'commands')) {
      return const _CommandFixturePreview();
    }
    if (_matches(name, 'shortcut-help', 'shortcuts')) {
      return const _ShortcutFixturePreview();
    }

    final saveState = _parseSaveState(name);
    if (saveState != null) {
      return _SaveStateFixturePreview(state: saveState);
    }

    final textScale = _parseTextScale(name);
    if (textScale != null) {
      return _MediaFixture(
        textScaler: TextScaler.linear(textScale),
        child: _AccessibilityFixturePreview(
          title: '${(textScale * 100).round()}% text',
          description: 'Content remains available without horizontal clipping.',
        ),
      );
    }

    if (_matches(name, 'reduced-motion', 'motion-reduced')) {
      return const _MediaFixture(
        disableAnimations: true,
        accessibleNavigation: true,
        child: _AccessibilityFixturePreview(
          title: 'Reduced motion',
          description: 'Nonessential travel and animated skeleton effects remain disabled.',
        ),
      );
    }

    if (_matches(name, 'focus-sequence', 'keyboard-focus')) {
      return const _FocusSequenceFixturePreview();
    }

    final themeMode = _parseTheme(name);
    if (themeMode != null) {
      final preview = _AccessibilityFixturePreview(
        title: '${themeMode.name[0].toUpperCase()}${themeMode.name.substring(1)} theme',
        description: 'Semantic surface, text, outline, focus, and status roles remain distinct.',
      );
      return switch (themeMode) {
        ThemeMode.dark => Theme(data: StoneSetTheme.dark(), child: preview),
        ThemeMode.light => Theme(data: StoneSetTheme.light(), child: preview),
        ThemeMode.system => preview,
      };
    }

    if (_matches(name, 'shell-compact', 'shell-medium', 'shell-expanded')) {
      return _ShellFixturePreview(name: name);
    }

    if (_matches(name, 'unauthorized', 'permission-denied')) {
      return const DashboardUnauthorizedView();
    }
    if (_matches(name, 'not-found', '404')) {
      return const DashboardSafeErrorView(
        message: 'The requested fixture route was not found. No private data was exposed.',
      );
    }
    if (_matches(name, 'safe-error', 'error')) {
      return const DashboardSafeErrorView();
    }

    return DashboardSafeErrorView(
      message: 'The fixture scenario “$name” is not available in this bounded preview.',
    );
  }
}

class _FixturePreviewPage extends StatelessWidget {
  const _FixturePreviewPage({required this.title, required this.description, required this.child});

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        key: PageStorageKey<String>('fixture-gallery-$title'),
        padding: const EdgeInsets.all(StoneSetSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(height: StoneSetSpacing.xs),
                Text(description),
                const SizedBox(height: StoneSetSpacing.md),
                const StoneSetStatusBanner(
                  kind: StoneSetStatusKind.information,
                  message: 'Fixture preview only — no browser or server record is used.',
                ),
                const SizedBox(height: StoneSetSpacing.xl),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchFixturePreview extends StatelessWidget {
  const _SearchFixturePreview({required this.state});

  final DashboardSearchFixtureState state;

  @override
  Widget build(BuildContext context) {
    final child = switch (state) {
      DashboardSearchFixtureState.loading => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.loading,
        title: 'Searching fixtures',
        message: 'The deterministic search preview is loading.',
      ),
      DashboardSearchFixtureState.empty => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.empty,
        title: 'No matching results',
        message: 'Try a routine, exercise, review, or activity term.',
      ),
      DashboardSearchFixtureState.error => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.error,
        title: 'Search unavailable',
        message: 'The fixture search failed. No saved work was changed.',
      ),
      DashboardSearchFixtureState.results => StoneSetCard(
        padding: EdgeInsets.zero,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DashboardSearchFixtures.results.length,
          itemBuilder: (context, index) {
            final result = DashboardSearchFixtures.results[index];
            return ListTile(
              key: Key('gallery-search-${result.id}'),
              leading: const Icon(Icons.search),
              title: Text(result.title),
              subtitle: Text('${result.group.label} — ${result.subtitle}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(result.location),
            );
          },
        ),
      ),
    };
    return _FixturePreviewPage(
      title: 'Search — ${state.name}',
      description: 'Grouped, permission-filtered fixture search state.',
      child: child,
    );
  }
}

class _CommandFixturePreview extends StatelessWidget {
  const _CommandFixturePreview();

  @override
  Widget build(BuildContext context) {
    return _FixturePreviewPage(
      title: 'Command palette',
      description: 'Implemented commands and their availability.',
      child: StoneSetCard(
        padding: EdgeInsets.zero,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DashboardCommandFixtures.commands.length,
          itemBuilder: (context, index) {
            final command = DashboardCommandFixtures.commands[index];
            return ListTile(
              enabled: command.enabled,
              leading: Icon(command.icon),
              title: Text(command.label),
              subtitle: Text(command.enabled ? command.description : command.disabledReason!),
              trailing: command.shortcut == null ? null : Text(command.shortcut!),
            );
          },
        ),
      ),
    );
  }
}

class _ShortcutFixturePreview extends StatelessWidget {
  const _ShortcutFixturePreview();

  @override
  Widget build(BuildContext context) {
    return _FixturePreviewPage(
      title: 'Keyboard shortcuts',
      description: 'Search, commands, and dialog shortcuts implemented by this packet.',
      child: StoneSetCard(
        padding: EdgeInsets.zero,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DashboardShortcutFixtures.shortcuts.length,
          itemBuilder: (context, index) {
            final shortcut = DashboardShortcutFixtures.shortcuts[index];
            return ListTile(
              title: Text(shortcut.description),
              subtitle: Text(shortcut.category),
              trailing: Text(shortcut.keys),
            );
          },
        ),
      ),
    );
  }
}

class _SaveStateFixturePreview extends StatelessWidget {
  const _SaveStateFixturePreview({required this.state});

  final DashboardSaveState state;

  @override
  Widget build(BuildContext context) {
    return _FixturePreviewPage(
      title: 'Save state — ${state.label}',
      description: 'Explicit, non-authoritative presentation with a semantic status message.',
      child: state == DashboardSaveState.conflict
          ? DashboardConflictSurface(
              onCompare: () {},
              onRestoreFixture: () {},
              onKeepCurrentFixture: () {},
            )
          : DashboardSaveStatus(
              state: state,
              onRetry: state == DashboardSaveState.failed ? () {} : null,
            ),
    );
  }
}

class _MediaFixture extends StatelessWidget {
  const _MediaFixture({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
    this.accessibleNavigation = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;
  final bool accessibleNavigation;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: textScaler ?? media.textScaler,
        disableAnimations: disableAnimations,
        accessibleNavigation: accessibleNavigation,
      ),
      child: child,
    );
  }
}

class _AccessibilityFixturePreview extends StatelessWidget {
  const _AccessibilityFixturePreview({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _FixturePreviewPage(
      title: title,
      description: description,
      child: StoneSetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Fixture heading', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: StoneSetSpacing.sm),
            const Text(
              'Meaning remains available through text, iconography, focus, and semantic roles — '
              'never through color alone.',
            ),
            const SizedBox(height: StoneSetSpacing.md),
            const Wrap(
              spacing: StoneSetSpacing.xs,
              runSpacing: StoneSetSpacing.xs,
              children: <Widget>[
                StoneSetStatusChip(kind: StoneSetStatusKind.success, label: 'Saved'),
                StoneSetStatusChip(kind: StoneSetStatusKind.warning, label: 'Read only'),
                StoneSetStatusChip(kind: StoneSetStatusKind.conflict, label: 'Conflict'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusSequenceFixturePreview extends StatelessWidget {
  const _FocusSequenceFixturePreview();

  @override
  Widget build(BuildContext context) {
    return _FixturePreviewPage(
      title: 'Keyboard focus sequence',
      description: 'Controls follow reading order and retain visible Material focus treatment.',
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const TextField(decoration: InputDecoration(labelText: 'Search fixtures')),
            const SizedBox(height: StoneSetSpacing.md),
            Wrap(
              spacing: StoneSetSpacing.sm,
              runSpacing: StoneSetSpacing.sm,
              children: <Widget>[
                StoneSetButton(label: 'Primary action', onPressed: () {}),
                StoneSetButton(
                  label: 'Secondary action',
                  kind: StoneSetButtonKind.secondary,
                  onPressed: () {},
                ),
                StoneSetButton(
                  label: 'Unavailable action',
                  kind: StoneSetButtonKind.quiet,
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellFixturePreview extends StatelessWidget {
  const _ShellFixturePreview({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final label = name.split('-').last;
    return _FixturePreviewPage(
      title: 'Adaptive shell — $label',
      description: 'Resize the browser to exercise the actual authenticated shell at this tier.',
      child: StoneSetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StoneSetStatusChip(kind: StoneSetStatusKind.information, label: label),
            const SizedBox(height: StoneSetSpacing.md),
            const Text(
              'The route, selected destination, branch navigation, and page storage remain owned '
              'by go_router while the shell changes navigation chrome by available width.',
            ),
          ],
        ),
      ),
    );
  }
}

DashboardOverviewFixtureScenario? _parseOverviewScenario(String name) {
  final normalized = name.split('/').last.replaceAll('-', '').replaceAll('_', '').toLowerCase();
  for (final scenario in DashboardOverviewFixtureScenario.values) {
    if (scenario.name.toLowerCase() == normalized) {
      return scenario;
    }
  }
  return null;
}

DashboardDestination? _parseDestination(String name) {
  final normalized = name.split('/').last.toLowerCase();
  for (final destination in DashboardDestination.values) {
    if (destination.name == normalized) {
      return destination;
    }
  }
  return null;
}

DashboardSearchFixtureState? _parseSearchState(String name) {
  final normalized = _normalize(name).replaceFirst('search', '');
  return switch (normalized) {
    'results' => DashboardSearchFixtureState.results,
    'loading' => DashboardSearchFixtureState.loading,
    'empty' => DashboardSearchFixtureState.empty,
    'error' => DashboardSearchFixtureState.error,
    _ => null,
  };
}

DashboardSaveState? _parseSaveState(String name) {
  final normalized = _normalize(name).replaceFirst('status', '').replaceFirst('save', '');
  return switch (normalized) {
    'saved' => DashboardSaveState.saved,
    'saving' => DashboardSaveState.saving,
    'offline' => DashboardSaveState.offline,
    'syncing' => DashboardSaveState.syncing,
    'conflict' => DashboardSaveState.conflict,
    'failed' || 'failedtosave' => DashboardSaveState.failed,
    'readonly' => DashboardSaveState.readOnly,
    _ => null,
  };
}

double? _parseTextScale(String name) {
  final normalized = _normalize(name).replaceFirst('text', '').replaceFirst('scale', '');
  return switch (normalized) {
    '100' => 1,
    '150' => 1.5,
    '200' => 2,
    _ => null,
  };
}

ThemeMode? _parseTheme(String name) {
  final normalized = _normalize(name).replaceFirst('theme', '');
  return switch (normalized) {
    'system' => ThemeMode.system,
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => null,
  };
}

bool _matches(String name, String first, [String? second, String? third]) {
  final normalized = _normalize(name);
  return <String>{
    first,
    ?second,
    ?third,
  }.map(_normalize).contains(normalized);
}

String _normalize(String value) =>
    value.split('/').last.replaceAll('-', '').replaceAll('_', '').toLowerCase();
