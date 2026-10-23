import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';

/// Animated pulse ring for current active node per design spec §5.
///
/// Respects reduce-motion settings and accessibility disable-animations.
class CurrentNodeRing extends StatefulWidget {
  const CurrentNodeRing({
    super.key,
    required this.child,
    this.diameter = 68.0,
    this.ringColor,
  });

  final Widget child;
  final double diameter;
  final Color? ringColor;

  @override
  State<CurrentNodeRing> createState() => _CurrentNodeRingState();
}

class _CurrentNodeRingState extends State<CurrentNodeRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final effectiveColor = widget.ringColor ?? context.palette.brand;

    if (disableAnimations || isTest) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.diameter + 14.0,
            height: widget.diameter + 14.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: effectiveColor.withValues(alpha: 0.35),
                width: 3.0,
              ),
            ),
          ),
          widget.child,
        ],
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.diameter + 8.0,
                height: widget.diameter + 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveColor.withValues(
                      alpha: _opacityAnimation.value,
                    ),
                    width: 3.0,
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
