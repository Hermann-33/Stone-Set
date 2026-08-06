import 'package:flutter/material.dart';

enum MobileDestination {
  home(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
  week(
    label: 'Week',
    icon: Icons.calendar_view_week_outlined,
    selectedIcon: Icons.calendar_view_week,
  ),
  progress(
    label: 'Progress',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
  ),
  profile(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  );

  const MobileDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
