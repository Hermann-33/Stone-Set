import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../features/identity/controllers/mobile_session_controller.dart';
import 'router/mobile_router.dart';

class StoneSetMobileApp extends ConsumerStatefulWidget {
  const StoneSetMobileApp({super.key});

  @override
  ConsumerState<StoneSetMobileApp> createState() => _StoneSetMobileAppState();
}

class _StoneSetMobileAppState extends ConsumerState<StoneSetMobileApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(mobileSessionControllerProvider.notifier).foregroundRevalidate());
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(mobileRouterProvider);
    final appearanceMode = ref
        .watch(mobileSessionControllerProvider)
        .value
        ?.bootstrap
        ?.preferences
        .appearanceMode;
    return MaterialApp.router(
      title: 'Stone Set',
      debugShowCheckedModeBanner: false,
      theme: StoneSetTheme.light(),
      darkTheme: StoneSetTheme.dark(),
      themeMode: switch (appearanceMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      routerConfig: router,
    );
  }
}
