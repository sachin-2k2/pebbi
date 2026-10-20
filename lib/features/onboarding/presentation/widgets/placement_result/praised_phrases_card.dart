import 'package:flutter/material.dart';
import '../../../../../core/design_system/benefit_chip.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Card displaying target-language phrases answered correctly on first try.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// wraps chips flexibly, completely hidden when [phrases] is empty.
class PraisedPhrasesCard extends StatelessWidget {
  const PraisedPhrasesCard({
    super.key,
    required this.phrases,
    this.textDirection = TextDirection.ltr,
  });

  final List<String> phrases;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.alreadySaidRightTitle,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Directionality(
            textDirection: textDirection,
            child: Wrap(
              spacing: AppSpacing.xs + 2.0,
              runSpacing: AppSpacing.xs + 2.0,
              children: [
                for (final phrase in phrases)
                  BenefitChip(
                    label: phrase,
                    tone: ChipTone.mint,
                    showDefaultIcon: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
