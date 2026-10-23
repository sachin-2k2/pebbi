import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Row of pills for playing phrase audio at Normal or Slow rates.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines, 48dp tap target.
/// Uses compact pill width so Normal and Slow stay side-by-side.
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
          context: context,
          label: '🔊 ${AppStrings.speedNormal}',
          semanticLabel: AppStrings.speedNormalSemantics,
          onPressed: onNormal,
        ),
        _buildPillButton(
          context: context,
          label: '🐢 ${AppStrings.speedSlow}',
          semanticLabel: AppStrings.speedSlowSemantics,
          onPressed: onSlow,
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required BuildContext context,
    required String label,
    required String semanticLabel,
    required VoidCallback onPressed,
  }) {
    final palette = context.palette;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0, minWidth: 96.0),
      child: Material(
        color: palette.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: palette.outline),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  button: true,
                  label: semanticLabel,
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
