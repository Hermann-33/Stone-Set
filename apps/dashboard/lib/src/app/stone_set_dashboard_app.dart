import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../routing/dashboard_router.dart';
import '../session/dashboard_session_controller.dart';
import '../session/dashboard_session_lifecycle.dart';
import 'dashboard_theme_controller.dart';

class StoneSetDashboardApp extends ConsumerWidget {
  const StoneSetDashboardApp({super.key, this.initialLocation});

  final String? initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(dashboardRouterProvider(initialLocation: initialLocation));
    final themeMode = ref.watch(dashboardThemeModeProvider);
    ref.listen(dashboardSessionControllerProvider, (previous, next) {
      if (previous?.userId != next.userId) {
        ref.read(dashboardThemeModeProvider.notifier).reset();
      }
    });

    return DashboardSessionLifecycle(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Stone Set Dashboard',
        themeMode: themeMode,
        theme: StoneSetTheme.light(),
        darkTheme: StoneSetTheme.dark(),
        routerConfig: router,
      ),
    );
  }
}
