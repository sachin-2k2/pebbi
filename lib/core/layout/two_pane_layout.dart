import 'package:flutter/widgets.dart';
import 'window_class.dart';

/// Renders a two-pane layout side-by-side on [WindowClass.expanded],
/// and falls back to a single pane on compact and medium screens.
class TwoPaneLayout extends StatelessWidget {
  const TwoPaneLayout({
    super.key,
    required this.primaryPane,
    required this.secondaryPane,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    this.spacing = 24.0,
  });

  final Widget primaryPane;
  final Widget secondaryPane;
  final int primaryFlex;
  final int secondaryFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (!context.isExpanded) {
      return primaryPane;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: primaryFlex, child: primaryPane),
        SizedBox(width: spacing),
        Expanded(flex: secondaryFlex, child: secondaryPane),
      ],
    );
  }
}
