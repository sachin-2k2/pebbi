import 'package:flutter/material.dart';
import '../../../../../core/design_system/icon_tile.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Top header block for Mission Brief: rounded peach emoji icon tile, bold title, and character line.
///
/// Follows AGENTS.md §3 & §8:
/// - Semantic heading semantics for accessibility screen readers
/// - Clamped responsive tile and WCAG AA compliant muted text
class BriefHeader extends StatelessWidget {
  const BriefHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.characterName,
    required this.characterRole,
  });

  final String emoji;
  final String title;
  final String characterName;
  final String characterRole;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconTile.emoji(
          emoji,
          backgroundColor: palette.coralTint,
          size: 56.0,
          fontSize: 28.0,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.screenTitle.copyWith(
                    color: palette.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$characterName, $characterRole',
                style: AppTypography.bodyMedium.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
