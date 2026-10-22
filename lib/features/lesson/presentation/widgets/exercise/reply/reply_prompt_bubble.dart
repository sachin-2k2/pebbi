import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Dialogue prompt row with speaker avatar tile and tappable speech bubble.
///
/// Follows AGENTS.md §3 & §4: under 90 lines, 48dp minimum tap target.
class ReplyPromptBubble extends StatelessWidget {
  const ReplyPromptBubble({
    super.key,
    required this.speakerEmoji,
    required this.promptLine,
    required this.onTapToHear,
  });

  final String speakerEmoji;
  final String promptLine;
  final VoidCallback onTapToHear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            alignment: Alignment.center,
            child: Text(speakerEmoji, style: const TextStyle(fontSize: 26.0)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Material(
              color: const Color(0xFFF0ECFD),
              borderRadius: BorderRadius.circular(16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.0),
                onTap: onTapToHear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: const Color(0xFFDDD6FE),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        promptLine,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            size: 14.0,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            AppStrings.tapToHearAgain,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
