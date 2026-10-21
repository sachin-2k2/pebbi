import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Thin progress bar rendered on badge cards with an active target.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class BadgeProgressBar extends StatelessWidget {
  const BadgeProgressBar({super.key, required this.progressRatio});

  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.8);
    final fillColor = progressRatio > 0.0
        ? AppColors.textTertiary
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs + 2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: LinearProgressIndicator(
          value: progressRatio,
          minHeight: 5.0,
          backgroundColor: trackColor,
          valueColor: AlwaysStoppedAnimation<Color>(fillColor),
        ),
      ),
    );
  }
}
