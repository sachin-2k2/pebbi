import 'package:flutter/material.dart';
import '../../../../../core/layout/content_width_limiter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'check_button.dart';
import 'hint_button.dart';

/// Pinned bottom bar displaying the Hint button and full-width Check button.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// centered max-width content on tablets, thin top divider.
class ExerciseBottomBar extends StatelessWidget {
  const ExerciseBottomBar({
    super.key,
    required this.canCheck,
    required this.canUseHint,
    required this.onCheck,
    required this.onHint,
    this.showHint = true,
  });

  final bool canCheck;
  final bool canUseHint;
  final VoidCallback onCheck;
  final VoidCallback onHint;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: dividerColor, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: ContentWidthLimiter(
          maxWidth: AppSpacing.maxContentWidthCompact,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHint) ...[
                HintButton(onPressed: onHint, isEnabled: canUseHint),
                const SizedBox(height: AppSpacing.xs),
              ],
              CheckButton(
                onPressed: canCheck ? onCheck : null,
                isEnabled: canCheck,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
