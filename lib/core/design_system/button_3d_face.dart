import 'package:flutter/widgets.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Face surface widget for [Button3D].
class Button3DFace extends StatelessWidget {
  const Button3DFace({
    super.key,
    required this.color,
    required this.radius,
    required this.padding,
    required this.label,
    required this.textColor,
    this.icon,
    this.trailingIcon,
    this.isCircular = false,
  });

  final Color color;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final String label;
  final Color textColor;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : radius,
      ),
      child: Padding(
        padding: padding,
        child: Center(
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ?icon,
                if (icon != null && label.isNotEmpty)
                  const SizedBox(width: AppSpacing.sm),
                if (label.isNotEmpty)
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (trailingIcon != null) ...[
                  if (label.isNotEmpty) const SizedBox(width: AppSpacing.xs),
                  trailingIcon!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
