import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/layout/window_class.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/missions_compact_layout.dart';
import '../widgets/missions_expanded_layout.dart';

/// Main role-play Missions tab screen (tab 2 of AdaptiveShell).
///
/// Follows AGENTS.md §3: Thin screen file (<100 lines) with zero business logic.
/// Follows AGENTS.md §4: Adapts between compact/medium single column and expanded two-pane.
class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.isExpanded;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: isExpanded ? 1200.0 : 640.0,
          child: isExpanded
              ? const MissionsExpandedLayout()
              : const MissionsCompactLayout(),
        ),
      ),
    );
  }
}
