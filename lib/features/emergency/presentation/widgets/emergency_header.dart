import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Screen header with purple Pebbi mascot, green badge slot, title, and subtitle.
///
/// Follows AGENTS.md §3 (under 150 lines) and §4 (responsive).
class EmergencyHeader extends StatelessWidget {
  const EmergencyHeader({super.key, this.badgeSlot});

  /// Optional badge widget placed below the mascot (e.g. green health/safety badge).
  final Widget? badgeSlot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label:
          '${AppStrings.emergencyPhrasebookTitle}. ${AppStrings.emergencyPhrasebookSubtitle}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mascot with small badge slot below
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ExcludeSemantics(
                  child: PebbiMascot(
                    size: 48.0,
                    accentColor: AppColors.brandPurple,
                    expression: PebbiExpression.happy,
                  ),
                ),
                const SizedBox(height: 2.0),
                badgeSlot ??
                    Container(
                      width: 14.0,
                      height: 14.0,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 10.0,
                        color: Colors.white,
                      ),
                    ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    AppStrings.emergencyPhrasebookTitle,
                    style: AppTypography.screenTitle,
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    AppStrings.emergencyPhrasebookSubtitle,
                    style: AppTypography.caption,
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
