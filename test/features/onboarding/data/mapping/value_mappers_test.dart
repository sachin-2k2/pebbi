import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/data/mapping/accent_mapper.dart';
import 'package:peddi/features/onboarding/data/mapping/daily_goal_mapper.dart';
import 'package:peddi/features/onboarding/data/mapping/goals_mapper.dart';
import 'package:peddi/features/onboarding/data/mapping/level_mapper.dart';
import 'package:peddi/features/onboarding/data/mapping/reminder_time_mapper.dart';
import 'package:peddi/features/onboarding/data/mapping/sticker_mapper.dart';
import 'package:peddi/features/onboarding/data/mapping/weekday_mapper.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('Value Mappers', () {
    test('LevelMapper maps domain levels to backend strings', () {
      expect(LevelMapper.toApi(LanguageLevel.little), equals('starter'));
      expect(LevelMapper.toApi(LanguageLevel.knowABit), equals('know_a_bit'));
      expect(LevelMapper.toApi(LanguageLevel.expert), equals('expert'));

      expect(LevelMapper.fromApi('starter'), equals(LanguageLevel.little));
      expect(LevelMapper.fromApi('know_a_bit'), equals(LanguageLevel.knowABit));
      expect(LevelMapper.fromApi('expert'), equals(LanguageLevel.expert));
    });

    test('AccentMapper preserves string IDs and rejects hex', () {
      expect(AccentMapper.toApi('violet'), equals('violet'));
      expect(AccentMapper.toApi('green'), equals('green'));
      expect(AccentMapper.toApi('orange'), equals('orange'));
      expect(AccentMapper.toApi('blue'), equals('blue'));
      expect(AccentMapper.toApi('pink'), equals('pink'));
      expect(AccentMapper.toApi('slate'), equals('slate'));

      // If invalid/hex passed, falls back to default 'violet'
      expect(AccentMapper.toApi('#6C4DF6'), equals('violet'));
    });

    test('StickerMapper maps local sticker IDs to backend names', () {
      expect(StickerMapper.toApi('wave'), equals('first_hello'));
      expect(StickerMapper.toApi('sparkle'), equals('little_spark'));
      expect(StickerMapper.toApi('wellsaid'), equals('well_said'));
      expect(StickerMapper.toApi(null), isNull);
    });

    test('WeekdayMapper produces full English weekday names Monday-first', () {
      final days = WeekdayMapper.toApi({1, 2, 3, 4, 5, 6, 7});
      expect(
        days,
        equals([
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ]),
      );

      // Subset preserves Monday-first ordering
      expect(
        WeekdayMapper.toApi({7, 3, 1}),
        equals(['Monday', 'Wednesday', 'Sunday']),
      );
    });

    test('DailyGoalMapper and GoalsMapper map appropriately', () {
      expect(DailyGoalMapper.toApi('regular'), equals('regular'));
      expect(DailyGoalMapper.toApi('casual'), equals('casual'));
      expect(DailyGoalMapper.toApi('unknown'), equals('regular'));

      expect(
        GoalsMapper.toApi({'travel', 'work'}),
        containsAll(['travel', 'work']),
      );
    });

    test('ReminderTimeMapper formats 24h string HH:mm', () {
      expect(
        ReminderTimeMapper.toApi(const ReminderTime(hour: 8, minute: 5)),
        equals('08:05'),
      );
      expect(
        ReminderTimeMapper.toApi(const ReminderTime(hour: 19, minute: 30)),
        equals('19:30'),
      );
    });
  });
}
