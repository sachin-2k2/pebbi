import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Soft info-toned correction note rendered under a user bubble in Live correction mode.
///
/// Follows AGENTS.md §7.3 & §11:
/// - Uses semantic info palette tokens (no shame wording or harsh red)
class CorrectionNote extends StatelessWidget {
  const CorrectionNote({super.key, required this.correction});

  final String correction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final trimmed = correction.trim();
    final displayText = trimmed.startsWith('💡') ||
            trimmed.toLowerCase().startsWith('tip:') ||
            trimmed.toLowerCase().startsWith('better:')
        ? trimmed
        : '${AppStrings.sessionLiveCorrectionPrefix}$trimmed';

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
        displayText,
        style: AppTypography.caption.copyWith(
          color: palette.infoText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
