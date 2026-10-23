import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_palette.dart';
import '../providers/mission_brief_provider.dart';
import '../widgets/brief/mission_brief_body.dart';
import '../widgets/brief/mission_brief_error_view.dart';

/// Full-page Mission Brief screen ("Order a coffee").
///
/// Follows AGENTS.md §3 (<100 lines target) and §4 (responsive layout).
class MissionBriefScreen extends ConsumerWidget {
  const MissionBriefScreen({super.key, required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final asyncState = ref.watch(missionBriefNotifierProvider(missionId));
    final notifier = ref.read(missionBriefNotifierProvider(missionId).notifier);
    final isOffline = ref.watch(missionBriefIsOfflineProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 720.0,
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => const MissionBriefErrorView(),
            data: (state) => MissionBriefBody(
              brief: state.brief,
              state: state,
              notifier: notifier,
              isOffline: isOffline,
            ),
          ),
        ),
      ),
    );
  }
}
