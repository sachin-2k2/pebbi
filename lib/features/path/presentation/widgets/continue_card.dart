import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// "Continue" lesson action card with mascot tile, title, and mint 3D play button.
class ContinueCard extends StatelessWidget {
  const ContinueCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlayPressed,
    this.overline,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPlayPressed;
  final String? overline;

  @override
  Widget build(BuildContext context) {
    final effectiveOverline = overline ?? AppStrings.continueLessonOverline;

    return Semantics(
      button: true,
      label: '$effectiveOverline: $title, $subtitle',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        elevation: 0,
        child: InkWell(
          onTap: onPlayPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: AppSpacing.cardShadow,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Mascot Icon Tile
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: AppColors.tintLavender,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusIconTile,
                    ),
                  ),
                  child: const Center(child: PebbiMascot(size: 38.0)),
                ),
                const SizedBox(width: AppSpacing.md),

                // Titles Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        effectiveOverline,
                        style: AppTypography.cardOverline,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        title,
                        style: AppTypography.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Round Mint 3D Play Button
                Button3D(
                  label: '',
                  onPressed: onPlayPressed,
                  isFullWidth: false,
                  width: 48.0,
                  minHeight: 48.0,
                  padding: EdgeInsets.zero,
                  borderRadius: AppSpacing.radiusPill,
                  backgroundColor: AppColors.mint,
                  depthColor: AppColors.mintDepth,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28.0,
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
