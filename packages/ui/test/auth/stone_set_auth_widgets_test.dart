import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  testWidgets('auth frame remains visible at 200 percent text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: StoneSetAuthFrame(
            title: 'Sign in',
            description: 'Use the username and password provided to you.',
            child: Text('Form content'),
          ),
        ),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Form content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password control toggles visibility accessibly', (tester) async {
    final controller = TextEditingController(text: 'Secret-value7');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoneSetPasswordField(controller: controller, label: 'Password'),
        ),
      ),
    );

    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
