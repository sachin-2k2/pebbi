import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../lesson/presentation/widgets/exercise/audio_play_button.dart';

/// Navigation and audio controls for the emergency phrasebook pager.
///
/// Follows AGENTS.md §3 (<150 lines):
/// - Previous/Next buttons for the 8-phrase index navigation.
/// - Large "Play out loud" button utilizing on-device TTS.
class ShowScreenControls extends StatelessWidget {
  const ShowScreenControls({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onPlay,
    required this.hasPrev,
    required this.hasNext,
    required this.isPlaying,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPlay;
  final bool hasPrev;
  final bool hasNext;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        IconButton(
          iconSize: 32.0,
          tooltip: 'Previous phrase',
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: hasPrev
                ? AppColors.brandPurple
                : AppColors.textMuted.withAlpha(70),
          ),
          onPressed: hasPrev ? onPrev : null,
        ),
        const SizedBox(width: AppSpacing.lg),
        // Play Out Loud Button
        AudioPlayButton(
          isPlaying: isPlaying,
          onPressed: onPlay,
        ),
        const SizedBox(width: AppSpacing.lg),
        // Next Button
        IconButton(
          iconSize: 32.0,
          tooltip: 'Next phrase',
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: hasNext
                ? AppColors.brandPurple
                : AppColors.textMuted.withAlpha(70),
          ),
          onPressed: hasNext ? onNext : null,
        ),
      ],
    );
  }
}

