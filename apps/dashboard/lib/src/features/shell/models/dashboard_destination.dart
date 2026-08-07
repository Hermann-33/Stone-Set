import 'package:flutter/material.dart';

enum DashboardDestination {
  overview(
    label: 'Overview',
    path: '/',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard,
    description: 'Attention items, resumable work, publication state, and recent activity.',
  ),
  routines(
    label: 'Routines',
    path: '/routines',
    icon: Icons.view_week_outlined,
    selectedIcon: Icons.view_week,
    description: 'Routine authoring arrives in a later approved implementation packet.',
  ),
  exercises(
    label: 'Exercises',
    path: '/exercises',
    icon: Icons.fitness_center_outlined,
    selectedIcon: Icons.fitness_center,
    description: 'Exercise and guidance authoring arrives in a later approved packet.',
  ),
  reviews(
    label: 'Reviews',
    path: '/reviews',
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
    description: 'Independent routine review arrives with the routine publication packet.',
  ),
  activity(
    label: 'Activity',
    path: '/activity',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    description: 'Authoritative activity history is not connected in this fixture-only preview.',
  ),
  settings(
    label: 'Settings',
    path: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    description: 'Product settings and export controls arrive in their owning packets.',
  );

  const DashboardDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.description,
  });

  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String description;
}
