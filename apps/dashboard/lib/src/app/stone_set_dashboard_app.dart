import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/dashboard_router.dart';
import '../session/dashboard_session_lifecycle.dart';

class StoneSetDashboardApp extends ConsumerWidget {
  const StoneSetDashboardApp({super.key, this.initialLocation});

  final String? initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(dashboardRouterProvider(initialLocation: initialLocation));

    return DashboardSessionLifecycle(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Stone Set Dashboard',
        themeMode: ThemeMode.system,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        routerConfig: router,
      ),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8B6CFF),
    brightness: brightness,
  );
  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}
