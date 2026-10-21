import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/layout/two_pane_layout.dart';
import '../../../../core/layout/window_class.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/rewards_provider.dart';
import '../widgets/rewards_left_pane.dart';
import '../widgets/rewards_right_pane.dart';

/// Gamification and Rewards screen (4th tab of the AdaptiveShell).
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.3 (TwoPane on Expanded).
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  void _scrollToCalendar(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(rewardsSummaryProvider);
    final calendarKey = ref.read(calendarScrollKeyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(rewardsSummaryProvider),
              child: const Text('Failed to load rewards. Tap to retry.'),
            ),
          ),
          data: (summary) {
            final leftPane = RewardsLeftPane(
              summary: summary,
              calendarKey: calendarKey,
              onSettingsPressed: () => context.push('/settings'),
              onCalendarPressed: () => _scrollToCalendar(calendarKey),
            );
            final rightPane = RewardsRightPane(
              summary: summary,
              onOpenStickerBook: () => context.push('/rewards/sticker-book'),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: ContentWidthLimiter(
                maxWidth: 1040.0,
                child: Column(
                  children: [
                    if (context.isExpanded)
                      TwoPaneLayout(
                        primaryPane: leftPane,
                        secondaryPane: rightPane,
                        spacing: AppSpacing.lg,
                      )
                    else ...[
                      leftPane,
                      const SizedBox(height: AppSpacing.md),
                      rightPane,
                    ],
                    const SizedBox(height: AppSpacing.xl * 2),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
