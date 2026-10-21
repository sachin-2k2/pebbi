import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/practice_summary.dart';
import '../providers/review_provider.dart';
import 'phrase_count_line.dart';
import 'practice_coming_soon_note.dart';
import 'practice_rooms_list.dart';

/// Presentation widget composing the "Practice" sub-tab view.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.
class PracticeTab extends ConsumerWidget {
  const PracticeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(practiceSummaryProvider);
    final rooms = ref.watch(practiceRoomsProvider);
    final summary = summaryAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const PracticeSummary(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PracticeRoomsList(rooms: rooms, summary: summary),
        const SizedBox(height: AppSpacing.md),
        const PracticeComingSoonNote(),
        const SizedBox(height: AppSpacing.sm),
        PhraseCountLine(count: summary.reviewedPhraseCount),
      ],
    );
  }
}
