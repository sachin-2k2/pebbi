import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import 'splash_config.dart';

/// Three small horizontal pill dashes representing the splash startup indicator.
///
/// Follows AGENTS.md §2, §3 (< 150 lines), §4, and User Rules 1–8:
/// - Excluded from screen readers (ExcludeSemantics).
/// - Enclosed in ONE [RepaintBoundary] so dash animations do not trigger parent repaints.
/// - When reduceMotion is active: all 3 dashes use [AppPalette.splashForegroundMuted].
/// - When animated: smooth 80ms cross-fade between dashes without AnimatedContainer.
class SplashLoadingDashes extends StatelessWidget {
  const SplashLoadingDashes({
    super.key,
    required this.animation,
    this.reduceMotion = false,
  });

  final Animation<double> animation;
  final bool reduceMotion;

  /// Calculates the active lit weight [0.0, 1.0] for dash at [index].
  static double calculateDashWeight(int index, double progress) {
    // Each dash owns a slot of 1.0 in normalized slot space [0, 3).
    // Transition cross-fade duration in slot space: 80ms / 200ms = 0.4 slots.
    const fadeSlot = 80.0 / 200.0;

    final currentSlot = (progress * 3.0) % 3.0;
    double diff = currentSlot - index;
    while (diff < -1.5) {
      diff += 3.0;
    }
    while (diff > 1.5) {
      diff -= 3.0;
    }

    if (diff >= -fadeSlot && diff < 0.0) {
      return ((diff + fadeSlot) / fadeSlot).clamp(0.0, 1.0);
    } else if (diff >= 0.0 && diff < (1.0 - fadeSlot)) {
      return 1.0;
    } else if (diff >= (1.0 - fadeSlot) && diff < 1.0) {
      return ((1.0 - diff) / fadeSlot).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final p = animation.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: SplashConfig.dashSpacing),
                  Container(
                    width: SplashConfig.dashWidth,
                    height: SplashConfig.dashHeight,
                    decoration: BoxDecoration(
                      color: reduceMotion
                          ? palette.splashForegroundMuted
                          : Color.lerp(
                              palette.splashDashDim,
                              palette.splashDashLit,
                              calculateDashWeight(i, p),
                            ),
                      borderRadius: BorderRadius.circular(
                        SplashConfig.dashHeight / 2,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
