import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/app/dashboard_theme_controller.dart';

void main() {
  group('DashboardThemeModeController', () {
    test('starts in system mode and supports every approved theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(dashboardThemeModeProvider), ThemeMode.system);

      final controller = container.read(dashboardThemeModeProvider.notifier);
      controller.select(ThemeMode.dark);
      expect(container.read(dashboardThemeModeProvider), ThemeMode.dark);

      controller.select(ThemeMode.light);
      expect(container.read(dashboardThemeModeProvider), ThemeMode.light);
    });

    test('reset removes user-owned appearance state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(dashboardThemeModeProvider.notifier)
        ..select(ThemeMode.dark);

      controller.reset();

      expect(container.read(dashboardThemeModeProvider), ThemeMode.system);
    });
  });
}
