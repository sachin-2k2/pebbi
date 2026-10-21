import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/missions/domain/correction_style.dart';
import 'package:peddi/features/missions/domain/free_talk_access_rules.dart';
import 'package:peddi/features/missions/domain/free_talk_safety_rules.dart';
import 'package:peddi/features/missions/domain/free_talk_topic.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('CorrectionStyle', () {
    test('resolves from valid IDs', () {
      expect(CorrectionStyle.fromId('gentle'), CorrectionStyle.gentle);
      expect(CorrectionStyle.fromId('live'), CorrectionStyle.live);
      expect(CorrectionStyle.fromId('none'), CorrectionStyle.none);
    });

    test('defaults to gentle on null or invalid IDs', () {
      expect(CorrectionStyle.fromId(null), CorrectionStyle.gentle);
      expect(CorrectionStyle.fromId(''), CorrectionStyle.gentle);
      expect(CorrectionStyle.fromId('unknown'), CorrectionStyle.gentle);
    });

    test('exposes correct stable IDs', () {
      expect(CorrectionStyle.gentle.id, 'gentle');
      expect(CorrectionStyle.live.id, 'live');
      expect(CorrectionStyle.none.id, 'none');
    });
  });

  group('FreeTalkTopic', () {
    test('instantiates with defaults and supports equality', () {
      const topic1 = FreeTalkTopic(id: 'food', label: 'Food & drinks');
      const topic2 = FreeTalkTopic(id: 'food', label: 'Food & drinks');
      const topicCustom = FreeTalkTopic(
        id: 'custom',
        label: 'My own',
        isCustom: true,
      );

      expect(topic1.isCustom, isFalse);
      expect(topicCustom.isCustom, isTrue);
      expect(topic1, equals(topic2));
      expect(topic1.hashCode, equals(topic2.hashCode));
      expect(topic1, isNot(equals(topicCustom)));
    });
  });

  group('FreeTalkSafetyRules', () {
    test('permits free talk for all age bands', () {
      expect(FreeTalkSafetyRules.shouldAllowFreeTalk(AgeBand.child), isTrue);
      expect(FreeTalkSafetyRules.shouldAllowFreeTalk(AgeBand.teen), isTrue);
      expect(FreeTalkSafetyRules.shouldAllowFreeTalk(AgeBand.adult), isTrue);
    });

    test('allowedTopics returns catalog unmodified for now', () {
      const catalog = [
        FreeTalkTopic(id: 'today', label: 'How was your day?'),
        FreeTalkTopic(id: 'news', label: 'News & politics'),
      ];
      final childTopics = FreeTalkSafetyRules.allowedTopics(
        AgeBand.child,
        catalog,
      );
      expect(childTopics, equals(catalog));
    });

    test('isTopicAllowed validates non-empty and length limits', () {
      expect(FreeTalkSafetyRules.isTopicAllowed(''), isFalse);
      expect(FreeTalkSafetyRules.isTopicAllowed('   '), isFalse);
      expect(FreeTalkSafetyRules.isTopicAllowed('A'), isTrue);
      expect(
        FreeTalkSafetyRules.isTopicAllowed('My summer holiday plans'),
        isTrue,
      );

      final exactly60 = 'A' * maxCustomTopicLength;
      expect(FreeTalkSafetyRules.isTopicAllowed(exactly60), isTrue);

      final over60 = 'A' * (maxCustomTopicLength + 1);
      expect(FreeTalkSafetyRules.isTopicAllowed(over60), isFalse);
    });
  });

  group('FreeTalkAccessRules', () {
    const freeUser = UserProfile(
      userId: 'user_free',
      ageBand: AgeBand.adult,
      explanationLanguageCode: 'en',
      targetLanguageCode: 'es',
      reasonIds: {},
      dailyGoalId: 'casual',
      reminderTime: ReminderTime(hour: 9, minute: 0),
      selectedWeekdayNumbers: {1},
      remindersEnabled: false,
      accentId: 'violet',
      plan: 'free',
    );

    const premiumUser = UserProfile(
      userId: 'user_premium',
      ageBand: AgeBand.adult,
      explanationLanguageCode: 'en',
      targetLanguageCode: 'es',
      reasonIds: {},
      dailyGoalId: 'casual',
      reminderTime: ReminderTime(hour: 9, minute: 0),
      selectedWeekdayNumbers: {1},
      remindersEnabled: false,
      accentId: 'violet',
      plan: 'premium',
    );

    test('evaluates access for free, premium, and guest users', () {
      expect(FreeTalkAccessRules.evaluate(freeUser), FreeTalkAccess.allowed);
      expect(FreeTalkAccessRules.evaluate(premiumUser), FreeTalkAccess.allowed);
      expect(FreeTalkAccessRules.evaluate(null), FreeTalkAccess.allowed);
    });
  });
}
