import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Renders the target phrase with support for RTL languages and optional transliteration.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// respects target language text direction and helper line setting.
class PhraseText extends StatelessWidget {
  const PhraseText({
    super.key,
    required this.phrase,
    required this.locale,
    this.helperLine,
    this.showHelperLine = false,
  });

  final String phrase;
  final String locale;
  final String? helperLine;
  final bool showHelperLine;

  bool get _isRtl => locale.toLowerCase().startsWith('ar');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasHelper =
        showHelperLine && helperLine != null && helperLine!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              phrase,
              textAlign: TextAlign.center,
              style: AppTypography.display.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (hasHelper) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              helperLine!,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
