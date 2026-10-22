import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Soft lavender card on Screen B displaying the target phrase and "Hear it again" link.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines.
class SelfCheckCard extends StatelessWidget {
  const SelfCheckCard({
    super.key,
    required this.phrase,
    required this.meaning,
    this.helperLine,
    required this.onHearAgain,
  });

  final String phrase;
  final String meaning;
  final String? helperLine;
  final VoidCallback onHearAgain;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.45);
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phrase,
            style: AppTypography.cardTitle.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          if (helperLine != null && helperLine!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              helperLine!,
              style: AppTypography.caption.copyWith(
                color: AppColors.brandPurple,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            meaning,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          _HearAgainLink(onTap: onHearAgain),
        ],
      ),
    );
  }
}

class _HearAgainLink extends StatelessWidget {
  const _HearAgainLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.selfCheckHearAgainSemantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            'Hear it again',
            style: AppTypography.caption.copyWith(
              color: AppColors.brandPurple,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.brandPurple,
            ),
          ),
        ),
      ),
    );
  }
}
