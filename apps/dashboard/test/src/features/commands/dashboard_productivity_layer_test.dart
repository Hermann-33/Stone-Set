import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/commands/dashboard_productivity_layer.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  Widget app(Widget child) => MaterialApp(
    theme: StoneSetTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('slash opens search from the protected productivity layer', (tester) async {
    await tester.pumpWidget(
      app(
        DashboardProductivityLayer(
          onOpenLocation: (_) {},
          onCommand: (_) {},
          child: const Center(child: Text('Protected fixture')),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-search-dialog')), findsOneWidget);
  });

  testWidgets('global shortcuts do not override focused text editing', (tester) async {
    await tester.pumpWidget(
      app(
        DashboardProductivityLayer(
          onOpenLocation: (_) {},
          onCommand: (_) {},
          child: const TextField(autofocus: true),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-search-dialog')), findsNothing);
  });

  testWidgets('palette explains disabled commands and dispatches keyboard selection', (
    tester,
  ) async {
    const commands = <DashboardCommand>[
      DashboardCommand(
        id: 'disabled',
        label: 'Unavailable action',
        description: 'Not available.',
        icon: Icons.block,
        enabled: false,
        disabledReason: 'Arrives in a later approved task.',
      ),
      DashboardCommand(
        id: 'enabled',
        label: 'Open fixture',
        description: 'Open a deterministic fixture.',
        icon: Icons.open_in_new,
      ),
    ];
    String? commandId;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () => DashboardCommandPalette.show(
              context,
              commands: commands,
              onCommand: (value) => commandId = value,
            ),
            child: const Text('Open palette'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();

    expect(find.text('Arrives in a later approved task.'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(commandId, 'enabled');
    expect(find.byKey(const Key('dashboard-command-palette')), findsNothing);
  });

  testWidgets('shortcut help is searchable and lists only implemented shortcuts', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () => DashboardShortcutHelpDialog.show(context),
            child: const Text('Open help'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open help'));
    await tester.pumpAndSettle();

    expect(find.text('Ctrl/Cmd + K'), findsOneWidget);
    expect(find.text('Ctrl/Cmd + S'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('dashboard-shortcut-search')),
      'escape',
    );
    await tester.pump();
    expect(find.text('Esc'), findsOneWidget);
    expect(find.text('Ctrl/Cmd + K'), findsNothing);
  });
}
