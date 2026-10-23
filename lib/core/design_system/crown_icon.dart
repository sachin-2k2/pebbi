import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// Small vector outline crown icon matching the Pebbi design system.
///
/// Follows AGENTS.md §3 & §8: under 100 lines, build under 50 lines,
/// flexible sizing, vector graphics.
class CrownIcon extends StatelessWidget {
  const CrownIcon({super.key, this.size = 14.0, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? IconTheme.of(context).color ?? context.palette.brand;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CrownPainter(color: effectiveColor)),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Bottom base line
    final basePath = Path()
      ..moveTo(w * 0.15, h * 0.82)
      ..lineTo(w * 0.85, h * 0.82);
    canvas.drawPath(basePath, strokePaint);

    // 3-point crown outline
    final crownPath = Path()
      ..moveTo(w * 0.18, h * 0.78)
      ..lineTo(w * 0.15, h * 0.35)
      ..lineTo(w * 0.38, h * 0.55)
      ..lineTo(w * 0.50, h * 0.28)
      ..lineTo(w * 0.62, h * 0.55)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.82, h * 0.78);
    canvas.drawPath(crownPath, strokePaint);

    // 3 small tip dots
    final dotRadius = w * 0.055;
    canvas.drawCircle(Offset(w * 0.15, h * 0.30), dotRadius, dotPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.23), dotRadius, dotPaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.30), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) =>
      oldDelegate.color != color;
}
