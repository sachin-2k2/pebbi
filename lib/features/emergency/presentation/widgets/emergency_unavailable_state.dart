import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Fallback state displayed when the user's active target language has unreviewed phrases.
///
/// Follows AGENTS.md §3: Clean fallback with mascot and Back button.
class EmergencyUnavailableState extends StatelessWidget {
  const EmergencyUnavailableState({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PebbiMascot(
            size: 72.0,
            expression: PebbiExpression.surprised,
            accentColor: AppColors.brandPurple,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            AppStrings.emergencyPhrasesNotReadyTitle,
            style: AppTypography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            AppStrings.emergencyPhrasesNotReadySubtitle,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Button3D.secondary(
            label: AppStrings.backToMissions,
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
