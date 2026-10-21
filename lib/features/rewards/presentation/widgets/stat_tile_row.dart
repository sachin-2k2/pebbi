import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import 'stat_tile.dart';

/// Row of three equal-width stat tiles for stops done, phrases, and stars.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class StatTileRow extends StatelessWidget {
  const StatTileRow({
    super.key,
    required this.stopsDone,
    required this.phrasesMet,
    required this.stars,
  });

  final int stopsDone;
  final int phrasesMet;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: stopsDone,
            label: AppStrings.rewardsStopsDoneLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2.0),
        Expanded(
          child: StatTile(
            value: phrasesMet,
            label: AppStrings.rewardsPhrasesLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2.0),
        Expanded(
          child: StatTile(value: stars, label: AppStrings.rewardsStarsLabel),
        ),
      ],
    );
  }
}
