import 'package:flutter/material.dart';
import '../../app/shell/app_nav_rail.dart';
import '../../app/shell/app_tab_bar.dart';
import 'window_class.dart';

/// Responsive shell that swaps between [AppTabBar] on compact screens
/// and [AppNavRail] on medium and expanded screens.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: AppTabBar(
          currentIndex: currentIndex,
          onTap: onDestinationSelected,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AppNavRail(
            currentIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
