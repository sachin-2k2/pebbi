import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shape variety for path nodes per AGENTS.md §8 and design spec §5.
enum NodeShapeType { circle, hexagon, roundedSquare }

/// Custom 3D shape widget for path nodes.
///
/// Draws circle, hexagon, or rounded square with 3D depth layer and face layer.
class NodeShape extends StatelessWidget {
  const NodeShape({
    super.key,
    required this.shape,
    required this.faceColor,
    required this.depthColor,
    required this.child,
    this.diameter = 68.0,
    this.depth = 6.0,
    this.isPressed = false,
  });

  final NodeShapeType shape;
  final Color faceColor;
  final Color depthColor;
  final Widget child;
  final double diameter;
  final double depth;
  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    final currentDepth = isPressed ? depth * 0.25 : depth;
    final topOffset = isPressed ? depth * 0.75 : 0.0;

    return SizedBox(
      width: diameter,
      height: diameter + depth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Depth / Shadow Layer
          Positioned(
            top: topOffset + currentDepth,
            child: _buildShapeContainer(color: depthColor, size: diameter),
          ),
          // Top Face Layer
          Positioned(
            top: topOffset,
            child: _buildShapeContainer(
              color: faceColor,
              size: diameter,
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeContainer({
    required Color color,
    required double size,
    Widget? child,
  }) {
    switch (shape) {
      case NodeShapeType.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: child,
        );
      case NodeShapeType.roundedSquare:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: child,
        );
      case NodeShapeType.hexagon:
        return CustomPaint(
          size: Size(size, size),
          painter: _HexagonPainter(color: color),
          child: SizedBox(width: size, height: size, child: child),
        );
    }
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      // Pointy-topped hexagon (starting at -90 degrees)
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => oldDelegate.color != color;
}
