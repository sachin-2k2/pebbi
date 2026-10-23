import 'package:flutter/material.dart';
import '../../core/layout/window_class.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import 'nav_destination_item.dart';

/// Side navigation rail for medium (tablets) and expanded screens.
class AppNavRail extends StatelessWidget {
  const AppNavRail({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.isExpanded;
    final palette = context.palette;

    return NavigationRail(
      extended: isExpanded,
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: palette.navRailBackground,
      indicatorColor: palette.tabBarIndicator,
      minWidth: 72.0,
      minExtendedWidth: 190.0,
      unselectedIconTheme: IconThemeData(color: palette.textMuted),
      selectedIconTheme: IconThemeData(color: palette.brandText),
      unselectedLabelTextStyle: TextStyle(
        color: palette.textMuted,
        fontWeight: FontWeight.w500,
        fontSize: 13.0,
      ),
      selectedLabelTextStyle: TextStyle(
        color: palette.brandText,
        fontWeight: FontWeight.w700,
        fontSize: 13.0,
      ),
      destinations: NavDestinationItem.values.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        );
      }).toList(),
    );
  }
}
