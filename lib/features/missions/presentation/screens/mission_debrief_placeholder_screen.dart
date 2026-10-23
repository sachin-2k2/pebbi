import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/debrief_ref.dart';

/// Clearly marked placeholder screen for the role-play mission debrief.
///
/// Follows prompt instruction: "The DEBRIEF screen is NOT designed: use a clearly
/// marked placeholder that shows the raw summary. Do not build it."
class MissionDebriefPlaceholderScreen extends StatelessWidget {
  const MissionDebriefPlaceholderScreen({super.key, this.debriefRef});

  final DebriefRef? debriefRef;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final debrief = debriefRef;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 600.0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48.0), textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Debrief Placeholder',
                  style: AppTypography.screenTitle.copyWith(color: palette.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'TODO(question: Full debrief screen is not yet designed)',
                  style: AppTypography.bodyMedium.copyWith(color: palette.textMuted),
                  textAlign: TextAlign.center,
                ),
                if (debrief != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: palette.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session: ${debrief.sessionId}', style: AppTypography.caption),
                        Text('Turns count: ${debrief.turnsCount}', style: AppTypography.bodyMedium),
                        Text(
                          'Goals completed: ${debrief.completedGoalIds.length} of ${debrief.totalGoals}',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Button3D(
                  label: 'Return to Missions',
                  backgroundColor: palette.brand,
                  depthColor: palette.brandDepth,
                  textColor: palette.textOnBrand,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
