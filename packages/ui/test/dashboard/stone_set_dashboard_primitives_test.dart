import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  testWidgets('list-detail scaffold adapts from routed detail to three panes', (tester) async {
    await _pump(
      tester,
      width: 500,
      child: StoneSetListDetailScaffold(
        hasSelection: true,
        list: const Text('Fixture list'),
        detail: const Text('Fixture detail'),
        supportingPane: const Text('Fixture support'),
        onCompactBack: () {},
      ),
    );

    expect(find.text('Fixture list'), findsNothing);
    expect(find.text('Fixture detail'), findsOneWidget);
    expect(find.byKey(const Key('dashboard-list-detail-back')), findsOneWidget);

    await _pump(
      tester,
      width: 1300,
      child: const StoneSetListDetailScaffold(
        hasSelection: true,
        list: Text('Fixture list'),
        detail: Text('Fixture detail'),
        supportingPane: Text('Fixture support'),
      ),
    );

    expect(find.text('Fixture list'), findsOneWidget);
    expect(find.text('Fixture detail'), findsOneWidget);
    expect(find.text('Fixture support'), findsOneWidget);
  });

  testWidgets('responsive toolbar preserves one direct action and keyboard-operable overflow', (
    tester,
  ) async {
    var selected = '';
    await _pump(
      tester,
      width: 640,
      child: StoneSetResponsiveToolbar(
        title: 'Fixture toolbar',
        actions: <StoneSetDashboardAction>[
          StoneSetDashboardAction(
            id: 'primary',
            label: 'Primary action',
            icon: Icons.add,
            onPressed: () => selected = 'primary',
          ),
          StoneSetDashboardAction(
            id: 'secondary',
            label: 'Secondary action',
            icon: Icons.edit,
            onPressed: () => selected = 'secondary',
          ),
        ],
      ),
    );

    expect(find.text('Primary action'), findsOneWidget);
    expect(find.byKey(const Key('dashboard-toolbar-overflow')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-toolbar-overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Secondary action'));
    await tester.pumpAndSettle();
    expect(selected, 'secondary');
  });

  testWidgets('reorder placeholder exposes labelled keyboard alternatives', (tester) async {
    var movedUp = false;
    var movedDown = false;
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      child: StoneSetReorderPlaceholder(
        label: 'Incline dumbbell press',
        position: 2,
        total: 4,
        onMoveUp: () => movedUp = true,
        onMoveDown: () => movedDown = true,
      ),
    );

    expect(
      tester.getSemantics(find.byType(StoneSetReorderPlaceholder)).label,
      contains('Position 2 of 4'),
    );
    await tester.tap(find.byKey(const Key('dashboard-reorder-up-2')));
    await tester.tap(find.byKey(const Key('dashboard-reorder-down-2')));
    expect(movedUp, isTrue);
    expect(movedDown, isTrue);
    semantics.dispose();
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  double width = 900,
}) async {
  tester.view.physicalSize = Size(width, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: StoneSetTheme.light(),
      home: Scaffold(body: SizedBox.expand(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}
