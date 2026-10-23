import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

/// Reusable soft pill container with subtle shadow for chips and top pills.
class PillCard extends StatelessWidget {
  const PillCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveBg = backgroundColor ?? palette.surface;
    final effectiveBorder = borderColor ?? palette.outline;

    return Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: effectiveBorder),
            boxShadow: palette.cardShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
