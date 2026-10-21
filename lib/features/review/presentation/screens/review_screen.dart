import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/segmented_tabs.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/review_segment.dart';
import '../providers/review_provider.dart';
import '../widgets/add_phrase_sheet.dart';
import '../widgets/library_tab.dart';
import '../widgets/phrases_tab.dart';
import '../widgets/practice_tab.dart';
import '../widgets/review_header.dart';
import '../widgets/review_invite_card.dart';

/// Top-level Review screen presenting Phrases, Practice, and Library sub-tabs.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4 (responsive width).
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  void _openAddPhraseSheet(BuildContext context) {
    AdaptiveSheet.show(
      context: context,
      builder: (_) => const AddPhraseSheet(),
    );
  }

  String _segmentLabel(ReviewSegment segment) {
    switch (segment) {
      case ReviewSegment.phrases:
        return AppStrings.tabPhrases;
      case ReviewSegment.practice:
        return AppStrings.tabPractice;
      case ReviewSegment.library:
        return AppStrings.tabLibrary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ref.watch(reviewSegmentProvider);

    return Scaffold(
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 580.0,
          child: SingleChildScrollView(
            key: const PageStorageKey<String>('review_scroll_view'),
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReviewHeader(onAddPressed: () => _openAddPhraseSheet(context)),
                const SizedBox(height: AppSpacing.md),
                SegmentedTabs<ReviewSegment>(
                  items: ReviewSegment.values,
                  selectedItem: segment,
                  labelBuilder: _segmentLabel,
                  onSelected: (val) {
                    ref.read(reviewSegmentProvider.notifier).state = val;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const ReviewInviteCard(),
                const SizedBox(height: AppSpacing.md),
                _ReviewSegmentBody(segment: segment),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewSegmentBody extends StatelessWidget {
  const _ReviewSegmentBody({required this.segment});

  final ReviewSegment segment;

  @override
  Widget build(BuildContext context) {
    switch (segment) {
      case ReviewSegment.phrases:
        return const PhrasesTab();
      case ReviewSegment.practice:
        return const PracticeTab();
      case ReviewSegment.library:
        return const LibraryTab();
    }
  }
}
