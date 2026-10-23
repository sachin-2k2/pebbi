import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Animated thin progress bar with a small visible cap at zero progress and mint fill.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// respects RTL mirroring and smoothly animates state changes.
class ExerciseProgressBar extends StatelessWidget {
  const ExerciseProgressBar({
    super.key,
    required this.progress,
    this.height = 7.0,
    this.minCapFactor = 0.04,
  });

  /// Target progress value between 0.0 and 1.0.
  final double progress;

  final double height;
  final double minCapFactor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Ensures a small visible cap is shown even at 0% per design spec
    final effectiveProgress = progress.clamp(minCapFactor, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        height: height,
        color: palette.progressTrack,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: minCapFactor, end: effectiveProgress),
          builder: (context, value, _) {
            return FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: palette.mint,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
