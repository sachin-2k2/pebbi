import 'package:flutter/material.dart';
import '../../../../../../core/design_system/button_3d.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Screen B actions: Mint 3D button ("I said it ✓ (half credit)") and "Skip for now" link.
///
/// Follows AGENTS.md §4.6: Flexible width, minimum 48dp tap target.
class SelfCheckActions extends StatelessWidget {
  const SelfCheckActions({
    super.key,
    required this.onSaidIt,
    required this.onSkip,
  });

  final VoidCallback onSaidIt;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skipColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: AppStrings.selfCheckSaidItSemantics,
          child: Button3D(
            label:
                '${AppStrings.selfCheckSaidItAction}  ${AppStrings.selfCheckHalfCreditLabel}',
            backgroundColor: AppColors.mint,
            depthColor: AppColors.mintDepth,
            textColor: Colors.white,
            onPressed: onSaidIt,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          button: true,
          label: AppStrings.selfCheckSkipSemantics,
          child: InkWell(
            onTap: onSkip,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                AppStrings.selfCheckSkipAction,
                style: AppTypography.caption.copyWith(
                  color: skipColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
