import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Single white pill chip displaying an activity highlight.
///
/// Follows AGENTS.md §3 and §4: flexible sizing, token-based spacing,
/// supports text scaling up to 200% without clipping.
class WelcomeChip extends StatelessWidget {
  const WelcomeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textStyle = AppTypography.bodyMedium.copyWith(
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2.0,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081E1647),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(label, style: textStyle, textAlign: TextAlign.center),
    );
  }
}
