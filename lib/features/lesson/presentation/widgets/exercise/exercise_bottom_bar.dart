import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/layout/content_width_limiter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../providers/exercise_session_state.dart';
import 'check_button.dart';
import 'hint_button.dart';

/// Pinned bottom bar adapting to [BottomBarMode] (check, gotIt, none).
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// centered max-width content on tablets, thin top divider.
class ExerciseBottomBar extends StatelessWidget {
  const ExerciseBottomBar({
    super.key,
    this.mode = BottomBarMode.check,
    this.canCheck = false,
    this.canUseHint = false,
    this.onCheck,
    this.onHint,
    this.onGotIt,
    this.showHint = true,
  });

  final BottomBarMode mode;
  final bool canCheck;
  final bool canUseHint;
  final VoidCallback? onCheck;
  final VoidCallback? onHint;
  final VoidCallback? onGotIt;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    if (mode == BottomBarMode.none) {
      return const SizedBox.shrink();
    }

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
          child: mode == BottomBarMode.gotIt ? _buildGotIt() : _buildCheck(),
        ),
      ),
    );
  }

  Widget _buildGotIt() {
    return Button3D(
      label: AppStrings.gotIt,
      backgroundColor: AppColors.mint,
      depthColor: AppColors.mintDepth,
      textColor: Colors.white,
      onPressed: onGotIt,
    );
  }

  Widget _buildCheck() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHint && onHint != null) ...[
          HintButton(onPressed: onHint!, isEnabled: canUseHint),
          const SizedBox(height: AppSpacing.xs),
        ],
        CheckButton(onPressed: canCheck ? onCheck : null, isEnabled: canCheck),
      ],
    );
  }
}
