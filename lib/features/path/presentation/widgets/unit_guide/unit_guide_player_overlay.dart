import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/guide_phrase.dart';
import 'mini_player_bar.dart';

/// Floating mini player overlay pinned to the bottom of the guidebook sheet.
///
/// Follows AGENTS.md §3: under 100 lines, isolates player bar positioning.
class UnitGuidePlayerOverlay extends StatelessWidget {
  const UnitGuidePlayerOverlay({
    super.key,
    required this.phrase,
    required this.currentIndex,
    required this.totalPhrases,
    required this.onStopPressed,
  });

  final GuidePhrase phrase;
  final int currentIndex;
  final int totalPhrases;
  final VoidCallback onStopPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      child: MiniPlayerBar(
        phrase: phrase,
        currentIndex: currentIndex,
        totalPhrases: totalPhrases,
        onStopPressed: onStopPressed,
      ),
    );
  }
}
