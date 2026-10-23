import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/missions/domain/correction_style.dart';
import 'package:peddi/features/missions/domain/mission_brief.dart';
import 'package:peddi/features/missions/domain/mission_goal.dart';
import 'package:peddi/features/missions/domain/mission_mode.dart';
import 'package:peddi/features/missions/domain/mission_support.dart';
import 'package:peddi/features/missions/domain/session_config.dart';
import 'package:peddi/features/missions/domain/start_mission_gate.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('StartMissionGate Domain Tests', () {
    const defaultBrief = MissionBrief(
      missionId: 'order_coffee',
      emoji: '☕',
      title: 'Order a coffee',
      characterName: 'Lucía',
      characterRole: 'barista',
      sceneLine: 'A busy café, morning rush',
      goals: [
        MissionGoal(id: 'g1', text: 'Order a drink'),
        MissionGoal(id: 'g2', text: 'Ask the price'),
      ],
      estimatedMinutes: 5,
      difficulty: 1,
      languageCode: 'es',
    );

    const regularUser = UserProfile(
      userId: 'user_123',
      ageBand: AgeBand.adult,
      targetLanguageCode: 'es',
      explanationLanguageCode: 'en',
      reasonIds: {},
      dailyGoalId: 'goal_casual',
      reminderTime: ReminderTime(hour: 9, minute: 0),
      selectedWeekdayNumbers: {1, 2, 3, 4, 5},
      remindersEnabled: true,
      accentId: 'violet',
      plan: 'free',
    );

    test('Returns needsInternet when isOffline is true', () {
      final outcome = StartMissionGate.evaluate(
        isOffline: true,
        user: regularUser,
        brief: defaultBrief,
        selectedMode: MissionMode.chat,
        selectedSupport: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        hasMicPermission: true,
        explanationLanguageCode: 'en',
      );

      expect(outcome.type, StartMissionOutcomeType.needsInternet);
      expect(outcome.isReady, isFalse);
    });

    test(
      'Returns needsPremium when mission is premium and user is not premium',
      () {
        final premiumBrief = defaultBrief.copyWith(isPremium: true);

        final outcome = StartMissionGate.evaluate(
          isOffline: false,
          user: regularUser,
          brief: premiumBrief,
          selectedMode: MissionMode.chat,
          selectedSupport: MissionSupport.guided,
          correctionStyle: CorrectionStyle.gentle,
          captionsOn: true,
          hasMicPermission: true,
          explanationLanguageCode: 'en',
        );

        expect(outcome.type, StartMissionOutcomeType.needsPremium);
        expect(outcome.isReady, isFalse);
      },
    );

    test('Allows premium mission when user has premium entitlement', () {
      final premiumBrief = defaultBrief.copyWith(isPremium: true);
      final premiumUser = regularUser.copyWith(plan: 'premium');

      final outcome = StartMissionGate.evaluate(
        isOffline: false,
        user: premiumUser,
        brief: premiumBrief,
        selectedMode: MissionMode.chat,
        selectedSupport: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        hasMicPermission: true,
        explanationLanguageCode: 'en',
      );

      expect(outcome.type, StartMissionOutcomeType.ready);
      expect(outcome.isReady, isTrue);
      expect(outcome.sessionConfig?.missionId, 'order_coffee');
    });

    test(
      'Falls back to Chat when Voice mode selected but mic permission is denied',
      () {
        final outcome = StartMissionGate.evaluate(
          isOffline: false,
          user: regularUser,
          brief: defaultBrief,
          selectedMode: MissionMode.voice,
          selectedSupport: MissionSupport.lightHints,
          correctionStyle: CorrectionStyle.live,
          captionsOn: false,
          hasMicPermission: false,
          explanationLanguageCode: 'en',
        );

        expect(
          outcome.type,
          StartMissionOutcomeType.voicePermissionDeniedFallbackToChat,
        );
        expect(outcome.sessionConfig?.mode, MissionMode.chat);
        expect(outcome.sessionConfig?.support, MissionSupport.lightHints);
        expect(outcome.sessionConfig?.correctionStyle, CorrectionStyle.live);
        expect(outcome.sessionConfig?.captionsOn, isFalse);
      },
    );

    test('Returns ready with complete SessionConfig when all checks pass', () {
      final outcome = StartMissionGate.evaluate(
        isOffline: false,
        user: regularUser,
        brief: defaultBrief,
        selectedMode: MissionMode.voice,
        selectedSupport: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        hasMicPermission: true,
        explanationLanguageCode: 'en',
      );

      expect(outcome.type, StartMissionOutcomeType.ready);
      expect(outcome.isReady, isTrue);

      final config = outcome.sessionConfig!;
      expect(config.missionId, 'order_coffee');
      expect(config.mode, MissionMode.voice);
      expect(config.support, MissionSupport.guided);
      expect(config.correctionStyle, CorrectionStyle.gentle);
      expect(config.captionsOn, isTrue);
      expect(config.targetLanguageCode, 'es');
      expect(config.explanationLanguageCode, 'en');
    });

    test('MissionMode and MissionSupport id resolution and properties', () {
      expect(MissionMode.fromId('voice'), MissionMode.voice);
      expect(MissionMode.fromId('chat'), MissionMode.chat);
      expect(MissionMode.fromId('unknown'), MissionMode.chat);

      expect(MissionSupport.fromId('light_hints'), MissionSupport.lightHints);
      expect(MissionSupport.fromId('guided'), MissionSupport.guided);
      expect(MissionSupport.fromId('invalid'), MissionSupport.guided);

      expect(MissionSupport.guided.hasSuggestedReplies, isTrue);
      expect(MissionSupport.lightHints.hasSuggestedReplies, isFalse);
    });

    test('SessionConfig equality and hashcode', () {
      const config1 = SessionConfig(
        missionId: 'order_coffee',
        mode: MissionMode.chat,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
      );
      const config2 = SessionConfig(
        missionId: 'order_coffee',
        mode: MissionMode.chat,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
      );

      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
    });
  });
}
