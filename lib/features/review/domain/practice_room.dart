import 'practice_mode.dart';
import 'practice_room_tone.dart';

/// Configuration definition for a practice room card.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class PracticeRoom {
  const PracticeRoom({
    required this.id,
    required this.mode,
    required this.tone,
    required this.hasCta,
    required this.iconName,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String id;
  final PracticeMode mode;
  final PracticeRoomTone tone;
  final bool hasCta;
  final String iconName;
  final String titleKey;
  final String subtitleKey;

  static const List<PracticeRoom> defaultRooms = [
    PracticeRoom(
      id: 'mix2min',
      mode: PracticeMode.mix2min,
      tone: PracticeRoomTone.lavender,
      hasCta: true,
      iconName: 'sparkle',
      titleKey: 'practice2MinTitle',
      subtitleKey: 'practice2MinSubtitle',
    ),
    PracticeRoom(
      id: 'flashcards',
      mode: PracticeMode.flashcards,
      tone: PracticeRoomTone.yellow,
      hasCta: false,
      iconName: 'layers',
      titleKey: 'practiceFlashcardsTitle',
      subtitleKey: 'practiceFlashcardsSubtitle',
    ),
    PracticeRoom(
      id: 'tricky',
      mode: PracticeMode.tricky,
      tone: PracticeRoomTone.mint,
      hasCta: false,
      iconName: 'star',
      titleKey: 'practiceTrickyTitle',
      subtitleKey: 'practiceTrickySubtitle',
    ),
  ];
}
