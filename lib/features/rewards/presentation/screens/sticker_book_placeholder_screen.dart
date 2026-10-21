import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder screen for the upcoming Sticker Book feature.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §7.2.
class StickerBookPlaceholderScreen extends StatelessWidget {
  const StickerBookPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              BackLink(
                label: 'Rewards',
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/rewards');
                  }
                },
              ),
              const Expanded(
                child: Center(
                  child: EmptyState(
                    illustration: PebbiMascot(
                      size: 64.0,
                      expression: PebbiExpression.winking,
                    ),
                    title: AppStrings.rewardsStickerBookPlaceholderTitle,
                    subtitle: AppStrings.rewardsStickerBookPlaceholderSubtitle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
