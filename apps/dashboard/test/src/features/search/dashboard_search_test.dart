import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/search/dashboard_search.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  Future<void> pumpSearch(
    WidgetTester tester, {
    DashboardSearchFixtureState state = DashboardSearchFixtureState.results,
    ValueChanged<String>? onOpenLocation,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.light(),
        home: Scaffold(
          body: DashboardSearchDialog(
            fixtureState: state,
            onOpenLocation: onOpenLocation ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('groups fixture results and announces a semantic result count', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSearch(tester);

    expect(find.text('Routines · 1'), findsOneWidget);
    expect(find.text('Routine versions · 1'), findsOneWidget);
    expect(find.text('Exercises · 1'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('6 results')).label,
      contains('6 results'),
    );
    semantics.dispose();
  });

  testWidgets('filters case-insensitively and exposes an empty state', (tester) async {
    await pumpSearch(tester);

    await tester.enterText(
      find.byKey(const Key('dashboard-global-search-input')),
      'INCLINE',
    );
    await tester.pump();

    expect(find.text('Incline dumbbell press'), findsOneWidget);
    expect(find.text('1 result'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('dashboard-global-search-input')),
      'not a fixture',
    );
    await tester.pump();

    expect(find.text('No matching fixtures'), findsOneWidget);
    expect(find.text('0 results'), findsOneWidget);
  });

  testWidgets('arrow navigation and Enter open the selected typed location', (tester) async {
    String? openedLocation;
    await pumpSearch(tester, onOpenLocation: (location) => openedLocation = location);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(openedLocation, '/routines/strength-foundation/versions/3');
  });

  testWidgets('loading and error fixtures communicate explicit states', (tester) async {
    await pumpSearch(tester, state: DashboardSearchFixtureState.loading);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await pumpSearch(tester, state: DashboardSearchFixtureState.error);
    expect(find.text('Search is unavailable'), findsOneWidget);
    expect(find.textContaining('Close search and try again'), findsOneWidget);
  });

  testWidgets('Esc closes a shown search dialog without trapping focus', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => DashboardSearchDialog.show(
                context,
                onOpenLocation: (_) {},
              ),
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-search-dialog')), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-search-dialog')), findsNothing);
  });
}
