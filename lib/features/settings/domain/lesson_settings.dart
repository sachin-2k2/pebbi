/// User settings governing exercise behavior, audio playback, and visual helpers.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonSettings {
  const LessonSettings({
    this.autoplay = false,
    this.showHelperLine = false,
    this.soundEffects = true,
  });

  /// Whether speech audio autoplays when an exercise screen loads.
  final bool autoplay;

  /// Whether transliteration or romanization helper lines are shown beneath phrases.
  final bool showHelperLine;

  /// Whether gamified sound effects (chimes, buzzes) play on answers.
  final bool soundEffects;

  LessonSettings copyWith({
    bool? autoplay,
    bool? showHelperLine,
    bool? soundEffects,
  }) {
    return LessonSettings(
      autoplay: autoplay ?? this.autoplay,
      showHelperLine: showHelperLine ?? this.showHelperLine,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }
}
