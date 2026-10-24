import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_palette.dart';
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
    final palette = context.palette;
    final effectiveOverline = overline ?? AppStrings.continueLessonOverline;

    return Semantics(
      button: true,
      label: '$effectiveOverline: $title, $subtitle',
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        elevation: 0,
        child: InkWell(
          onTap: onPlayPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: palette.outline),
              boxShadow: palette.cardShadow,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Mascot Icon Tile
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: palette.tintLavender,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusIconTile,
                    ),
                  ),
                  child: Center(
                    child: PebbiMascot(size: 38.0, accentColor: palette.brand),
                  ),
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
                        style: AppTypography.cardOverline.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        title,
                        style: AppTypography.cardTitle.copyWith(
                          color: palette.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: palette.textMuted,
                        ),
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
                  backgroundColor: palette.mint,
                  depthColor: palette.mintDepth,
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    color: palette.textOnBrand,
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
