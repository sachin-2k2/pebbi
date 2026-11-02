import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Card displaying translated phrase with "Hear it" (TTS) and "Use this" actions.
///
/// Follows AGENTS.md §3 (< 150 lines, build < 50 lines).
class SayInMyLanguageResultCard extends StatelessWidget {
  const SayInMyLanguageResultCard({
    super.key,
    required this.translatedText,
    required this.onPlayAudio,
    required this.onUseThis,
  });

  final String translatedText;
  final ValueChanged<String> onPlayAudio;
  final ValueChanged<String> onUseThis;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.brandTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.brand, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translatedText,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => onPlayAudio(translatedText),
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: palette.brand,
                  size: 18.0,
                ),
                label: Text(
                  AppStrings.sayInMyLanguageHearIt,
                  style: TextStyle(
                    color: palette.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Button3D(
                label: AppStrings.sayInMyLanguageUseThis,
                backgroundColor: palette.mint,
                depthColor: palette.mintDepth,
                textColor: palette.textOnBrand,
                isFullWidth: false,
                width: 140.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                onPressed: () => onUseThis(translatedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

