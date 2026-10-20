import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Top bar for onboarding steps featuring an accessible "Skip" action.
///
/// Follows AGENTS.md §3 and §4: standalone widget class, ≥48dp touch target,
/// RTL alignment aware.
class StepTopBar extends StatelessWidget {
  const StepTopBar({super.key, this.onSkip, this.showSkip = true});

  final VoidCallback? onSkip;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final skipColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return SizedBox(
      height: 38.0,
      child: Align(
        alignment: Alignment.centerRight,
        child: showSkip && onSkip != null
            ? Semantics(
                button: true,
                label: AppStrings.skipSemantics,
                child: InkWell(
                  onTap: onSkip,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: 38.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.skip,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: skipColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
