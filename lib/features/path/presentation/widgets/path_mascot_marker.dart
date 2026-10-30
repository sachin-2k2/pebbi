import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';

/// Companion mascot standing beside the active path node with gentle bounce.
///
/// Follows AGENTS.md §8: supports RTL mirroring, size scaling, and reduce motion.
class PathMascotMarker extends StatefulWidget {
  const PathMascotMarker({
    super.key,
    this.size = 46.0,
    this.expression = PebbiExpression.excited,
    this.isOnRight = false,
  });

  final double size;
  final PebbiExpression expression;
  final bool isOnRight;

  @override
  State<PathMascotMarker> createState() => _PathMascotMarkerState();
}

class _PathMascotMarkerState extends State<PathMascotMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -6.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -6.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final flipHorizontal = widget.isOnRight != isRtl;

    Widget mascot = PebbiMascot(
      size: widget.size,
      expression: widget.expression,
    );

    if (flipHorizontal) {
      mascot = Transform.scale(scaleX: -1.0, child: mascot);
    }

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bounceAnimation.value),
        child: child,
      ),
      child: Semantics(label: 'Pebbi cheering you on', child: mascot),
    );
  }
}
