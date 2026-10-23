import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Soft info-toned correction note rendered under a user bubble in Live correction mode.
///
/// Follows AGENTS.md §7.3 & §11:
/// - Uses semantic info palette tokens (no shame wording or harsh red)
/// - TODO(question: correction note styling estimated based on infoSurface tokens)
class CorrectionNote extends StatelessWidget {
  const CorrectionNote({super.key, required this.correction});

  final String correction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2.0,
      ),
      decoration: BoxDecoration(
        color: palette.infoSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: palette.infoBorder, width: 1.0),
      ),
      child: Text(
        '${AppStrings.sessionLiveCorrectionPrefix}$correction',
        style: AppTypography.caption.copyWith(
          color: palette.infoText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
