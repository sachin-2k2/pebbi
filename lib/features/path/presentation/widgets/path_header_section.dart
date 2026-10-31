import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'top_pills.dart';
import 'track_chip_row.dart';

/// Top section of the Path screen containing pills, tracks, continue card, and due banner.
///
/// Follows AGENTS.md §3: Extracted widget keeping layouts under 150 lines.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        LevelHint(onTap: () => context.go('/settings')),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: ContinueCard(
            title: summary.currentStopTitle,
            subtitle: AppStrings.continueCaption(summary.estimatedMinutes),
            onPlayPressed: () => context.push('/lesson/${summary.currentStopId}'),
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
      ],
    );
  }

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TODO(question): $feature coming soon!')),
    );
  }
}

