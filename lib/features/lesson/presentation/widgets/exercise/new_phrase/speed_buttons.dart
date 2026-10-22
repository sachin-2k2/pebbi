import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Row of pills for playing phrase audio at Normal or Slow rates.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines, 48dp tap target.
class SpeedButtons extends StatelessWidget {
  const SpeedButtons({
    super.key,
    required this.onNormal,
    required this.onSlow,
    this.isPlaying = false,
  });

  final VoidCallback onNormal;
  final VoidCallback onSlow;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _buildPillButton(
          label: '🔊 ${AppStrings.speedNormal}',
          semanticLabel: AppStrings.speedNormalSemantics,
          onPressed: onNormal,
        ),
        _buildPillButton(
          label: '🐢 ${AppStrings.speedSlow}',
          semanticLabel: AppStrings.speedSlowSemantics,
          onPressed: onSlow,
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required String label,
    required String semanticLabel,
    required VoidCallback onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0, minWidth: 96.0),
      child: Material(
        color: const Color(0xFFF1F0F5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Center(
              child: Semantics(
                button: true,
                label: semanticLabel,
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
