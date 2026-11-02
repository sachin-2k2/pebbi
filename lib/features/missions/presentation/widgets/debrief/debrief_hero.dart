import 'package:flutter/material.dart';
import '../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Celebratory hero banner for the mission debrief screen.
///
/// Follows AGENTS.md §3 & §8:
/// - Reusable, dumb widget (< 100 lines, build < 50 lines).
/// - Displays celebrating Pebbi mascot and success title.
class DebriefHero extends StatelessWidget {
  const DebriefHero({
    super.key,
    this.characterName,
  });

  final String? characterName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final partner = characterName != null && characterName!.isNotEmpty
        ? characterName!
        : 'Lucía';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PebbiMascot(
          size: 88.0,
          accentColor: palette.brand,
          expression: PebbiExpression.excited,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Mission Complete! 🎉',
          style: AppTypography.screenTitle.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Great conversation with $partner',
          style: AppTypography.bodyMedium.copyWith(
            color: palette.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
