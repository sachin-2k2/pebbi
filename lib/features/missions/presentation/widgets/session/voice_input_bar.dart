import 'package:flutter/material.dart';
import '../../../../lesson/presentation/widgets/exercise/speaking/level_dots.dart';
import '../../../../lesson/presentation/widgets/exercise/speaking/mic_button.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Voice mode input bar: round [MicButton], audio [LevelDots], and a "Type instead" toggle.
///
/// Follows AGENTS.md §8 & §13:
/// - Reuses existing [MicButton] and [LevelDots] from lesson feature
/// - Populates speech into editable draft without auto-sending
/// - TODO(question: voice mode layout is estimated)
class VoiceInputBar extends StatelessWidget {
  const VoiceInputBar({
    super.key,
    required this.isListening,
    required this.onMicTap,
    required this.onTypeInsteadTap,
    this.soundLevel = 0.0,
  });

  final bool isListening;
  final VoidCallback onMicTap;
  final VoidCallback onTypeInsteadTap;
  final double soundLevel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MicButton(
                isListening: isListening,
                onPressed: onMicTap,
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 140.0,
                child: LevelDots(
                  soundLevel: soundLevel,
                  isListening: isListening,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: onTypeInsteadTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(48.0, 48.0),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text(
              AppStrings.sessionTypeInstead,
              style: AppTypography.caption.copyWith(
                color: palette.brand,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
