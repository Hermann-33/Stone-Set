import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/mobile_destination.dart';

class MobileAuthenticatedShell extends StatelessWidget {
  const MobileAuthenticatedShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
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
