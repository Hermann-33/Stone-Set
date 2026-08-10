import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  test('light and dark themes install the shared semantic contract', () {
    final light = StoneSetTheme.light();
    final dark = StoneSetTheme.dark();

    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.extension<StoneSetSemanticColors>(), StoneSetSemanticColors.light);
    expect(dark.extension<StoneSetSemanticColors>(), StoneSetSemanticColors.dark);
    expect(light.extension<StoneSetTextStyles>(), isNotNull);
    expect(StoneSetTextStyles.standard.dataValue.fontFeatures, isNotEmpty);
    expect(light.extension<StoneSetPresentationProfile>(), isNull);
    expect(dark.extension<StoneSetPresentationProfile>(), isNull);
    expect(StoneSetShapes.cardRadius, 16);
    expect(StoneSetShapes.controlRadius, 12);
  });

  testWidgets('reduced motion honors platform accessibility settings', (tester) async {
    late bool reduced;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              reduced = StoneSetMotion.reducedMotionOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(reduced, isTrue);
    expect(StoneSetSpacing.minimumTouchTarget, 48);
    expect(StoneSetMotion.standard, const Duration(milliseconds: 240));
  });

  test('mobile themes install the complete mobile component contract', () {
    final light = StoneSetTheme.mobileLight();
    final dark = StoneSetTheme.mobileDark();

    for (final theme in <ThemeData>[light, dark]) {
      expect(theme.navigationBarTheme.height, greaterThanOrEqualTo(64));
      expect(theme.cardTheme.elevation, 0);
      expect(theme.bottomSheetTheme.showDragHandle, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.extension<StoneSetTextStyles>()?.pageTitle.fontSize, 28);
      expect(theme.extension<StoneSetTextStyles>()?.identifier.fontFamily, 'monospace');
      expect(theme.extension<StoneSetPresentationProfile>()?.mobile, isTrue);
    }
    expect(StoneSetShapes.mobileCardRadius, 18);
    expect(StoneSetShapes.mobileControlRadius, 14);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(
      light.extension<StoneSetSemanticColors>()?.canvas,
      isNot(dark.extension<StoneSetSemanticColors>()?.canvas),
    );
  });
}
