import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/two_pane_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/ad_banner_provider.dart';
import '../providers/home_summary_provider.dart';
import '../providers/path_provider.dart';
import '../../domain/path_node.dart';
import 'ad_banner.dart';
import 'continue_card.dart';
import 'due_strip.dart';
import 'free_unit_note.dart';
import 'level_hint.dart';
import 'locked_node_sheet.dart';
import 'path_rail.dart';
import 'top_pills.dart';
import 'track_chip_row.dart';
import 'unit_guide/unit_guide_sheet.dart';
import 'unit_header.dart';

/// Two-pane responsive layout for expanded screens (tablets & landscape).
class PathExpandedLayout extends ConsumerWidget {
  const PathExpandedLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    final tracks = ref.watch(tracksProvider).valueOrNull ?? const [];
    final selectedTrack = ref.watch(selectedTrackProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final showAds = ref.watch(shouldShowAdBannerProvider);
    final activeAd = ref.watch(activeAdBannerProvider).valueOrNull;

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summary) {
        return TwoPaneLayout(
          primaryFlex: 2,
          secondaryFlex: 3,
          spacing: AppSpacing.lg,
          primaryPane: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TopPills(
                language: summary.language,
                streakCount: summary.streakCount,
                starsCount: summary.starsCount,
                onLanguageTap: () =>
                    _showPlaceholder(context, 'Language switcher'),
                onStreakTap: () => _showPlaceholder(context, 'Streak calendar'),
                onStarsTap: () => _showPlaceholder(context, 'Stars & outfits'),
                onProfileTap: () => context.go('/settings'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TrackChipRow(
                tracks: tracks,
                selectedTrackId: selectedTrack,
                onTrackSelected: (id) =>
                    ref.read(selectedTrackProvider.notifier).state = id,
              ),
              LevelHint(onTap: () => context.go('/settings')),
              const SizedBox(height: AppSpacing.md),
              ContinueCard(
                title: summary.currentStopTitle,
                subtitle: AppStrings.continueCaption(summary.estimatedMinutes),
                onPlayPressed: () => context.push('/lesson/1'),
              ),
              const SizedBox(height: AppSpacing.md),
              DueStrip(
                dueCount: summary.dueCount,
                hasPhrases: summary.hasAnyPhrases,
                onReviewTap: () => context.go('/review'),
              ),
              if (showAds && activeAd != null) ...[
                const SizedBox(height: AppSpacing.md),
                AdBanner(
                  title: activeAd.title,
                  priceString: activeAd.priceString,
                  onRemoveAdsTap: () => context.push('/premium/options'),
                ),
              ],
            ],
          ),
          secondaryPane: unitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (units) => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: units.map((unit) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UnitHeader(
                      unitNumber: unit.unitNumber,
                      title: unit.title,
                      stopsDone: unit.stopsDone,
                      totalStops: unit.totalStops,
                      isLocked: unit.isLocked,
                      onGuidebookTap: () =>
                          UnitGuideSheet.show(context, unitId: unit.id),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PathRail(
                      nodes: unit.nodes,
                      onNodeTap: (node) => _handleNodeTap(context, node),
                    ),
                    if (unit.isFreeUnit && unit.isCompleted)
                      FreeUnitNote(
                        onUnlockTap: () => context.push('/premium/options'),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _handleNodeTap(BuildContext context, PathNode node) {
    if (node.isLocked) {
      showLockedNodeSheet(context, node);
    } else if (node.isCurrent) {
      context.push('/lesson/1');
    } else {
      _showPlaceholder(context, 'Practice ${node.title}');
    }
  }

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TODO(question): $feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
