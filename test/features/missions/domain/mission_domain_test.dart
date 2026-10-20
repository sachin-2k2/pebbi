import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/missions/domain/mission_access_rules.dart';
import 'package:peddi/features/missions/domain/mission_category.dart';
import 'package:peddi/features/missions/domain/mission_summary.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('MissionSummary Domain Model', () {
    test('clamps difficulty below 1 to 1', () {
      const summary = MissionSummary(
        id: 'test_low',
        categoryIds: ['everyday'],
        title: 'Test Low',
        characterName: 'Tester',
        characterRole: 'role',
        durationMinutes: 5,
        difficulty: 0,
        emoji: '☕',
      );
      expect(summary.difficulty, 1);
    });

    test('clamps difficulty above 3 to 3', () {
      const summary = MissionSummary(
        id: 'test_high',
        categoryIds: ['everyday'],
        title: 'Test High',
        characterName: 'Tester',
        characterRole: 'role',
        durationMinutes: 5,
        difficulty: 5,
        emoji: '☕',
      );
      expect(summary.difficulty, 3);
    });

    test('retains valid difficulty within 1..3', () {
      const summary = MissionSummary(
        id: 'test_valid',
        categoryIds: ['everyday'],
        title: 'Test Valid',
        characterName: 'Tester',
        characterRole: 'role',
        durationMinutes: 5,
        difficulty: 2,
        emoji: '☕',
      );
      expect(summary.difficulty, 2);
    });
  });

  group('MissionAccessRules', () {
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

    const standardMission = MissionSummary(
      id: 'free_mission',
      categoryIds: ['everyday'],
      title: 'Free Mission',
      characterName: 'Lucía',
      characterRole: 'barista',
      durationMinutes: 5,
      difficulty: 1,
      emoji: '☕',
      isPremium: false,
    );

    const premiumMission = MissionSummary(
      id: 'premium_mission',
      categoryIds: ['social'],
      title: 'Premium Mission',
      characterName: 'Elena',
      characterRole: 'manager',
      durationMinutes: 8,
      difficulty: 3,
      emoji: '💼',
      isPremium: true,
    );

    test('free mission is allowed for free users and guests', () {
      expect(
        MissionAccessRules.missionAccess(freeUser, standardMission),
        MissionAccessResult.allowed,
      );
      expect(
        MissionAccessRules.missionAccess(null, standardMission),
        MissionAccessResult.allowed,
      );
    });

    test('premium mission requires premium plan', () {
      expect(
        MissionAccessRules.missionAccess(freeUser, premiumMission),
        MissionAccessResult.needsPremium,
      );
      expect(
        MissionAccessRules.missionAccess(null, premiumMission),
        MissionAccessResult.needsPremium,
      );
      expect(
        MissionAccessRules.missionAccess(premiumUser, premiumMission),
        MissionAccessResult.allowed,
      );
    });

    test('child safety rules default to allowed with TODO questions', () {
      expect(MissionAccessRules.shouldShowMissions(AgeBand.child), isTrue);
      expect(MissionAccessRules.shouldShowMissions(AgeBand.adult), isTrue);
      expect(MissionAccessRules.shouldAllowFreeTalk(AgeBand.child), isTrue);
      expect(MissionAccessRules.shouldAllowFreeTalk(AgeBand.adult), isTrue);
    });
  });

  group('MissionCategory Domain Model', () {
    test('equality and properties', () {
      const cat1 = MissionCategory(id: 'travel', title: 'Travel');
      const cat2 = MissionCategory(id: 'travel', title: 'Travel');
      const cat3 = MissionCategory(id: 'health', title: 'Health');

      expect(cat1, equals(cat2));
      expect(cat1, isNot(equals(cat3)));
    });
  });
}
