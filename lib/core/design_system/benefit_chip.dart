import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum ChipTone { purple, amber, mint }

/// Small tinted pill chip ("Bits") supporting multiple semantic tones.
///
/// Follows AGENTS.md §3, §4 & §8: under 100 lines, build under 50 lines,
/// flexible sizing, token-based spacing, WCAG AA compliant contrast.
class BenefitChip extends StatelessWidget {
  const BenefitChip({
    super.key,
    required this.label,
    this.tone = ChipTone.purple,
    this.icon,
    this.leading,
    this.showDefaultIcon = true,
  });

  final String label;
  final ChipTone tone;
  final IconData? icon;
  final Widget? leading;
  final bool showDefaultIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (bg, fg) = switch (tone) {
      ChipTone.purple => (
        isDark ? AppColors.darkSurfaceVariant : AppColors.chipPurpleBackground,
        isDark ? AppColors.darkChipPurpleText : AppColors.chipPurpleText,
      ),
      ChipTone.amber => (
        isDark ? AppColors.darkSurfaceVariant : AppColors.chipAmberBackground,
        isDark ? AppColors.darkChipAmberText : AppColors.chipAmberText,
      ),
      ChipTone.mint => (
        isDark ? AppColors.darkSurfaceVariant : AppColors.chipMintBackground,
        isDark ? AppColors.darkChipMintText : AppColors.chipMintText,
      ),
    };

    Widget? leadWidget = leading;
    if (leadWidget == null) {
      if (icon != null) {
        leadWidget = ExcludeSemantics(child: Icon(icon, size: 14.0, color: fg));
      } else if (showDefaultIcon && tone == ChipTone.purple) {
        leadWidget = ExcludeSemantics(
          child: Icon(Icons.auto_awesome, size: 14.0, color: fg),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 3.0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadWidget != null) ...[
            leadWidget,
            const SizedBox(width: AppSpacing.xs + 2.0),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
