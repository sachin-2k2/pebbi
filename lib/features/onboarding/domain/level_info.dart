import 'language_level.dart';

/// Central presentation and localization metadata for [LanguageLevel].
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// Reusable across Placement Results and Settings courses.
class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.emoji,
    required this.name,
    required this.description,
    required this.title,
    required this.whatHappensNowText,
  });

  final LanguageLevel level;
  final String emoji;
  final String name;
  final String description;
  final String title;
  final String whatHappensNowText;

  static const LevelInfo little = LevelInfo(
    level: LanguageLevel.little,
    emoji: '🐣',
    name: 'Little',
    description: 'Gentle questions with plenty of help',
    title: "You're a Little learner",
    whatHappensNowText:
        'Your lessons tune themselves to little — gentle questions with plenty of help. And any unit you feel ready to skip has a “Test out” door waiting.',
  );

  static const LevelInfo knowABit = LevelInfo(
    level: LanguageLevel.knowABit,
    emoji: '🐥',
    name: 'Know a bit',
    description: 'A mix of easy and harder questions',
    title: "You're a Know a bit learner",
    whatHappensNowText:
        'Your lessons tune themselves to know a bit — a mix of easy and harder questions. And any unit you feel ready to skip has a “Test out” door waiting.',
  );

  static const LevelInfo expert = LevelInfo(
    level: LanguageLevel.expert,
    emoji: '🦉',
    name: 'Expert',
    description: 'Tough questions, fewer hints',
    // English grammar fix: "an Expert" instead of "a Expert"
    title: "You're an Expert learner",
    whatHappensNowText:
        'Your lessons tune themselves to expert — tough questions, fewer hints. And any unit you feel ready to skip has a “Test out” door waiting.',
  );

  static const List<LevelInfo> allLevels = [little, knowABit, expert];

  /// Returns [LevelInfo] matching [level].
  static LevelInfo forLevel(LanguageLevel level) {
    switch (level) {
      case LanguageLevel.little:
        return little;
      case LanguageLevel.knowABit:
        return knowABit;
      case LanguageLevel.expert:
        return expert;
    }
  }
}
