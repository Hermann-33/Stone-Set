import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/main.dart';

void main() {
  testWidgets('renders an honest accessible dashboard foundation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const StoneSetDashboardApp());

      expect(find.text('Stone Set dashboard foundation'), findsOneWidget);
      expect(
        find.textContaining('Product workflows, authentication'),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(EditableText), findsNothing);

      expect(
        tester.getSemantics(
          find.byKey(const Key('dashboard-foundation-heading')),
        ),
        isSemantics(
          label: 'Stone Set dashboard foundation',
          textDirection: TextDirection.ltr,
          isHeader: true,
        ),
      );
    } finally {
      semantics.dispose();
    }
  });
}
