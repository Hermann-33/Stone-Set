import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../search/dashboard_search.dart';

abstract final class DashboardCommandIds {
  static const createRoutine = 'create-routine';
  static const createExercise = 'create-exercise';
  static const openRecentDraft = 'open-recent-draft';
  static const openReviewQueue = 'open-review-queue';
  static const openSearch = 'open-search';
  static const openSettings = 'open-settings';
  static const cycleTheme = 'cycle-theme';
  static const shortcutHelp = 'shortcut-help';
}

@immutable
class DashboardCommand {
  const DashboardCommand({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    this.shortcut,
    this.enabled = true,
    this.disabledReason,
  }) : assert(enabled || disabledReason != null);

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final String? shortcut;
  final bool enabled;
  final String? disabledReason;
}

abstract final class DashboardCommandFixtures {
  static const commands = <DashboardCommand>[
    DashboardCommand(
      id: DashboardCommandIds.createRoutine,
      label: 'Create routine',
      description: 'Open the future routine authoring placeholder.',
      icon: Icons.view_week_outlined,
      enabled: false,
      disabledReason: 'Routine authoring arrives in a later approved task.',
    ),
    DashboardCommand(
      id: DashboardCommandIds.createExercise,
      label: 'Create exercise',
      description: 'Create an owner-scoped exercise definition.',
      icon: Icons.fitness_center_outlined,
    ),
    DashboardCommand(
      id: DashboardCommandIds.openRecentDraft,
      label: 'Open recent draft',
      description: 'Resume the deterministic fixture draft.',
      icon: Icons.edit_note_outlined,
    ),
    DashboardCommand(
      id: DashboardCommandIds.openReviewQueue,
      label: 'Open review queue',
      description: 'Go to the fixture review queue.',
      icon: Icons.rate_review_outlined,
    ),
    DashboardCommand(
      id: DashboardCommandIds.openSearch,
      label: 'Search',
      description: 'Search dashboard fixture content.',
      icon: Icons.search,
      shortcut: '/',
    ),
    DashboardCommand(
      id: DashboardCommandIds.openSettings,
      label: 'Open settings',
      description: 'Go to dashboard settings.',
      icon: Icons.settings_outlined,
    ),
    DashboardCommand(
      id: DashboardCommandIds.cycleTheme,
      label: 'Switch theme',
      description: 'Cycle through system, light, and dark appearance.',
      icon: Icons.contrast_outlined,
    ),
    DashboardCommand(
      id: DashboardCommandIds.shortcutHelp,
      label: 'Keyboard shortcuts',
      description: 'Review implemented dashboard shortcuts.',
      icon: Icons.keyboard_outlined,
      shortcut: '?',
    ),
  ];
}

/// Installs route-agnostic productivity shortcuts around the protected shell.
///
/// Callers retain routing and theme ownership through string command/location
/// callbacks. The layer owns no authenticated or persistent state.
class DashboardProductivityLayer extends StatelessWidget {
  const DashboardProductivityLayer({
    required this.child,
    required this.onOpenLocation,
    required this.onCommand,
    this.searchFixtureState = DashboardSearchFixtureState.results,
    this.searchResults = DashboardSearchFixtures.results,
    this.commands = DashboardCommandFixtures.commands,
    super.key,
  });

  final Widget child;
  final ValueChanged<String> onOpenLocation;
  final ValueChanged<String> onCommand;
  final DashboardSearchFixtureState searchFixtureState;
  final List<DashboardSearchResult> searchResults;
  final List<DashboardCommand> commands;

  static Future<void> openSearch(
    BuildContext context, {
    required ValueChanged<String> onOpenLocation,
    DashboardSearchFixtureState fixtureState = DashboardSearchFixtureState.results,
    List<DashboardSearchResult> results = DashboardSearchFixtures.results,
  }) => DashboardSearchDialog.show(
    context,
    onOpenLocation: onOpenLocation,
    fixtureState: fixtureState,
    results: results,
  );

  static Future<void> openCommandPalette(
    BuildContext context, {
    required ValueChanged<String> onCommand,
    List<DashboardCommand> commands = DashboardCommandFixtures.commands,
  }) => DashboardCommandPalette.show(
    context,
    onCommand: onCommand,
    commands: commands,
  );

  static Future<void> openShortcutHelp(BuildContext context) =>
      DashboardShortcutHelpDialog.show(context);

  bool _isEditingText() {
    bool hasFocusedEditable(Element element) {
      final widget = element.widget;
      if (widget is EditableText && widget.focusNode.hasFocus) return true;
      var found = false;
      element.visitChildElements((child) {
        if (!found) found = hasFocusedEditable(child);
      });
      return found;
    }

    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement != null && hasFocusedEditable(rootElement)) return true;

    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;
    bool ownsEditableText(FocusNode node) {
      final focusedContext = node.context;
      if (focusedContext == null) return false;
      final currentState = focusedContext is StatefulElement ? focusedContext.state : null;
      return focusedContext.widget is TextField ||
          focusedContext.widget is TextFormField ||
          focusedContext.widget is EditableText ||
          currentState is EditableTextState ||
          focusedContext.findAncestorWidgetOfExactType<TextField>() != null ||
          focusedContext.findAncestorWidgetOfExactType<TextFormField>() != null ||
          focusedContext.findAncestorWidgetOfExactType<EditableText>() != null ||
          focusedContext.findAncestorStateOfType<EditableTextState>() != null;
    }

    return ownsEditableText(primaryFocus) || primaryFocus.ancestors.any(ownsEditableText);
  }

  KeyEventResult _handleKey(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent || _isEditingText()) return KeyEventResult.ignored;
    final hardware = HardwareKeyboard.instance;
    final commandModifier = hardware.isControlPressed || hardware.isMetaPressed;
    if (commandModifier && event.logicalKey == LogicalKeyboardKey.keyK) {
      unawaited(openCommandPalette(context, onCommand: onCommand, commands: commands));
      return KeyEventResult.handled;
    }
    if (!hardware.isAltPressed &&
        !commandModifier &&
        event.logicalKey == LogicalKeyboardKey.slash) {
      unawaited(
        openSearch(
          context,
          onOpenLocation: onOpenLocation,
          fixtureState: searchFixtureState,
          results: searchResults,
        ),
      );
      return KeyEventResult.handled;
    }
    if (!hardware.isAltPressed && !commandModifier && event.character == '?') {
      unawaited(openShortcutHelp(context));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Focus(
    key: const Key('dashboard-productivity-layer'),
    autofocus: true,
    skipTraversal: true,
    onKeyEvent: (_, event) => _handleKey(context, event),
    child: child,
  );
}

class DashboardCommandPalette extends StatefulWidget {
  const DashboardCommandPalette({
    required this.onCommand,
    this.commands = DashboardCommandFixtures.commands,
    super.key,
  });

  final ValueChanged<String> onCommand;
  final List<DashboardCommand> commands;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onCommand,
    List<DashboardCommand> commands = DashboardCommandFixtures.commands,
  }) => showDialog<void>(
    context: context,
    builder: (context) => DashboardCommandPalette(onCommand: onCommand, commands: commands),
  );

  @override
  State<DashboardCommandPalette> createState() => _DashboardCommandPaletteState();
}

class _DashboardCommandPaletteState extends State<DashboardCommandPalette> {
  final TextEditingController _queryController = TextEditingController();
  int _selectedIndex = 0;

  List<DashboardCommand> get _filtered {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.commands;
    return widget.commands
        .where(
          (command) =>
              command.label.toLowerCase().contains(query) ||
              command.description.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final commands = _filtered;
    if (commands.isEmpty) return;
    setState(() => _selectedIndex = (_selectedIndex + delta) % commands.length);
  }

  void _dispatch(DashboardCommand command) {
    if (!command.enabled) return;
    Navigator.of(context).pop();
    widget.onCommand(command.id);
  }

  void _dispatchSelected() {
    final commands = _filtered;
    if (commands.isEmpty) return;
    _dispatch(commands[_selectedIndex.clamp(0, commands.length - 1)]);
  }

  @override
  Widget build(BuildContext context) {
    final commands = _filtered;
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.enter): _dispatchSelected,
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: AlertDialog(
        key: const Key('dashboard-command-palette'),
        title: Row(
          children: <Widget>[
            const Expanded(child: Text('Command palette')),
            IconButton(
              key: const Key('dashboard-command-close'),
              tooltip: 'Close command palette',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 640,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: const Key('dashboard-command-search'),
                controller: _queryController,
                autofocus: true,
                onChanged: (_) => setState(() => _selectedIndex = 0),
                decoration: const InputDecoration(
                  labelText: 'Find a command',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: StoneSetSpacing.sm),
              Expanded(
                child: commands.isEmpty
                    ? const StoneSetDashboardStatePanel(
                        state: StoneSetDashboardPanelState.empty,
                        title: 'No matching commands',
                        message: 'Try a shorter action or destination name.',
                      )
                    : ListView.builder(
                        key: const Key('dashboard-command-results'),
                        itemCount: commands.length,
                        itemBuilder: (context, index) {
                          final command = commands[index];
                          final reason = command.enabled
                              ? command.description
                              : command.disabledReason!;
                          return Semantics(
                            enabled: command.enabled,
                            selected: index == _selectedIndex,
                            button: true,
                            label: '${command.label}. $reason',
                            child: ExcludeSemantics(
                              child: ListTile(
                                key: Key('dashboard-command-${command.id}'),
                                enabled: command.enabled,
                                selected: index == _selectedIndex,
                                minTileHeight: StoneSetSpacing.minimumTouchTarget,
                                leading: Icon(command.icon),
                                title: Text(command.label),
                                subtitle: Text(reason),
                                trailing: command.shortcut == null
                                    ? null
                                    : _ShortcutKeyLabel(command.shortcut!),
                                onTap: command.enabled ? () => _dispatch(command) : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: StoneSetSpacing.sm),
              Text(
                'Use ↑ and ↓ to move, Enter to run, and Esc to close.',
                style: StoneSetTextStyles.of(context).caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class DashboardShortcutDefinition {
  const DashboardShortcutDefinition({
    required this.category,
    required this.keys,
    required this.description,
    required this.searchTerms,
  });

  final String category;
  final String keys;
  final String description;
  final String searchTerms;
}

abstract final class DashboardShortcutFixtures {
  static const shortcuts = <DashboardShortcutDefinition>[
    DashboardShortcutDefinition(
      category: 'Global',
      keys: '/',
      description: 'Open dashboard search when focus is not in a text field.',
      searchTerms: 'search find global slash',
    ),
    DashboardShortcutDefinition(
      category: 'Global',
      keys: 'Ctrl/Cmd + K',
      description: 'Open the command palette.',
      searchTerms: 'command palette control meta',
    ),
    DashboardShortcutDefinition(
      category: 'Global',
      keys: '?',
      description: 'Open this shortcut guide.',
      searchTerms: 'help shortcuts question',
    ),
    DashboardShortcutDefinition(
      category: 'Search and commands',
      keys: '↑ / ↓',
      description: 'Move through visible results.',
      searchTerms: 'arrow move results selection',
    ),
    DashboardShortcutDefinition(
      category: 'Search and commands',
      keys: 'Enter',
      description: 'Open the selected result or run the selected command.',
      searchTerms: 'open run selected result command',
    ),
    DashboardShortcutDefinition(
      category: 'Dialogs',
      keys: 'Esc',
      description: 'Close search, the command palette, or shortcut help.',
      searchTerms: 'escape close cancel dialog',
    ),
  ];
}

class DashboardShortcutHelpDialog extends StatefulWidget {
  const DashboardShortcutHelpDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => const DashboardShortcutHelpDialog(),
  );

  @override
  State<DashboardShortcutHelpDialog> createState() => _DashboardShortcutHelpDialogState();
}

class _DashboardShortcutHelpDialogState extends State<DashboardShortcutHelpDialog> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _queryController.text.trim().toLowerCase();
    final shortcuts = DashboardShortcutFixtures.shortcuts
        .where(
          (shortcut) =>
              query.isEmpty ||
              shortcut.description.toLowerCase().contains(query) ||
              shortcut.category.toLowerCase().contains(query) ||
              shortcut.searchTerms.contains(query) ||
              shortcut.keys.toLowerCase().contains(query),
        )
        .toList(growable: false);
    final categories = shortcuts.map((shortcut) => shortcut.category).toSet();
    return AlertDialog(
      key: const Key('dashboard-shortcut-help'),
      title: Row(
        children: <Widget>[
          const Expanded(child: Text('Keyboard shortcuts')),
          IconButton(
            key: const Key('dashboard-shortcut-close'),
            tooltip: 'Close shortcut help',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 620,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              key: const Key('dashboard-shortcut-search'),
              controller: _queryController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search shortcuts',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: StoneSetSpacing.md),
            Expanded(
              child: shortcuts.isEmpty
                  ? const StoneSetDashboardStatePanel(
                      state: StoneSetDashboardPanelState.empty,
                      title: 'No matching shortcuts',
                      message: 'Try searching for search, commands, dialogs, or navigation.',
                    )
                  : ListView(
                      key: const Key('dashboard-shortcut-list'),
                      children: <Widget>[
                        for (final category in categories) ...<Widget>[
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              top: StoneSetSpacing.sm,
                              bottom: StoneSetSpacing.xxs,
                            ),
                            child: Semantics(
                              header: true,
                              child: Text(category, style: Theme.of(context).textTheme.titleSmall),
                            ),
                          ),
                          for (final shortcut in shortcuts.where(
                            (shortcut) => shortcut.category == category,
                          ))
                            ListTile(
                              minTileHeight: StoneSetSpacing.minimumTouchTarget,
                              title: Text(shortcut.description),
                              trailing: _ShortcutKeyLabel(shortcut.keys),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutKeyLabel extends StatelessWidget {
  const _ShortcutKeyLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: StoneSetSemanticColors.of(context).interactiveSurface,
      border: Border.all(color: StoneSetSemanticColors.of(context).outline),
      borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius / 2),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StoneSetSpacing.xs,
        vertical: StoneSetSpacing.xxs,
      ),
      child: Text(label, style: StoneSetTextStyles.of(context).caption),
    ),
  );
}
