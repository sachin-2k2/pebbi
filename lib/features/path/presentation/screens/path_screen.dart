import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/layout/window_class.dart';
import '../widgets/path_compact_layout.dart';
import '../widgets/path_expanded_layout.dart';

/// Main Path (Home) screen.
///
/// Follows AGENTS.md §3: Thin screen file (<100 lines) with zero business logic.
/// Follows AGENTS.md §4: Adapts between compact/medium single column and expanded two-pane.
class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.isExpanded;

    return Scaffold(
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: isExpanded ? 1200.0 : 640.0,
          child: isExpanded
              ? const PathExpandedLayout()
              : const PathCompactLayout(),
        ),
      ),
    );
  }
}
