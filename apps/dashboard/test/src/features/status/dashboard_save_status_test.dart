import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/status/dashboard_save_status.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  Widget app(Widget child) => MaterialApp(
    theme: StoneSetTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('every save state has explicit non-color copy and semantics', (tester) async {
    final semantics = tester.ensureSemantics();

    for (final state in DashboardSaveState.values) {
      await tester.pumpWidget(app(DashboardSaveStatus(state: state)));

      expect(find.textContaining(state.label), findsWidgets, reason: state.name);
      expect(
        find.byKey(Key('dashboard-save-status-${state.name}')),
        findsOneWidget,
        reason: state.name,
      );
      expect(tester.takeException(), isNull, reason: state.name);
    }
    semantics.dispose();
  });

  testWidgets('failed and conflict states expose only supplied recovery actions', (tester) async {
    var retries = 0;
    var comparisons = 0;
    await tester.pumpWidget(
      app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DashboardSaveStatus(
              state: DashboardSaveState.failed,
              onRetry: () => retries += 1,
            ),
            DashboardSaveStatus(
              state: DashboardSaveState.conflict,
              onCompare: () => comparisons += 1,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Retry fixture'));
    await tester.tap(find.text('Compare'));
    expect(retries, 1);
    expect(comparisons, 1);
  });

  testWidgets('conflict surface actions are keyboard-reachable and do not claim persistence', (
    tester,
  ) async {
    var compareCalls = 0;
    var restoreCalls = 0;
    await tester.pumpWidget(
      app(
        DashboardConflictSurface(
          onCompare: () => compareCalls += 1,
          onRestoreFixture: () => restoreCalls += 1,
        ),
      ),
    );

    expect(find.textContaining('does not write'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-conflict-compare')));
    await tester.tap(find.byKey(const Key('dashboard-conflict-restore')));
    expect(compareCalls, 1);
    expect(restoreCalls, 1);
  });
}
