import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Small centered muted helper line under the tip row.
///
/// Follows AGENTS.md §3 & §4: under 40 lines.
class PhrasebookHintText extends StatelessWidget {
  const PhrasebookHintText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.phrasebookHint,
      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
      textAlign: TextAlign.center,
    );
  }
}
