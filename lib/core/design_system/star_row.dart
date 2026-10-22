import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable row of 1 to 3 animated stars indicating completion rating.
///
/// Follows AGENTS.md §4.6 & §8:
/// - Distinguishes earned vs empty stars by both shape and accessible label.
/// - Earned stars animate in with a staggered pop and scale unless Reduce Motion is active.
/// - Conforms to WCAG AA non-text contrast (≥ 3:1) via [AppColors.goldStar].
class StarRow extends StatefulWidget {
  const StarRow({
    super.key,
    required this.starsEarned,
    this.totalStars = 3,
    this.starSize = 42.0,
    this.spacing = 10.0,
  });

  /// Count of earned stars (0 to 3).
  final int starsEarned;

  /// Total star capacity (default 3).
  final int totalStars;

  /// Size of each star icon.
  final double starSize;

  /// Horizontal spacing between stars.
  final double spacing;

  @override
  State<StarRow> createState() => _StarRowState();
}

class _StarRowState extends State<StarRow> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnimations;
  late final List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.totalStars,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      ),
    );

    _scaleAnimations = _controllers.map((c) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOutBack),
      );
    }).toList();

    _fadeAnimations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeIn),
      );
    }).toList();

    _triggerAnimations();
  }

  void _triggerAnimations() {
    for (int i = 0; i < widget.totalStars; i++) {
      if (i < widget.starsEarned) {
        Future.delayed(Duration(milliseconds: 100 + (i * 90)), () {
          if (mounted) _controllers[i].forward();
        });
      } else {
        _controllers[i].value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filledColor = isDark ? AppColors.darkGoldStar : AppColors.goldStar;
    final emptyColor = isDark
        ? AppColors.darkGoldStarOutline
        : AppColors.goldStarOutline;

    final semanticsLabel = '${widget.starsEarned} of ${widget.totalStars} stars';

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.totalStars, (index) {
          final isEarned = index < widget.starsEarned;
          final icon = isEarned
              ? Icons.star_rounded
              : Icons.star_outline_rounded;
          final color = isEarned ? filledColor : emptyColor;

          Widget star = Icon(icon, size: widget.starSize, color: color);

          if (!reduceMotion && isEarned) {
            star = FadeTransition(
              opacity: _fadeAnimations[index],
              child: ScaleTransition(
                scale: _scaleAnimations[index],
                child: star,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            child: star,
          );
        }),
      ),
    );
  }
}
