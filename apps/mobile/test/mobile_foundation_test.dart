import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/main.dart';

void main() {
  testWidgets('identifies the Android foundation accessibly', (tester) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(const StoneSetMobileApp());

      expect(find.text('Stone Set'), findsOneWidget);
      expect(find.text('Android foundation'), findsOneWidget);
      expect(
        find.text(
          'The mobile foundation is ready. Product features are not implemented yet.',
        ),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(find.text('Stone Set')),
        matchesSemantics(label: 'Stone Set', isHeader: true),
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
