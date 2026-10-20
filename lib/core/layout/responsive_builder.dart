import 'package:flutter/widgets.dart';
import 'window_class.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, WindowClass windowClass);

/// A widget that conditionally builds UI based on [WindowClass].
///
/// Uses `LayoutBuilder` to observe available width and falls back to
/// [compact] if higher-tier builders are omitted.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.builder,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final ResponsiveWidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = windowClassFromWidth(constraints.maxWidth);

        if (builder != null) {
          return builder!(context, windowClass);
        }

        switch (windowClass) {
          case WindowClass.expanded:
            if (expanded != null) return expanded!(context);
            if (medium != null) return medium!(context);
            return compact(context);
          case WindowClass.medium:
            if (medium != null) return medium!(context);
            return compact(context);
          case WindowClass.compact:
            return compact(context);
        }
      },
    );
  }
}
