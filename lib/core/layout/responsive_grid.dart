import 'package:flutter/widgets.dart';
import '../theme/app_spacing.dart';

/// A grid widget with automatically adapting column counts based on [maxItemWidth].
///
/// Prevents fixed-column overflow and oversized items across all device sizes.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxItemWidth = 200.0,
    this.mainAxisSpacing = AppSpacing.md,
    this.crossAxisSpacing = AppSpacing.md,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final double maxItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxItemWidth,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
