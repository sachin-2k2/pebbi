import 'correction_style.dart';
import 'mission_mode.dart';
import 'mission_support.dart';

/// Configuration payload passed to start a role-play conversation session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class SessionConfig {
  const SessionConfig({
    required this.missionId,
    required this.mode,
    required this.support,
    required this.correctionStyle,
    required this.captionsOn,
    required this.targetLanguageCode,
    required this.explanationLanguageCode,
    this.level = 1,
  });

  final String missionId;
  final MissionMode mode;
  final MissionSupport support;
  final CorrectionStyle correctionStyle;
  final bool captionsOn;
  final String targetLanguageCode;
  final String explanationLanguageCode;
  final int level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionConfig &&
          runtimeType == other.runtimeType &&
          missionId == other.missionId &&
          mode == other.mode &&
          support == other.support &&
          correctionStyle == other.correctionStyle &&
          captionsOn == other.captionsOn &&
          targetLanguageCode == other.targetLanguageCode &&
          explanationLanguageCode == other.explanationLanguageCode &&
          level == other.level;

  @override
  int get hashCode => Object.hash(
    missionId,
    mode,
    support,
    correctionStyle,
    captionsOn,
    targetLanguageCode,
    explanationLanguageCode,
    level,
  );
}
