import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../models/dashboard_destination.dart';

class DashboardDestinationPlaceholder extends StatelessWidget {
  const DashboardDestinationPlaceholder({
    required this.destination,
    this.fixtureId,
    super.key,
  });

  final DashboardDestination destination;
  final String? fixtureId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        key: PageStorageKey<String>('dashboard-${destination.name}-$fixtureId'),
        padding: const EdgeInsets.all(StoneSetSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: StoneSetStatePanel(
              icon: destination.icon,
              title: fixtureId == null ? destination.label : '${destination.label} preview',
              message: fixtureId == null
                  ? destination.description
                  : '${destination.description} Selected fixture: $fixtureId. No product record was loaded.',
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardUnauthorizedView extends StatelessWidget {
  const DashboardUnauthorizedView({
    this.message = 'You do not have permission to open this dashboard preview.',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) => _SafeStateView(
    icon: Icons.lock_outline,
    title: 'Access unavailable',
    message: message,
  );
}

class DashboardSafeErrorView extends StatelessWidget {
  const DashboardSafeErrorView({
    this.message = 'This dashboard page could not be opened. No saved work was changed.',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) => _SafeStateView(
    icon: Icons.error_outline,
    title: 'Something went wrong',
    message: message,
  );
}

class _SafeStateView extends StatelessWidget {
  const _SafeStateView({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: StoneSetStatePanel(icon: icon, title: title, message: message),
          ),
        ),
      ),
    );
  }
}
