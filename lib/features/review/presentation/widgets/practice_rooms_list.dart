import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/practice_availability.dart';
import '../../domain/practice_mode.dart';
import '../../domain/practice_room.dart';
import '../../domain/practice_summary.dart';
import 'practice_room_tile.dart';

/// Renders the list of practice room cards with availability evaluation on tap.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.
class PracticeRoomsList extends StatelessWidget {
  const PracticeRoomsList({
    super.key,
    required this.rooms,
    required this.summary,
  });

  final List<PracticeRoom> rooms;
  final PracticeSummary summary;

  void _handleTap(BuildContext context, PracticeRoom room) {
    final availability = evaluatePracticeAvailability(room.mode, summary);

    if (availability.isAvailable) {
      context.push('/review/practice?mode=${room.mode.paramValue}');
      return;
    }

    String message;
    switch (availability.status) {
      case PracticeAvailabilityStatus.unlockFirstLesson:
        message = AppStrings.practiceUnlockFirstLesson;
        break;
      case PracticeAvailabilityStatus.noFlashcardsYet:
        message = AppStrings.practiceNoFlashcards;
        break;
      case PracticeAvailabilityStatus.noTrickyPhrases:
        message = AppStrings.practiceNoTricky;
        break;
      case PracticeAvailabilityStatus.available:
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  (String title, String subtitle) _roomCopy(PracticeRoom room) {
    switch (room.mode) {
      case PracticeMode.mix2min:
        return (
          AppStrings.practice2MinTitle(summary.mixMinutes),
          AppStrings.practice2MinSubtitle,
        );
      case PracticeMode.flashcards:
        return (
          AppStrings.practiceFlashcardsTitle,
          AppStrings.practiceFlashcardsSubtitle(summary.flashcardCount),
        );
      case PracticeMode.tricky:
        return (
          AppStrings.practiceTrickyTitle,
          AppStrings.practiceTrickySubtitle(summary.trickyCount),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rooms.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          Builder(
            builder: (ctx) {
              final room = rooms[i];
              final (title, subtitle) = _roomCopy(room);
              return PracticeRoomTile(
                room: room,
                title: title,
                subtitle: subtitle,
                onTap: () => _handleTap(context, room),
              );
            },
          ),
        ],
      ],
    );
  }
}
