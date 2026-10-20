import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Horizontal divider with centered "OR" label.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, WCAG AA compliant muted text.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.borderLight, thickness: 1.0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppStrings.orDivider,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.dividerText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.borderLight, thickness: 1.0),
        ),
      ],
    );
  }
}
