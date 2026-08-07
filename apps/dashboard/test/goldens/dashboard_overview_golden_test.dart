import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/main.dart';
import 'package:stone_set_dashboard/src/session/dashboard_session_controller.dart';

import '../support/fake_identity_repository.dart';

void main() {
  const surfaces = <({String name, Size size})>[
    (name: 'compact', size: Size(600, 900)),
    (name: 'medium', size: Size(900, 900)),
    (name: 'expanded', size: Size(1360, 900)),
  ];

  for (final brightness in Brightness.values) {
    for (final surface in surfaces) {
      testWidgets(
        '${surface.name} ${brightness.name} Overview',
        (tester) async {
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          tester.view.physicalSize = surface.size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final repository = FakeIdentityRepository(
            recoveredSession: testSession,
            bootstrapResult: testBootstrap(),
          );
          addTearDown(repository.dispose);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dashboardIdentityRepositoryProvider.overrideWithValue(repository),
              ],
              child: const RepaintBoundary(
                key: Key('dashboard-golden-surface'),
                child: StoneSetDashboardApp(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await expectLater(
            find.byKey(const Key('dashboard-golden-surface')),
            matchesGoldenFile(
              'dashboard_overview_${surface.name}_${brightness.name}.png',
            ),
          );
        },
        skip: kIsWeb,
      );
    }
  }
}
