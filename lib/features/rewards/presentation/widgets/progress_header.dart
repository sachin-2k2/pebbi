import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import 'level_badge.dart';

/// Top progress header displaying mascot with level badge, titles, and settings button.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.targetLanguage,
    required this.level,
    required this.outfitName,
    required this.onSettingsPressed,
  });

  final String targetLanguage;
  final int level;
  final String outfitName;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;
    final gearBg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.7);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const PebbiMascot(
              size: 58.0,
              outfit: PebbiOutfit.scarf,
              expression: PebbiExpression.happy,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: LevelBadge(level: level, size: 22.0),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.rewardsTitle,
                style: AppTypography.screenTitle.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 22.0,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                AppStrings.rewardsSubtitle(targetLanguage, level, outfitName),
                style: AppTypography.caption.copyWith(
                  color: subtitleColor,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Semantics(
          label: AppStrings.rewardsSettingsSemantics,
          button: true,
          child: InkWell(
            onTap: onSettingsPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: Container(
              width: 48.0,
              height: 48.0,
              alignment: Alignment.center,
              child: Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: gearBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 20.0,
                  color: subtitleColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
