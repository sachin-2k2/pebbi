import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dashed connecting line between two path nodes.
class DashedConnectorPainter extends CustomPainter {
  const DashedConnectorPainter({
    required this.start,
    required this.end,
    this.isCompleted = false,
    this.color,
    this.dashLength = 6.0,
    this.dashGap = 5.0,
    this.strokeWidth = 3.5,
  });

  final Offset start;
  final Offset end;
  final bool isCompleted;
  final Color? color;
  final double dashLength;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveColor =
        color ?? (isCompleted ? AppColors.mint : const Color(0xFFDDDDE5));

    final paint = Paint()
      ..color = effectiveColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalDistance = math.sqrt(dx * dx + dy * dy);

    if (totalDistance < dashLength) return;

    final unitX = dx / totalDistance;
    final unitY = dy / totalDistance;

    double currentDist = 0.0;
    while (currentDist < totalDistance) {
      final segLength = math.min(dashLength, totalDistance - currentDist);
      final p1 = Offset(
        start.dx + unitX * currentDist,
        start.dy + unitY * currentDist,
      );
      final p2 = Offset(
        start.dx + unitX * (currentDist + segLength),
        start.dy + unitY * (currentDist + segLength),
      );
      canvas.drawLine(p1, p2, paint);
      currentDist += dashLength + dashGap;
    }
  }

  @override
  bool shouldRepaint(DashedConnectorPainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.isCompleted != isCompleted ||
      oldDelegate.color != color;
}
