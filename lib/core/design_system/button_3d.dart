import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'button_3d_face.dart';

/// 3D tactile button with pressed depth translation and accessibility semantics.
///
/// Adheres to AGENTS.md §4.6 (flexible sizing, minimum 48dp target) and §8.
class Button3D extends StatefulWidget {
  const Button3D({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.backgroundColor,
    this.depthColor,
    this.textColor,
    this.depth = AppSpacing.depthMd,
    this.borderRadius = AppSpacing.radiusButton,
    this.minHeight = AppSpacing.buttonHeightMd,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    this.isFullWidth = true,
    this.isCircular = false,
  });

  /// Circular variant of [Button3D] for round icon buttons.
  const Button3D.circular({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.depthColor,
    this.textColor,
    this.depth = AppSpacing.depthMd,
    double size = AppSpacing.buttonHeightLg,
    this.padding = EdgeInsets.zero,
  }) : trailingIcon = null,
       borderRadius = 0,
       minHeight = size,
       width = size,
       isFullWidth = false,
       isCircular = true;

  /// Soft/lavender secondary variant of [Button3D] with dark purple text.
  ///
  /// Adheres to AGENTS.md §4.6 and WCAG AAA contrast (7.42:1).
  const Button3D.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.depth = AppSpacing.depthMd,
    this.borderRadius = AppSpacing.radiusButton,
    this.minHeight = AppSpacing.buttonHeightMd,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    this.isFullWidth = true,
  }) : backgroundColor = AppColors.secondaryButtonBackground,
       depthColor = AppColors.secondaryButtonDepth,
       textColor = AppColors.secondaryButtonText,
       isCircular = false;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? trailingIcon;
  final Color? backgroundColor;
  final Color? depthColor;
  final Color? textColor;
  final double depth;
  final double borderRadius;
  final double minHeight;
  final double? width;
  final EdgeInsetsGeometry padding;
  final bool isFullWidth;
  final bool isCircular;

  bool get isEnabled => onPressed != null;

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.isEnabled
        ? (widget.backgroundColor ?? theme.colorScheme.primary)
        : AppColors.disabled;
    final depth = widget.isEnabled
        ? (widget.depthColor ?? AppColors.brandPurpleDepth)
        : AppColors.disabledDepth;
    final fg = widget.isEnabled
        ? (widget.textColor ?? Colors.white)
        : AppColors.disabledText;

    final topOffset = _isPressed ? widget.depth : 0.0;
    final radius = BorderRadius.circular(widget.borderRadius);

    final resolvedWidth =
        widget.width ??
        (widget.isCircular
            ? widget.minHeight
            : (widget.isFullWidth
                  ? double.infinity
                  : (widget.label.isEmpty ? widget.minHeight : null)));

    return Semantics(
      button: true,
      enabled: widget.isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isEnabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: resolvedWidth,
          height: widget.minHeight + widget.depth,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: widget.depth,
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: depth,
                    shape: widget.isCircular
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: widget.isCircular ? null : radius,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOut,
                top: topOffset,
                left: 0,
                right: 0,
                bottom: widget.depth - topOffset,
                child: Button3DFace(
                  color: bg,
                  radius: radius,
                  padding: widget.padding,
                  icon: widget.icon,
                  trailingIcon: widget.trailingIcon,
                  label: widget.label,
                  textColor: fg,
                  isCircular: widget.isCircular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
