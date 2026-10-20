import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/onboarding_config.dart';

/// Header row for onboarding setup steps:
/// circular back button + animated progress bar + "n/total" counter.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, min 48dp tap target,
/// RTL mirroring, accessible semantics, responsive padding.
class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = OnboardingConfig.totalSteps,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          _buildBackButton(context, isRtl),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildProgressBar(progress)),
          const SizedBox(width: AppSpacing.md),
          _buildStepCounter(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isRtl) {
    return Semantics(
      button: true,
      label: AppStrings.backSemantics,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            child: Icon(
              isRtl ? Icons.chevron_right : Icons.chevron_left,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double targetProgress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        height: 6.0,
        color: AppColors.borderLight,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: 0.0, end: targetProgress),
          builder: (context, value, _) {
            return FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandPurple,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepCounter(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      label: AppStrings.stepProgressSemantics(currentStep, totalSteps),
      child: Text(
        '$currentStep/$totalSteps',
        style: AppTypography.caption.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
