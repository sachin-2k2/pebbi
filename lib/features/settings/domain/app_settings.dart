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
  });

  /// Identifier for the active user accent ('violet', 'green', 'orange', 'blue', 'pink', 'slate').
  final String accentId;

  /// Whether sound effects and speech preview audio are enabled.
  final bool soundEnabled;

  /// Whether haptic feedback vibrations are enabled.
  final bool hapticsEnabled;

  /// Whether animation motion should be reduced.
  final bool reduceMotion;

  /// In-app text size scale multiplier.
  final double textScale;

  /// Whether UI elements adapt for left-handed thumb access.
  final bool isLeftHanded;

  /// The 32-bit ARGB colour value corresponding to [accentId].
  int get accentColorValue => AccentOption.findById(accentId).colorValue;

  AppSettings copyWith({
    String? accentId,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reduceMotion,
    double? textScale,
    bool? isLeftHanded,
  }) {
    return AppSettings(
      accentId: accentId ?? this.accentId,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScale: textScale ?? this.textScale,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
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
          isLeftHanded == other.isLeftHanded;

  @override
  int get hashCode => Object.hash(
    accentId,
    soundEnabled,
    hapticsEnabled,
    reduceMotion,
    textScale,
    isLeftHanded,
  );
}
