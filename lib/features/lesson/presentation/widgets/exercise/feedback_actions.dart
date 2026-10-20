import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../providers/exercise_session_state.dart';
import 'why_link.dart';

/// Action row in feedback panel:
/// "Why?" underlined link on left + Mint/Purple "Continue" 3D button on right.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum targets, mint continue for correct, purple continue for wrong.
class FeedbackActions extends StatelessWidget {
  const FeedbackActions({
    super.key,
    required this.kind,
    required this.onContinue,
    required this.onWhy,
  });

  final FeedbackKind kind;
  final VoidCallback onContinue;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) {
    final isCorrect = kind == FeedbackKind.correct;
    final btnBg = isCorrect ? AppColors.mint : AppColors.brandPurple;
    final btnDepth = isCorrect
        ? AppColors.mintDepth
        : AppColors.brandPurpleDepth;

    return Row(
      children: [
        WhyLink(onPressed: onWhy),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Button3D(
            label: AppStrings.continueExercise,
            backgroundColor: btnBg,
            depthColor: btnDepth,
            textColor: Colors.white,
            isFullWidth: true,
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}
