import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  testWidgets('renders supplied foundation content with a semantic heading', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoneSetFoundationPanel(
              title: 'Foundation title',
              message: 'Foundation message',
            ),
          ),
        ),
      );

      expect(find.text('Foundation title'), findsOneWidget);
      expect(find.text('Foundation message'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Foundation title')),
        matchesSemantics(label: 'Foundation title', isHeader: true),
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
