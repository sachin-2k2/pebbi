import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/correction_style.dart';

/// Animated helper line describing the active [CorrectionStyle] setting.
///
/// Follows AGENTS.md §3, WCAG AAA (9.4:1 contrast), and respects Reduce Motion.
class CorrectionHelperText extends StatelessWidget {
  const CorrectionHelperText({super.key, required this.style});

  final CorrectionStyle style;

  String _getHelperText(CorrectionStyle style) {
    switch (style) {
      case CorrectionStyle.gentle:
        return AppStrings.correctionHelperGentle;
      case CorrectionStyle.live:
        return AppStrings.correctionHelperLive;
      case CorrectionStyle.none:
        return AppStrings.correctionHelperNone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkCorrectionHelperText
        : AppColors.correctionHelperText;

    final text = _getHelperText(style);

    return Semantics(
      liveRegion: true,
      child: AnimatedSize(
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.topLeft,
        child: AnimatedSwitcher(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 200),
          child: Text(
            text,
            key: ValueKey<CorrectionStyle>(style),
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
