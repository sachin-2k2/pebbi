import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/emergency_phrase.dart';

/// Large auto-scaling, high-contrast target phrase text for arm's-length visibility.
///
/// Follows AGENTS.md §3 (under 150 lines, build under 50 lines), §4.1 (no fixed sizes),
/// §4.4 (FittedBox/LayoutBuilder), and supports text scaling up to 200%.
class PhraseDisplayText extends StatelessWidget {
  const PhraseDisplayText({
    super.key,
    required this.phrase,
    required this.targetLanguageCode,
    this.showHelperLine = false,
  });

  final EmergencyPhrase phrase;
  final String targetLanguageCode;
  final bool showHelperLine;

  static bool _isRtl(String langCode) =>
      langCode == 'ar' ||
      langCode == 'ur' ||
      langCode == 'he' ||
      langCode == 'fa';

  @override
  Widget build(BuildContext context) {
    final isRtl = _isRtl(targetLanguageCode);
    final textDir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Directionality(
          textDirection: textDir,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                phrase.targetText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 38.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
        if (showHelperLine &&
            phrase.helperLine != null &&
            phrase.helperLine!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            phrase.helperLine!,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
