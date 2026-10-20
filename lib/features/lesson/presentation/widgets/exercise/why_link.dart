import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';

/// Underlined text link for opening the "Why?" answer explanation sheet.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum touch target, accessible semantics.
class WhyLink extends StatelessWidget {
  const WhyLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.whySemantics,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
              minWidth: AppSpacing.minTouchTarget,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Center(
                child: Text(
                  AppStrings.why,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
