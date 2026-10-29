import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/data/dtos/profile_update_request_dto.dart';
import 'package:peddi/features/auth/data/dtos/profile_update_response_dto.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('ProfileUpdateRequestDto', () {
    test('toJson outputs only non-null and non-empty fields matching API-V2.md §10', () {
      const dto = ProfileUpdateRequestDto(
        displayName: 'Farsana K',
        currentLevel: 'know_a_bit',
        dailyGoal: 'intense',
        reminderTime: '20:30',
        reminderDays: ['Monday', 'Tuesday', 'Thursday', 'Saturday'],
        accentColor: 'green',
      );

      final json = dto.toJson();

      expect(json, equals({
        'display_name': 'Farsana K',
        'current_level': 'know_a_bit',
        'daily_goal': 'intense',
        'reminder_time': '20:30',
        'reminder_days': ['Monday', 'Tuesday', 'Thursday', 'Saturday'],
        'accent_color': 'green',
      }));
    });

    test('toJson with minimal partial fields only outputs those keys', () {
      const dto = ProfileUpdateRequestDto(
        accentColor: 'pink',
      );

      final json = dto.toJson();

      expect(json, equals({
        'accent_color': 'pink',
      }));
    });

    test('fromProfile correctly maps full UserProfile domain model to DTO', () {
      const profile = UserProfile(
        userId: '671cc85341f237bf81d2a191',
        firstName: 'Farsana K',
        email: 'user@example.com',
        ageBand: AgeBand.band18_24,
        explanationLanguageCode: 'ml',
        targetLanguageCode: 'en',
        reasonIds: {'travel', 'work'},
        selectedLevel: LanguageLevel.knowABit,
        dailyGoalId: 'intense',
        reminderTime: ReminderTime(hour: 20, minute: 30),
        selectedWeekdayNumbers: {1, 2, 4, 6},
        remindersEnabled: true,
        accentId: 'green',
        plan: 'free',
      );

      final dto = ProfileUpdateRequestDto.fromProfile(profile);
      final json = dto.toJson();

      expect(json['display_name'], equals('Farsana K'));
      expect(json['current_level'], equals('know_a_bit'));
      expect(json['daily_goal'], equals('intense'));
      expect(json['reminder_time'], equals('20:30'));
      expect(json['reminder_days'], equals(['Monday', 'Tuesday', 'Thursday', 'Saturday']));
      expect(json['accent_color'], equals('green'));
      expect(json['age_band'], equals('18-24'));
      expect(json['learning_goals'], containsAll(['travel', 'work']));
      expect(json['native_language'], equals('ml'));
      expect(json['learning_language'], equals('en'));
    });
  });

  group('ProfileUpdateResponseDto', () {
    test('parses API-V2.md §10 response sample and maps to domain model', () {
      final sampleJson = {
        'message': 'Profile updated successfully',
        'user': {
          'id': '671cc85341f237bf81d2a191',
          'display_name': 'Farsana K',
          'email': 'user@example.com',
          'native_language': 'ml',
          'learning_language': 'en',
          'current_level': 'know_a_bit',
          'level': 'know_a_bit',
          'suggested_level': 'starter',
          'placement_skipped': false,
          'placement_score': 6,
          'placement_total': 8,
          'age_band': '18-24',
          'learning_goals': ['travel', 'work'],
          'daily_goal': 'intense',
          'reminder_time': '20:30',
          'reminder_days': ['Monday', 'Tuesday', 'Thursday', 'Saturday'],
          'accent_color': 'green',
          'first_sticker': 'first_hello',
          'onboarding_done': true,
        },
      };

      final dto = ProfileUpdateResponseDto.fromJson(sampleJson);

      expect(dto.message, equals('Profile updated successfully'));
      expect(dto.user.id, equals('671cc85341f237bf81d2a191'));
      expect(dto.user.displayName, equals('Farsana K'));
      expect(dto.user.currentLevel, equals('know_a_bit'));
      expect(dto.user.dailyGoal, equals('intense'));
      expect(dto.user.accentColor, equals('green'));

      final domain = dto.user.toDomain();
      expect(domain.userId, equals('671cc85341f237bf81d2a191'));
      expect(domain.firstName, equals('Farsana K'));
      expect(domain.selectedLevel, equals(LanguageLevel.knowABit));
      expect(domain.dailyGoalId, equals('intense'));
      expect(domain.reminderTime.to24HourString(), equals('20:30'));
      expect(domain.selectedWeekdayNumbers, equals({1, 2, 4, 6}));
      expect(domain.accentId, equals('green'));
    });
  });
}
