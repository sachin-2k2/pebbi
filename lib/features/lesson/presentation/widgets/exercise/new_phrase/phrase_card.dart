import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../domain/phrase_token.dart';
import 'speed_buttons.dart';
import 'tappable_phrase.dart';

/// Large white card with soft shadow displaying picture, phrase tokens, meaning, and speed controls.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class PhraseCard extends StatelessWidget {
  const PhraseCard({
    super.key,
    required this.picture,
    required this.tokens,
    required this.meaning,
    required this.savedTokenIds,
    required this.onTokenTap,
    required this.onNormal,
    required this.onSlow,
    this.isPlaying = false,
  });

  final String picture;
  final List<PhraseToken> tokens;
  final String meaning;
  final Set<String> savedTokenIds;
  final ValueChanged<PhraseToken> onTokenTap;
  final VoidCallback onNormal;
  final VoidCallback onSlow;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFF1F0F5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            picture,
            style: const TextStyle(fontSize: 48.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          TappablePhrase(
            tokens: tokens,
            savedTokenIds: savedTokenIds,
            onTokenTap: onTokenTap,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            meaning,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SpeedButtons(
            onNormal: onNormal,
            onSlow: onSlow,
            isPlaying: isPlaying,
          ),
        ],
      ),
    );
  }
}
