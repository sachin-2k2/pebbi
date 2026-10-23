import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Modal sheet disclosing AI character identity and safety recommendations.
///
/// Follows AGENTS.md §14:
/// - Mandatory transparency disclosure for conversational AI characters
/// - TODO(question: AI disclosure text for legal/AI-team review)
class AiDisclosureSheet extends StatelessWidget {
  const AiDisclosureSheet({super.key, required this.characterName});

  final String characterName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.aiDisclosureTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: palette.infoSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: palette.infoBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 24.0)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      AppStrings.aiDisclosureBody(characterName),
                      style: AppTypography.bodyMedium.copyWith(
                        color: palette.infoText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Button3D(
              label: AppStrings.close,
              backgroundColor: palette.brand,
              depthColor: palette.brandDepth,
              textColor: palette.textOnBrand,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
