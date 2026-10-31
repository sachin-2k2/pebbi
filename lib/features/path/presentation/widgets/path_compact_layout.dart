import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/home_summary_provider.dart';
import '../providers/path_provider.dart';
import '../../domain/path_node.dart';
import 'free_unit_note.dart';
import 'locked_node_sheet.dart';
import 'path_header_section.dart';
import 'path_rail.dart';
import 'unit_guide/unit_guide_sheet.dart';
import 'unit_header.dart';

/// Single-column scrolling layout for compact and medium window classes.
class PathCompactLayout extends ConsumerStatefulWidget {
  const PathCompactLayout({super.key});

  @override
  ConsumerState<PathCompactLayout> createState() => _PathCompactLayoutState();
}

class _PathCompactLayoutState extends ConsumerState<PathCompactLayout> {
  ScrollController? _scrollController;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    final tracks = ref.watch(tracksProvider).valueOrNull ?? const [];
    final selectedTrack = ref.watch(selectedTrackProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final completedId = ref.watch(completedLessonAnimProvider);
    final units = unitsAsync.valueOrNull ?? const [];

    if (_scrollController == null) {
      double initialOffset = 0.0;
      if (completedId != null) {
        for (final unit in units) {
          final idx = unit.nodes.indexWhere((n) => n.id == completedId);
          if (idx != -1) {
            final screenH = MediaQuery.sizeOf(context).height;
            final targetY = 480.0 + idx * 148.0;
            initialOffset = (targetY - screenH * 0.35).clamp(0.0, 4000.0);
            break;
          }
        }
      }
      _scrollController = ScrollController(initialScrollOffset: initialOffset);
    }

    return summaryAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summary) {
        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            PathHeaderSection(summary: summary, tracks: tracks, selectedTrack: selectedTrack),
            ...unitsAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => [
                const SizedBox(height: 120.0, child: Center(child: CircularProgressIndicator())),
              ],
              error: (err, _) => [Center(child: Text('Error: $err'))],
              data: (units) => units.map((unit) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: UnitHeader(
                        unitNumber: unit.unitNumber,
                        title: unit.title,
                        stopsDone: unit.stopsDone,
                        totalStops: unit.totalStops,
                        isLocked: unit.isLocked,
                        onGuidebookTap: () => UnitGuideSheet.show(context, unitId: unit.id),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PathRail(
                      key: ValueKey('path_rail_${unit.id}'),
                      nodes: unit.nodes,
                      completedStopId: completedId,
                      onAnimationComplete: () =>
                          ref.read(completedLessonAnimProvider.notifier).state = null,
                      onNodeTap: (node) => _handleNodeTap(context, node),
                    ),
                    if (unit.isFreeUnit && unit.isCompleted)
                      FreeUnitNote(onUnlockTap: () => context.push('/premium/options')),
                  ],
                );
              }),
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
        SnackBar(content: Text('TODO(question): Practice ${node.title} coming soon!')),
      );
    }
  }
}
