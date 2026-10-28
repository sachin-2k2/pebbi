import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/layout/window_class.dart';
import '../../../../core/network/network_status_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/path_compact_layout.dart';
import '../widgets/path_expanded_layout.dart';

/// Main Path (Home) screen.
///
/// Follows AGENTS.md §3: Thin screen file (<100 lines) with zero business logic.
/// Follows AGENTS.md §4: Adapts between compact/medium single column and expanded two-pane.
/// Follows Rule 5: Performs lazy profile check when Path is shown and online.
class PathScreen extends ConsumerStatefulWidget {
  const PathScreen({super.key});

  @override
  ConsumerState<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends ConsumerState<PathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLazySession();
    });
  }

  void _checkLazySession() {
    final isOffline = ref.read(isOfflineProvider);
    if (!isOffline) {
      ref.read(currentUserProvider.notifier).refreshProfile();
    }
  }

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
