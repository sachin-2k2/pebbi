import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Screen header with large bold 2-line title and dynamic language subtitle.
///
/// Follows AGENTS.md §3 (<100 lines) & WCAG AA contrast.
class FreeTalkHeader extends StatelessWidget {
  const FreeTalkHeader({super.key, required this.targetLanguageName});

  final String targetLanguageName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final primaryTextColor = palette.textPrimary;
    final subtitleColor = palette.textMuted;

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.freeTalkScreenTitle,
            style: TextStyle(
              fontSize: 27.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.25,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.freeTalkScreenSubtitle(targetLanguageName),
            style: AppTypography.bodyMedium.copyWith(
              color: subtitleColor,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
