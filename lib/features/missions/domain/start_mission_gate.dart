import '../../auth/domain/user_profile.dart';
import '../../onboarding/domain/age_band.dart';
import 'correction_style.dart';
import 'mission_access_rules.dart';
import 'mission_brief.dart';
import 'mission_mode.dart';
import 'mission_summary.dart';
import 'mission_support.dart';
import 'session_config.dart';

/// Outcomes produced by [StartMissionGate.evaluate].
enum StartMissionOutcomeType {
  ready,
  needsInternet,
  needsPremium,
  limitReached,
  childSafetyBlocked,
  voicePermissionDeniedFallbackToChat,
}

class StartMissionOutcome {
  const StartMissionOutcome._(this.type, {this.sessionConfig});

  factory StartMissionOutcome.ready(SessionConfig config) =>
      StartMissionOutcome._(
        StartMissionOutcomeType.ready,
        sessionConfig: config,
      );

  factory StartMissionOutcome.needsInternet() =>
      const StartMissionOutcome._(StartMissionOutcomeType.needsInternet);

  factory StartMissionOutcome.needsPremium() =>
      const StartMissionOutcome._(StartMissionOutcomeType.needsPremium);

  factory StartMissionOutcome.limitReached() =>
      const StartMissionOutcome._(StartMissionOutcomeType.limitReached);

  factory StartMissionOutcome.childSafetyBlocked() =>
      const StartMissionOutcome._(StartMissionOutcomeType.childSafetyBlocked);

  factory StartMissionOutcome.voicePermissionDeniedFallbackToChat(
    SessionConfig fallbackConfig,
  ) => StartMissionOutcome._(
    StartMissionOutcomeType.voicePermissionDeniedFallbackToChat,
    sessionConfig: fallbackConfig,
  );

  final StartMissionOutcomeType type;
  final SessionConfig? sessionConfig;

  bool get isReady => type == StartMissionOutcomeType.ready;
}

/// Pure Dart gate evaluating pre-start mission conditions in strict order.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class StartMissionGate {
  /// Evaluates pre-start readiness in strict order:
  /// 1. Offline connectivity
  /// 2. Subscription & quota access rules
  /// 3. Child safety age band validation
  /// 4. Microphone permissions for Voice mode (falls back to Chat if denied)
  static StartMissionOutcome evaluate({
    required bool isOffline,
    required UserProfile? user,
    required MissionBrief brief,
    required MissionMode selectedMode,
    required MissionSupport selectedSupport,
    required CorrectionStyle correctionStyle,
    required bool captionsOn,
    required bool hasMicPermission,
    required String explanationLanguageCode,
    int level = 1,
  }) {
    // 1. Offline check: AI role-play conversation requires internet
    if (isOffline) {
      return StartMissionOutcome.needsInternet();
    }

    // 2. Subscription & quota access check
    final summary = MissionSummary(
      id: brief.missionId,
      categoryIds: const [],
      title: brief.title,
      characterName: brief.characterName,
      characterRole: brief.characterRole,
      durationMinutes: brief.estimatedMinutes,
      difficulty: brief.difficulty,
      emoji: brief.emoji,
      status: brief.status,
      isPremium: brief.isPremium,
    );

    final access = MissionAccessRules.missionAccess(user, summary);
    if (access == MissionAccessResult.needsPremium) {
      return StartMissionOutcome.needsPremium();
    }
    if (access == MissionAccessResult.limitReached) {
      return StartMissionOutcome.limitReached();
    }

    // 3. Child safety check
    final ageBand = user?.ageBand ?? AgeBand.adult;
    if (!MissionAccessRules.shouldShowMissions(ageBand)) {
      return StartMissionOutcome.childSafetyBlocked();
    }

    // 4. Voice permission check
    if (selectedMode == MissionMode.voice && !hasMicPermission) {
      final fallbackConfig = SessionConfig(
        missionId: brief.missionId,
        mode: MissionMode.chat,
        support: selectedSupport,
        correctionStyle: correctionStyle,
        captionsOn: captionsOn,
        targetLanguageCode: brief.languageCode,
        explanationLanguageCode: explanationLanguageCode,
        level: level,
      );
      return StartMissionOutcome.voicePermissionDeniedFallbackToChat(
        fallbackConfig,
      );
    }

    // 5. Success: launch session
    final config = SessionConfig(
      missionId: brief.missionId,
      mode: selectedMode,
      support: selectedSupport,
      correctionStyle: correctionStyle,
      captionsOn: captionsOn,
      targetLanguageCode: brief.languageCode,
      explanationLanguageCode: explanationLanguageCode,
      level: level,
    );

    return StartMissionOutcome.ready(config);
  }
}
