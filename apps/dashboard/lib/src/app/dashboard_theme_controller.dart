import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardThemeModeProvider = NotifierProvider<DashboardThemeModeController, ThemeMode>(
  DashboardThemeModeController.new,
  name: 'dashboardThemeModeProvider',
);

class DashboardThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void select(ThemeMode mode) => state = mode;

  void reset() => state = ThemeMode.system;
}
