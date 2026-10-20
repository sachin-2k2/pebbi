import 'package:flutter/material.dart';

/// Navigation destinations for the 5 main tabs per design specification.
enum NavDestinationItem {
  path(
    label: 'Path',
    icon: Icons.alt_route_rounded,
    selectedIcon: Icons.alt_route_rounded,
    location: '/path',
  ),
  missions(
    label: 'Missions',
    icon: Icons.forum_outlined,
    selectedIcon: Icons.forum_rounded,
    location: '/missions',
  ),
  review(
    label: 'Review',
    icon: Icons.sync_rounded,
    selectedIcon: Icons.sync_rounded,
    location: '/review',
  ),
  rewards(
    label: 'Rewards',
    icon: Icons.military_tech_outlined,
    selectedIcon: Icons.military_tech_rounded,
    location: '/rewards',
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    location: '/settings',
  );

  const NavDestinationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}
