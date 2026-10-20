import 'package:flutter/material.dart';

/// Animated pop-in green check tick with scale and fade transition.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// respects reduce motion, high contrast emerald color (#047857 > 7:1 against white).
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({
    super.key,
    required this.isDone,
    this.reduceMotion = false,
    this.color = const Color(0xFF065F46),
  });

  final bool isDone;
  final bool reduceMotion;
  final Color color;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    if (widget.isDone) {
      if (widget.reduceMotion) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isDone && widget.isDone) {
      if (widget.reduceMotion) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.0);
      }
    } else if (oldWidget.isDone && !widget.isDone) {
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDone) {
      return const SizedBox(width: 24.0, height: 24.0);
    }

    if (widget.reduceMotion) {
      return Icon(Icons.check, size: 22.0, color: widget.color);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(Icons.check, size: 22.0, color: widget.color),
      ),
    );
  }
}
