import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Sheet shown when "Finish & debrief" is tapped before the user has sent any messages.
///
/// Follows AGENTS.md §12.
class FinishPromptSheet extends StatelessWidget {
  const FinishPromptSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await AdaptiveSheet.show<bool>(
      context: context,
      builder: (dialogCtx) => const FinishPromptSheet(),
    );
    return result ?? false;
  }

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
            Text(
              AppStrings.finishWithoutSpeakingTitle,
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.finishWithoutSpeakingBody,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Button3D(
              label: AppStrings.leaveSessionKeepGoing,
              backgroundColor: palette.brand,
              depthColor: palette.brandDepth,
              textColor: palette.textOnBrand,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(minimumSize: const Size(48.0, 48.0)),
              child: Text(
                AppStrings.leaveSessionLeave,
                style: AppTypography.bodyMedium.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
