import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Row of three secondary utility actions sitting below the input bar.
///
/// Follows AGENTS.md §4.6 & §8:
/// - 48dp minimum tap target for all three links
/// - Wraps gracefully onto two lines at 200% text scale
class SessionFooterLinks extends StatelessWidget {
  const SessionFooterLinks({
    super.key,
    required this.captionsOn,
    required this.onSayInMyLanguageTap,
    required this.onCaptionsToggle,
    required this.onFinishTap,
  });

  final bool captionsOn;
  final VoidCallback onSayInMyLanguageTap;
  final VoidCallback onCaptionsToggle;
  final VoidCallback onFinishTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final sayInMyLanguageLink = TextButton(
      onPressed: onSayInMyLanguageTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(48.0, 48.0),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      child: Text(
        AppStrings.sessionSayInMyLanguage,
        style: AppTypography.caption.copyWith(
          color: palette.brand,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );

    final captionsToggle = TextButton.icon(
      onPressed: onCaptionsToggle,
      style: TextButton.styleFrom(
        minimumSize: const Size(48.0, 48.0),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      icon: Icon(
        Icons.subtitles_rounded,
        size: 16.0,
        color: palette.textMuted,
      ),
      label: Text(
        captionsOn ? AppStrings.sessionCaptionsOn : AppStrings.sessionCaptionsOff,
        style: AppTypography.caption.copyWith(
          color: palette.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final finishLink = TextButton(
      onPressed: onFinishTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(48.0, 48.0),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      child: Text(
        AppStrings.sessionFinishAndDebrief,
        style: AppTypography.caption.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            sayInMyLanguageLink,
            captionsToggle,
            finishLink,
          ],
        ),
      ),
    );
  }
}
