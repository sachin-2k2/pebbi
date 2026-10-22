import '../../onboarding/domain/accent_option.dart';

/// Pure Dart domain model representing user application settings.
///
/// Follows AGENTS.md §2.2 & §2.3: Zero Flutter imports, pure state.
class AppSettings {
  const AppSettings({
    this.accentId = AccentOption.defaultAccentId,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reduceMotion = false,
    this.textScale = 1.0,
    this.isLeftHanded = false,
    this.themeMode = 'light',
    this.showHelperLine = true,
    this.autoplay = true,
    this.speakingPracticeEnabled = true,
    this.captionsAlwaysOn = true,
    this.firstName,
  });

  /// Identifier for the active user accent ('violet', 'green', 'orange', 'blue', 'pink', 'slate').
  final String accentId;

  /// Whether sound effects and speech preview audio are enabled.
  final bool soundEnabled;

  /// Whether haptic feedback vibrations are enabled.
  final bool hapticsEnabled;

  /// Whether animation motion should be reduced.
  final bool reduceMotion;

  /// In-app text size scale multiplier (0.85 .. 1.30).
  final double textScale;

  /// Whether UI elements adapt for left-handed thumb access.
  final bool isLeftHanded;

  /// Theme brightness preference ('light', 'dark', 'system').
  final String themeMode;

  /// Whether romanization/transliteration helper lines are shown.
  final bool showHelperLine;

  /// Whether speech audio autoplays upon phrase presentation.
  final bool autoplay;

  /// Whether speaking practice tasks are active (if false, falls back to self-check).
  final bool speakingPracticeEnabled;

  /// Whether subtitles and translations are persistently rendered in AI missions.
  final bool captionsAlwaysOn;

  /// Optional learner first name.
  final String? firstName;

  /// The 32-bit ARGB colour value corresponding to [accentId].
  int get accentColorValue => AccentOption.findById(accentId).colorValue;

  AppSettings copyWith({
    String? accentId,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reduceMotion,
    double? textScale,
    bool? isLeftHanded,
    String? themeMode,
    bool? showHelperLine,
    bool? autoplay,
    bool? speakingPracticeEnabled,
    bool? captionsAlwaysOn,
    String? firstName,
    bool clearFirstName = false,
  }) {
    return AppSettings(
      accentId: accentId ?? this.accentId,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScale: textScale ?? this.textScale,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
      themeMode: themeMode ?? this.themeMode,
      showHelperLine: showHelperLine ?? this.showHelperLine,
      autoplay: autoplay ?? this.autoplay,
      speakingPracticeEnabled:
          speakingPracticeEnabled ?? this.speakingPracticeEnabled,
      captionsAlwaysOn: captionsAlwaysOn ?? this.captionsAlwaysOn,
      firstName: clearFirstName ? null : (firstName ?? this.firstName),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          accentId == other.accentId &&
          soundEnabled == other.soundEnabled &&
          hapticsEnabled == other.hapticsEnabled &&
          reduceMotion == other.reduceMotion &&
          textScale == other.textScale &&
          isLeftHanded == other.isLeftHanded &&
          themeMode == other.themeMode &&
          showHelperLine == other.showHelperLine &&
          autoplay == other.autoplay &&
          speakingPracticeEnabled == other.speakingPracticeEnabled &&
          captionsAlwaysOn == other.captionsAlwaysOn &&
          firstName == other.firstName;

  @override
  int get hashCode => Object.hash(
    accentId,
    soundEnabled,
    hapticsEnabled,
    reduceMotion,
    textScale,
    isLeftHanded,
    themeMode,
    showHelperLine,
    autoplay,
    speakingPracticeEnabled,
    captionsAlwaysOn,
    firstName,
  );
}
