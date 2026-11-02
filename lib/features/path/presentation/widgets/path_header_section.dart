import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/home_summary.dart';
import '../../domain/track.dart';
import '../providers/ad_banner_provider.dart';
import '../providers/path_provider.dart';
import 'ad_banner.dart';
import 'continue_card.dart';
import 'due_strip.dart';
import 'level_hint.dart';
import 'path_compact_continue_bar.dart';
import 'top_pills.dart';
import 'track_chip_row.dart';

/// Pinned top header for the Path screen with collapsible summary support.
///
/// Follows AGENTS.md §3 (<150 lines):
/// - Pinned TopPills and TrackChipRow that never scroll away.
/// - Collapsible summary toggle providing immersive Candy Crush map scrolling.
class PathHeaderSection extends ConsumerWidget {
  const PathHeaderSection({
    super.key,
    required this.summary,
    required this.tracks,
    required this.selectedTrack,
  });

  final HomeSummary summary;
  final List<Track> tracks;
  final String selectedTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAds = ref.watch(shouldShowAdBannerProvider);
    final activeAd = ref.watch(activeAdBannerProvider).valueOrNull;
    final isCollapsed = ref.watch(pathSummaryCollapsedProvider);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TopPills(
          language: summary.language,
          streakCount: summary.streakCount,
          starsCount: summary.starsCount,
          onLanguageTap: () => _showPlaceholder(context, 'Language switcher'),
          onStreakTap: () => _showPlaceholder(context, 'Streak calendar'),
          onStarsTap: () => _showPlaceholder(context, 'Stars & outfits'),
          onProfileTap: () => context.go('/settings'),
        ),
        const SizedBox(height: AppSpacing.xs),
        TrackChipRow(
          tracks: tracks,
          selectedTrackId: selectedTrack,
          onTrackSelected: (id) =>
              ref.read(selectedTrackProvider.notifier).state = id,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (isCollapsed)
          PathCompactContinueBar(
            title: summary.currentStopTitle,
            subtitle: AppStrings.continueCaption(summary.estimatedMinutes),
            dueCount: summary.dueCount,
            onPlayPressed: () =>
                context.push('/lesson/${summary.currentStopId}'),
            onReviewPressed: () => context.go('/review'),
            onExpandPressed: () =>
                ref.read(pathSummaryCollapsedProvider.notifier).state = false,
          )
        else ...[
          LevelHint(onTap: () => context.go('/settings')),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ContinueCard(
              title: summary.currentStopTitle,
              subtitle: AppStrings.continueCaption(summary.estimatedMinutes),
              onPlayPressed: () =>
                  context.push('/lesson/${summary.currentStopId}'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: DueStrip(
              dueCount: summary.dueCount,
              hasPhrases: summary.hasAnyPhrases,
              onReviewTap: () => context.go('/review'),
            ),
          ),
          if (showAds && activeAd != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md)
                  .copyWith(top: AppSpacing.md),
              child: AdBanner(
                title: activeAd.title,
                priceString: activeAd.priceString,
                onRemoveAdsTap: () => context.push('/premium/options'),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: InkWell(
              onTap: () =>
                  ref.read(pathSummaryCollapsedProvider.notifier).state = true,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.expand_less_rounded,
                      size: 16.0,
                      color: palette.textMuted,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Minimise to map view',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TODO(question): $feature coming soon!')),
    );
  }
}
