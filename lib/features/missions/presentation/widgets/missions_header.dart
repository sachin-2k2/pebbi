import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Missions screen top header with backpack mascot, title, and subtitle.
///
/// Follows AGENTS.md §3 (modular, under 150 lines) and §4 (responsive).
class MissionsHeader extends StatelessWidget {
  const MissionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      header: true,
      label: '${AppStrings.missionsTitle}. ${AppStrings.missionsSubtitle}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: PebbiMascot(
                size: 48.0,
                outfit: PebbiOutfit.backpack,
                accentColor: palette.brand,
                expression: PebbiExpression.happy,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.missionsTitle,
                    style: AppTypography.screenTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    AppStrings.missionsSubtitle,
                    style: AppTypography.caption.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
