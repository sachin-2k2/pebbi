import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/domain/reminder_selection_rules.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/onboarding/domain/weekday.dart';

void main() {
  group('ReminderTime Domain Tests', () {
    test('defaultTime is 19:00 (7:00 PM)', () {
      const time = ReminderTime.defaultTime;
      expect(time.hour, 19);
      expect(time.minute, 0);
      expect(time.to24HourString(), '19:00');
    });

    test('to24HourString formats with leading zeroes', () {
      const time = ReminderTime(hour: 8, minute: 5);
      expect(time.to24HourString(), '08:05');
    });

    test(
      'parse correctly converts string and handles malformed strings safely',
      () {
        expect(
          ReminderTime.parse('14:30'),
          const ReminderTime(hour: 14, minute: 30),
        );
        expect(
          ReminderTime.parse('00:00'),
          const ReminderTime(hour: 0, minute: 0),
        );
        expect(ReminderTime.parse('invalid'), ReminderTime.defaultTime);
      },
    );

    test('formatDisplay handles 12h AM/PM and 24h formats', () {
      const evening = ReminderTime(hour: 19, minute: 0);
      expect(evening.formatDisplay(alwaysUse24Hour: false), '07:00 PM');
      expect(evening.formatDisplay(alwaysUse24Hour: true), '19:00');

      const morning = ReminderTime(hour: 9, minute: 15);
      expect(morning.formatDisplay(alwaysUse24Hour: false), '09:15 AM');
      expect(morning.formatDisplay(alwaysUse24Hour: true), '09:15');

      const midnight = ReminderTime(hour: 0, minute: 0);
      expect(midnight.formatDisplay(alwaysUse24Hour: false), '12:00 AM');

      const noon = ReminderTime(hour: 12, minute: 30);
      expect(noon.formatDisplay(alwaysUse24Hour: false), '12:30 PM');
    });

    test('equality and hashCode work properly', () {
      const t1 = ReminderTime(hour: 19, minute: 0);
      const t2 = ReminderTime(hour: 19, minute: 0);
      const t3 = ReminderTime(hour: 20, minute: 0);
      expect(t1, t2);
      expect(t1.hashCode, t2.hashCode);
      expect(t1, isNot(t3));
    });
  });

  group('Weekday Domain Tests', () {
    test(
      'allDays has 7 days in Monday to Sunday order with correct letters',
      () {
        expect(Weekday.allDays.length, 7);
        expect(Weekday.allDays.map((d) => d.shortLetter).toList(), [
          'M',
          'T',
          'W',
          'T',
          'F',
          'S',
          'S',
        ]);
        expect(Weekday.allDays.map((d) => d.isoNumber).toList(), [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
        ]);
      },
    );

    test('forNumber resolves correctly and defaults to monday on fallback', () {
      expect(Weekday.forNumber(1), Weekday.monday);
      expect(Weekday.forNumber(5), Weekday.friday);
      expect(Weekday.forNumber(7), Weekday.sunday);
      expect(Weekday.forNumber(99), Weekday.monday);
    });
  });

  group('ReminderSelectionRules Tests', () {
    test('defaultWeekdayNumbers contains all 7 days', () {
      expect(ReminderSelectionRules.defaultWeekdayNumbers, {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
      });
    });

    test('toggleWeekday adds and removes days without mutating input', () {
      const initial = {1, 2, 3};
      final afterRemove = ReminderSelectionRules.toggleWeekday(initial, 2);
      expect(afterRemove, {1, 3});
      expect(initial, {1, 2, 3}); // unmutated

      final afterAdd = ReminderSelectionRules.toggleWeekday(afterRemove, 4);
      expect(afterAdd, {1, 3, 4});
    });

    test(
      'areRemindersEnabled returns true when days are selected and false when empty',
      () {
        expect(ReminderSelectionRules.areRemindersEnabled({1}), isTrue);
        expect(ReminderSelectionRules.areRemindersEnabled({}), isFalse);
      },
    );
  });

  group('OnboardingState Reminder Persistence', () {
    test('default reminder values in OnboardingState', () {
      const state = OnboardingState();
      expect(state.reminderTime, ReminderTime.defaultTime);
      expect(state.selectedWeekdayNumbers, {1, 2, 3, 4, 5, 6, 7});
      expect(state.remindersEnabled, isTrue);
      expect(state.notificationPermissionGranted, isNull);
    });

    test('copyWith updates reminder preferences and permission', () {
      const state = OnboardingState();
      final updated = state.copyWith(
        reminderTime: const ReminderTime(hour: 8, minute: 30),
        selectedWeekdayNumbers: {1, 3, 5},
        remindersEnabled: true,
        notificationPermissionGranted: true,
      );
      expect(updated.reminderTime, const ReminderTime(hour: 8, minute: 30));
      expect(updated.selectedWeekdayNumbers, {1, 3, 5});
      expect(updated.remindersEnabled, isTrue);
      expect(updated.notificationPermissionGranted, isTrue);
    });
  });
}
