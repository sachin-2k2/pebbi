import 'package:flutter/widgets.dart';
import '../theme/app_spacing.dart';

/// Centers child content and caps its maximum width to prevent stretching
/// on tablets, iPads, and desktop windows.
class ContentWidthLimiter extends StatelessWidget {
  const ContentWidthLimiter({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.maxContentWidthExpanded,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
