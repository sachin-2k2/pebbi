import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PebbiExpression {
  happy,
  happyClosed,
  winking,
  protective,
  sad,
  surprised,
  relaxed,
}

enum PebbiOutfit { defaultPurple, explorer, casual, backpack, scarf }

/// Vector placeholder mascot for Pebbi per AGENTS.md §8 and design spec §6.
///
/// Features bear ears with pink inner ear, white face, smile, and accent color.
class PebbiMascot extends StatelessWidget {
  const PebbiMascot({
    super.key,
    this.size = 48.0,
    this.accentColor = AppColors.brandPurple,
    this.expression = PebbiExpression.happy,
    this.outfit = PebbiOutfit.defaultPurple,
  });

  final double size;
  final Color accentColor;
  final PebbiExpression expression;
  final PebbiOutfit outfit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PebbiPainter(
          bodyColor: accentColor,
          expression: expression,
          outfit: outfit,
        ),
      ),
    );
  }
}

class _PebbiPainter extends CustomPainter {
  const _PebbiPainter({
    required this.bodyColor,
    required this.expression,
    required this.outfit,
  });

  final Color bodyColor;
  final PebbiExpression expression;
  final PebbiOutfit outfit;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = bodyColor;
    final whitePaint = Paint()..color = Colors.white;
    final pinkPaint = Paint()..color = const Color(0xFFFFB6C1);
    final darkPaint = Paint()
      ..color = const Color(0xFF1E1647)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    // 1. Ears
    final earRadius = w * 0.18;
    canvas.drawCircle(Offset(w * 0.22, h * 0.22), earRadius, bodyPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.22), earRadius, bodyPaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.22), earRadius * 0.6, pinkPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.22), earRadius * 0.6, pinkPaint);

    // 1.5 Backpack straps (if outfit == PebbiOutfit.backpack)
    if (outfit == PebbiOutfit.backpack) {
      final strapPaint = Paint()..color = const Color(0xFFD9481E);
      final leftStrap = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.44, w * 0.10, h * 0.28),
        Radius.circular(w * 0.04),
      );
      final rightStrap = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.84, h * 0.44, w * 0.10, h * 0.28),
        Radius.circular(w * 0.04),
      );
      canvas.drawRRect(leftStrap, strapPaint);
      canvas.drawRRect(rightStrap, strapPaint);
    }

    // 2. Head / Body
    final headRect = Rect.fromCircle(
      center: Offset(w * 0.5, h * 0.54),
      radius: w * 0.42,
    );
    canvas.drawOval(headRect, bodyPaint);

    // 3. White Face muzzle
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.58,
      height: h * 0.44,
    );
    canvas.drawOval(faceRect, whitePaint);

    // 4. Cheeks
    canvas.drawCircle(Offset(w * 0.30, h * 0.60), w * 0.06, pinkPaint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.60), w * 0.06, pinkPaint);

    // 5. Nose
    final nosePaint = Paint()..color = const Color(0xFF1E1647);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.52),
        width: w * 0.12,
        height: h * 0.08,
      ),
      nosePaint,
    );

    // 6. Eyes
    if (expression == PebbiExpression.winking ||
        expression == PebbiExpression.protective) {
      canvas.drawCircle(Offset(w * 0.38, h * 0.46), w * 0.045, nosePaint);
      final winkPath = Path()
        ..moveTo(w * 0.58, h * 0.46)
        ..quadraticBezierTo(w * 0.64, h * 0.42, w * 0.70, h * 0.46);
      canvas.drawPath(winkPath, darkPaint);
    } else if (expression == PebbiExpression.happyClosed ||
        expression == PebbiExpression.surprised) {
      final leftArc = Path()
        ..moveTo(w * 0.33, h * 0.47)
        ..quadraticBezierTo(w * 0.38, h * 0.41, w * 0.43, h * 0.47);
      canvas.drawPath(leftArc, darkPaint);
      final rightArc = Path()
        ..moveTo(w * 0.57, h * 0.47)
        ..quadraticBezierTo(w * 0.62, h * 0.41, w * 0.67, h * 0.47);
      canvas.drawPath(rightArc, darkPaint);
    } else if (expression == PebbiExpression.relaxed) {
      // Calm, relaxed/sleepy closed straight horizontal eyes
      canvas.drawLine(
        Offset(w * 0.33, h * 0.46),
        Offset(w * 0.43, h * 0.46),
        darkPaint,
      );
      canvas.drawLine(
        Offset(w * 0.57, h * 0.46),
        Offset(w * 0.67, h * 0.46),
        darkPaint,
      );
    } else {
      canvas.drawCircle(Offset(w * 0.38, h * 0.46), w * 0.045, nosePaint);
      canvas.drawCircle(Offset(w * 0.62, h * 0.46), w * 0.045, nosePaint);
    }

    // 7. Smile / Mouth
    if (expression == PebbiExpression.surprised) {
      final mouthPaint = Paint()
        ..color = const Color(0xFF1E1647)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.63),
          width: w * 0.12,
          height: h * 0.14,
        ),
        mouthPaint,
      );
    } else if (expression == PebbiExpression.protective) {
      canvas.drawLine(
        Offset(w * 0.43, h * 0.61),
        Offset(w * 0.57, h * 0.61),
        darkPaint,
      );
    } else if (expression == PebbiExpression.sad) {
      // Downward curved mouth (frown / concerned)
      final sadPath = Path()
        ..moveTo(w * 0.44, h * 0.64)
        ..quadraticBezierTo(w * 0.5, h * 0.58, w * 0.56, h * 0.64);
      canvas.drawPath(sadPath, darkPaint);
    } else {
      final smilePath = Path()
        ..moveTo(w * 0.44, h * 0.60)
        ..quadraticBezierTo(w * 0.5, h * 0.66, w * 0.56, h * 0.60);
      canvas.drawPath(smilePath, darkPaint);
    }

    // 8. Scarf and Sparkle (if outfit == PebbiOutfit.scarf)
    if (outfit == PebbiOutfit.scarf) {
      final scarfPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      final scarfPath = Path()
        ..moveTo(w * 0.30, h * 0.85)
        ..quadraticBezierTo(w * 0.5, h * 0.97, w * 0.70, h * 0.85)
        ..quadraticBezierTo(w * 0.5, h * 0.91, w * 0.30, h * 0.85);
      canvas.drawPath(scarfPath, scarfPaint);

      final sparklePaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w * 0.605, h * 0.27),
        Offset(w * 0.655, h * 0.27),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(w * 0.63, h * 0.245),
        Offset(w * 0.63, h * 0.295),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(w * 0.615, h * 0.255),
        Offset(w * 0.645, h * 0.285),
        sparklePaint,
      );
    } else if (outfit == PebbiOutfit.backpack) {
      final strapPaint = Paint()
        ..color = AppColors.coral
        ..style = PaintingStyle.fill;

      // Left and right coral backpack straps visible at shoulders
      final leftStrap = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.74, w * 0.12, h * 0.22),
        Radius.circular(w * 0.06),
      );
      final rightStrap = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.80, h * 0.74, w * 0.12, h * 0.22),
        Radius.circular(w * 0.06),
      );
      canvas.drawRRect(leftStrap, strapPaint);
      canvas.drawRRect(rightStrap, strapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PebbiPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.expression != expression ||
        oldDelegate.outfit != outfit;
  }
}
