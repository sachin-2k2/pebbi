import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Row of stat capsules highlighting stars, completed goals, and conversation turns.
///
/// Follows AGENTS.md §3 (< 100 lines, build < 50 lines).
class DebriefRewardsRow extends StatelessWidget {
  const DebriefRewardsRow({
    super.key,
    required this.starsEarned,
    required this.completedGoalsCount,
    required this.totalGoalsCount,
    required this.turnsCount,
  });

  final int starsEarned;
  final int completedGoalsCount;
  final int totalGoalsCount;
  final int turnsCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: '⭐',
            value: '+$starsEarned',
            label: 'Stars',
            palette: palette,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            icon: '🎯',
            value: '$completedGoalsCount/$totalGoalsCount',
            label: 'Goals Hit',
            palette: palette,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            icon: '💬',
            value: '$turnsCount',
            label: 'Turns',
            palette: palette,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.palette,
  });

  final String icon;
  final String value;
  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.outline, width: 1.0),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: palette.textMuted,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }
}
