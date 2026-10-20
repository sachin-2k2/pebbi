import 'package:flutter/material.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/design_system/ring.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/features/onboarding/domain/path_ready_config.dart';
import 'package:peddi/l10n/app_strings.dart';

/// Hero circular progress ring displaying the animated preparation progress
/// and centered excited Pebbi mascot.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// clamped responsive boundaries (140dp - 200dp), thick rounded stroke.
class PathReadyRing extends StatelessWidget {
  const PathReadyRing({
    super.key,
    required this.progress,
    this.strokeWidth = PathReadyConfig.ringStrokeWidth,
  });

  final double progress;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final ringDiameter = (screenHeight * 0.22).clamp(
      PathReadyConfig.minRingDiameter,
      PathReadyConfig.maxRingDiameter,
    );
    final mascotSize = (ringDiameter * 0.58).clamp(80.0, 116.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Ring(
        progress: progress,
        size: ringDiameter,
        strokeWidth: strokeWidth,
        color: AppColors.brandPurple,
        strokeCap: StrokeCap.round,
        semanticsLabel: AppStrings.ringProgressSemantics(
          (progress * 100).round(),
        ),
        child: ExcludeSemantics(
          child: PebbiMascot(
            size: mascotSize,
            accentColor: AppColors.brandPurple,
            expression: PebbiExpression.surprised,
          ),
        ),
      ),
    );
  }
}
