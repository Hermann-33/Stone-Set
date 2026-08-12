import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../sync/controllers/mobile_sync_controller.dart';
import '../models/mobile_destination.dart';

class MobileAuthenticatedShell extends ConsumerStatefulWidget {
  const MobileAuthenticatedShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MobileAuthenticatedShell> createState() => _MobileAuthenticatedShellState();
}

class _MobileAuthenticatedShellState extends ConsumerState<MobileAuthenticatedShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_synchronize(MobileSyncTrigger.startup));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_synchronize(MobileSyncTrigger.resume));
    }
  }

  Future<void> _synchronize(MobileSyncTrigger trigger) async {
    final ownerId = ref.read(mobileSessionControllerProvider).value?.userId;
    if (ownerId == null) return;
    final coordinator = ref.read(mobileSyncControllerProvider.notifier);
    await coordinator.initializeForOwner(ownerId);
    await coordinator.synchronize(trigger: trigger);
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        key: const Key('mobile-primary-navigation'),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: <NavigationDestination>[
          for (final destination in MobileDestination.values)
            NavigationDestination(
              key: Key('mobile-destination-${destination.name}'),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}
