import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/home_summary.dart';
import '../providers/ad_banner_provider.dart';
import '../providers/path_provider.dart';
import 'ad_banner.dart';
import 'continue_card.dart';
import 'due_strip.dart';
import 'level_hint.dart';
import 'path_compact_continue_bar.dart';

/// Collapsible summary section containing Continue card, Due strip, and Ad.
///
/// Follows AGENTS.md §3 (<150 lines) and supports text scaling up to 2.0x.
class PathSummarySection extends ConsumerWidget {
  const PathSummarySection({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAds = ref.watch(shouldShowAdBannerProvider);
    final activeAd = ref.watch(activeAdBannerProvider).valueOrNull;
    final isCollapsed = ref.watch(pathSummaryCollapsedProvider);
    final palette = context.palette;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: PathCompactContinueBar(
          title: summary.currentStopTitle,
          subtitle: AppStrings.continueCaption(summary.estimatedMinutes),
          dueCount: summary.dueCount,
          onPlayPressed: () => context.push('/lesson/${summary.currentStopId}'),
          onReviewPressed: () => context.go('/review'),
          onExpandPressed: () =>
              ref.read(pathSummaryCollapsedProvider.notifier).state = false,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.expand_less_rounded,
                    size: 16.0,
                    color: palette.textMuted,
                  ),
                  const SizedBox(width: 4.0),
                  Flexible(
                    child: Text(
                      'Minimise to map view',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: palette.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

