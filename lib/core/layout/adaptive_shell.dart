import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/shell/app_nav_rail.dart';
import '../../app/shell/app_tab_bar.dart';
import '../network/network_status_provider.dart';
import 'window_class.dart';

/// Responsive shell that swaps between [AppTabBar] on compact screens
/// and [AppNavRail] on medium and expanded screens.
/// Displays [OfflineNoticeBanner] when connection is lost (Rule 3).
class AdaptiveShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    if (context.isCompact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTabBar(
              currentIndex: currentIndex,
              onTap: onDestinationSelected,
              includeBottomSafeArea: !isOffline,
            ),
            if (isOffline) const OfflineNoticeBanner(),
          ],
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
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                if (isOffline) const OfflineNoticeBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
