import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/path_node.dart';
import '../../domain/unit.dart';
import '../providers/home_summary_provider.dart';
import '../providers/path_provider.dart';
import 'free_unit_note.dart';
import 'locked_node_sheet.dart';
import 'path_pinned_top_bar.dart';
import 'path_rail.dart';
import 'path_scroll_helper.dart';
import 'path_summary_section.dart';
import 'unit_guide/unit_guide_sheet.dart';
import 'unit_header.dart';

/// Single-column layout for compact and medium window classes.
///
/// Follows AGENTS.md §3 (<150 lines) and Candy Crush map UX:
/// - Pinned top status bar (language, streak, stars, profile, track chips).
/// - Automatically centers on the active level and mascot on app open.
/// - Independent scrolling level path map.
class PathCompactLayout extends ConsumerStatefulWidget {
  const PathCompactLayout({super.key});

  @override
  ConsumerState<PathCompactLayout> createState() => _PathCompactLayoutState();
}

class _PathCompactLayoutState extends ConsumerState<PathCompactLayout> {
  ScrollController? _scrollController;
  bool _hasInitialScrolled = false;
  String? _lastTrackId;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _checkScrollToCurrent({
    required List<Unit> units,
    required String? targetStopId,
    required double screenH,
    required bool isCollapsed,
  }) {
    if (units.isEmpty || _hasInitialScrolled) return;
    final targetOffset = PathScrollHelper.calculateTargetOffset(
      units: units,
      targetStopId: targetStopId,
      screenHeight: screenH,
      isCollapsed: isCollapsed,
    );
    if (targetOffset > 0) {
      _hasInitialScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController?.hasClients == true) {
          _scrollController!.jumpTo(targetOffset);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    final tracks = ref.watch(tracksProvider).valueOrNull ?? const [];
    final selectedTrack = ref.watch(selectedTrackProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final completedId = ref.watch(completedLessonAnimProvider);
    final units = unitsAsync.valueOrNull ?? const [];
    final isCollapsed = ref.watch(pathSummaryCollapsedProvider);
    final screenH = MediaQuery.sizeOf(context).height;

    if (selectedTrack != _lastTrackId) {
      _lastTrackId = selectedTrack;
      _hasInitialScrolled = false;
    }

    final currentStopId = summaryAsync.valueOrNull?.currentStopId;
    final targetStopId = completedId ?? currentStopId;

    if (_scrollController == null) {
      final initialOffset = PathScrollHelper.calculateTargetOffset(
        units: units,
        targetStopId: targetStopId,
        screenHeight: screenH,
        isCollapsed: isCollapsed,
      );
      if (initialOffset > 0) _hasInitialScrolled = true;
      _scrollController = ScrollController(initialScrollOffset: initialOffset);
    } else {
      _checkScrollToCurrent(
        units: units,
        targetStopId: targetStopId,
        screenH: screenH,
        isCollapsed: isCollapsed,
      );
    }

    return summaryAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summary) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PathPinnedTopBar(
              summary: summary,
              tracks: tracks,
              selectedTrack: selectedTrack,
            ),
            Expanded(
              child: unitsAsync.when(
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (units) => ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  children: [
                    PathSummarySection(summary: summary),
                    ...units.map((unit) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: UnitHeader(
                              unitNumber: unit.unitNumber,
                              title: unit.title,
                              stopsDone: unit.stopsDone,
                              totalStops: unit.totalStops,
                              isLocked: unit.isLocked,
                              onGuidebookTap: () =>
                                  UnitGuideSheet.show(context, unitId: unit.id),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PathRail(
                            key: ValueKey('path_rail_${unit.id}'),
                            nodes: unit.nodes,
                            completedStopId: completedId,
                            onAnimationComplete: () => ref
                                .read(completedLessonAnimProvider.notifier)
                                .state = null,
                            onNodeTap: (node) => _handleNodeTap(context, node),
                          ),
                          if (unit.isFreeUnit && unit.isCompleted)
                            FreeUnitNote(
                              onUnlockTap: () =>
                                  context.push('/premium/options'),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNodeTap(BuildContext context, PathNode node) {
    if (node.isLocked) {
      showLockedNodeSheet(context, node);
    } else if (node.isCurrent) {
      context.push('/lesson/${node.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('TODO(question): Practice ${node.title} coming soon!'),
        ),
      );
    }
  }
}
