import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/data/registration_payload_builder.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/domain/placement_result.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('RegistrationPayloadBuilder', () {
    test(
      'builds payload matching custom ASSUMED API-UPDATES example when quiz taken',
      () {
        // NOTE: API-UPDATES.md contains NO JSON example for registration.
        // The following expected map is derived from the confirmed allowed values in API-UPDATES.md (§1 row 17 and §5),
        // with native_language "ml" and learning_language "en".
        // Every field is marked ASSUMED below:
        final expectedPayloadAssumed = <String, dynamic>{
          'native_language': 'ml', // ASSUMED: Malayalam
          'learning_language': 'en', // ASSUMED: English (only available course)
          'age_band': '18-24', // ASSUMED: Six API age band format
          'learning_goals': [
            'travel',
            'work',
          ], // ASSUMED: reasons mapped to confirmed goal IDs
          'daily_goal': 'regular', // ASSUMED: daily target string
          'reminder_time': '19:00', // ASSUMED: HH:mm 24-hour string
          'reminder_days': [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ], // ASSUMED: Full English weekday names Monday-first
          'accent_color':
              'violet', // ASSUMED: string ID from confirmed accent list
          'first_sticker':
              'first_hello', // ASSUMED: sticker ID mapped from 'wave'
          'current_level':
              'know_a_bit', // ASSUMED: chosen level mapped from knowABit
          'suggested_level': 'know_a_bit', // ASSUMED: suggested level
          'placement_skipped': false, // ASSUMED: boolean flag
          'placement_score': 6, // ASSUMED: correct score
          'placement_total': 8, // ASSUMED: total questions
        };

        const state = OnboardingState(
          explanationLanguageCode: 'ml',
          targetLanguageCode: 'en',
          ageBand: AgeBand.band18_24,
          selectedReasonIds: {'travel', 'work'},
          chosenLevel: LanguageLevel.knowABit,
          suggestedLevel: LanguageLevel.knowABit,
          isPlacementSkipped: false,
          placementResult: PlacementResult(
            suggestedLevel: LanguageLevel.knowABit,
            chosenLevel: LanguageLevel.knowABit,
            firstTryCorrect: 6,
            totalQuestions: 8,
          ),
          selectedGoalId: 'regular',
          reminderTime: ReminderTime(hour: 19, minute: 0),
          selectedWeekdayNumbers: {1, 2, 3, 4, 5, 6, 7},
          accentId: 'violet',
          firstStickerId: 'wave',
          selectedPlan: 'free',
        );

        final payload = RegistrationPayloadBuilder.build(state);

        expect(payload, equals(expectedPayloadAssumed));
        expect(payload.containsKey('birth_year'), isFalse);
        expect(payload.containsKey('year_of_birth'), isFalse);
      },
    );

    test(
      'omits placement_score and placement_total when placement is skipped',
      () {
        final expectedSkippedPayloadAssumed = <String, dynamic>{
          'native_language': 'ml', // ASSUMED
          'learning_language': 'en', // ASSUMED
          'age_band': '25-34', // ASSUMED
          'learning_goals': ['culture'], // ASSUMED
          'daily_goal': 'casual', // ASSUMED
          'reminder_time': '08:30', // ASSUMED
          'reminder_days': ['Monday', 'Wednesday'], // ASSUMED
          'accent_color': 'green', // ASSUMED
          'current_level': 'starter', // ASSUMED: starter for Little
          'suggested_level': 'starter', // ASSUMED
          'placement_skipped': true, // ASSUMED
          // placement_score and placement_total OMITTED
          // first_sticker OMITTED when null
        };

        const state = OnboardingState(
          explanationLanguageCode: 'ml',
          targetLanguageCode: 'en',
          ageBand: AgeBand.band25_34,
          selectedReasonIds: {'culture'},
          chosenLevel: LanguageLevel.little,
          suggestedLevel: LanguageLevel.little,
          isPlacementSkipped: true,
          selectedGoalId: 'casual',
          reminderTime: ReminderTime(hour: 8, minute: 30),
          selectedWeekdayNumbers: {1, 3},
          accentId: 'green',
          firstStickerId: null,
          selectedPlan: 'free',
        );

        final payload = RegistrationPayloadBuilder.build(state);

        expect(payload, equals(expectedSkippedPayloadAssumed));
        expect(payload.containsKey('placement_score'), isFalse);
        expect(payload.containsKey('placement_total'), isFalse);
        expect(payload.containsKey('birth_year'), isFalse);
      },
    );
  });
}
