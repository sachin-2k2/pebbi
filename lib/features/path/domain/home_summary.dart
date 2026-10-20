/// Pure domain model representing display counters and active summary for Home.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class HomeSummary {
  const HomeSummary({
    this.language = 'Español',
    this.languageGlyph = 'Ñ',
    this.streakCount = 1,
    this.starsCount = 10,
    this.dueCount = 0,
    this.hasAnyPhrases = true,
    this.levelName = 'Little mode',
    this.levelCaption = 'tap your profile to change it',
    this.currentStopId = '1',
    this.currentStopTitle = 'Say hello',
    this.estimatedMinutes = 3,
    this.isPremium = false,
  });

  final String language;
  final String languageGlyph;
  final int streakCount;
  final int starsCount;
  final int dueCount;
  final bool hasAnyPhrases;
  final String levelName;
  final String levelCaption;
  final String currentStopId;
  final String currentStopTitle;
  final int estimatedMinutes;
  final bool isPremium;
}
