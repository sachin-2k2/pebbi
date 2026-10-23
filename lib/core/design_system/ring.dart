import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// Reusable circular progress ring matching the Pebbi design system.
///
/// Follows AGENTS.md §3, §4 & §8: under 100 lines, build under 50 lines,
/// flexible sizing, rounded stroke ends, child slot, token-based colors.
class Ring extends StatelessWidget {
  const Ring({
    super.key,
    required this.progress,
    this.size = 180.0,
    this.strokeWidth = 12.0,
    this.color,
    this.trackColor,
    this.strokeCap = StrokeCap.round,
    this.child,
    this.semanticsLabel,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final StrokeCap strokeCap;
  final Widget? child;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveColor = color ?? palette.brand;
    final effectiveTrack = trackColor ?? palette.progressTrack;
    final clamped = progress.clamp(0.0, 1.0);

    return Semantics(
      value: semanticsLabel ?? '${(clamped * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: clamped,
                strokeWidth: strokeWidth,
                color: effectiveColor,
                trackColor: effectiveTrack,
                strokeCap: strokeCap,
              ),
            ),
            ?child,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
    required this.strokeCap,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0.0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;

      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
