import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Animated page indicator dots where the active page widens into a pill.
///
/// Follows AGENTS.md §3 and §4: accessible semantics, token-driven colors,
/// smooth micro-animation.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
    this.activeColor = AppColors.brandPurple,
  });

  final int currentIndex;
  final int pageCount;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkBorder : AppColors.disabled;

    return Semantics(
      label: AppStrings.pageIndicatorSemantics(currentIndex + 1, pageCount),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: isActive ? 28.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          );
        }),
      ),
    );
  }
}
