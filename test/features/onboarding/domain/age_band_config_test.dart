import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/age_band_config.dart';

void main() {
  group('AgeBandConfig - Youngest Possible Age & Evaluation', () {
    test('calculates youngest possible age as currentYear - birthYear - 1', () {
      final now2026 = DateTime(2026, 6, 1);
      expect(
        AgeBandConfig.calculateYoungestPossibleAge(2010, now: () => now2026),
        equals(15),
      );
      expect(
        AgeBandConfig.calculateYoungestPossibleAge(2013, now: () => now2026),
        equals(12),
      );
    });

    test('under-13 is blocked and returns null AgeBand', () {
      final now2026 = DateTime(2026, 6, 1);
      // Born in 2014 in year 2026: youngest = 2026 - 2014 - 1 = 11 -> blocked
      expect(AgeBandConfig.evaluateAgeBand(2014, now: () => now2026), isNull);
      // Born in 2013 in year 2026: youngest = 2026 - 2013 - 1 = 12 -> blocked
      expect(AgeBandConfig.evaluateAgeBand(2013, now: () => now2026), isNull);
    });

    test('boundary year 2012 in 2026 gives youngest age 13 -> band13_17', () {
      final now2026 = DateTime(2026, 1, 1);
      expect(
        AgeBandConfig.evaluateAgeBand(2012, now: () => now2026),
        equals(AgeBand.band13_17),
      );
    });

    test('boundary tests across reference years 2025, 2026, 2027', () {
      final now2025 = DateTime(2025, 10, 1);
      final now2026 = DateTime(2026, 10, 1);
      final now2027 = DateTime(2027, 10, 1);

      // In 2025: birth year 2011 -> youngest = 2025 - 2011 - 1 = 13 (band13_17)
      expect(
        AgeBandConfig.evaluateAgeBand(2011, now: () => now2025),
        equals(AgeBand.band13_17),
      );
      // In 2025: birth year 2012 -> youngest = 2025 - 2012 - 1 = 12 (blocked)
      expect(AgeBandConfig.evaluateAgeBand(2012, now: () => now2025), isNull);

      // In 2026: birth year 2008 -> youngest = 2026 - 2008 - 1 = 17 (band13_17)
      // Born 2008 could turn 18 in 2026, but boundary year assigns to younger band
      expect(
        AgeBandConfig.evaluateAgeBand(2008, now: () => now2026),
        equals(AgeBand.band13_17),
      );

      // In 2026: birth year 2007 -> youngest = 2026 - 2007 - 1 = 18 (band18_24)
      expect(
        AgeBandConfig.evaluateAgeBand(2007, now: () => now2026),
        equals(AgeBand.band18_24),
      );

      // In 2027: birth year 2013 -> youngest = 2027 - 2013 - 1 = 13 (band13_17)
      expect(
        AgeBandConfig.evaluateAgeBand(2013, now: () => now2027),
        equals(AgeBand.band13_17),
      );
    });

    test('assigns all 6 bands correctly', () {
      final now2026 = DateTime(2026, 1, 1);
      expect(
        AgeBandConfig.evaluateAgeBand(2010, now: () => now2026),
        AgeBand.band13_17,
      );
      expect(
        AgeBandConfig.evaluateAgeBand(2005, now: () => now2026),
        AgeBand.band18_24,
      );
      expect(
        AgeBandConfig.evaluateAgeBand(1995, now: () => now2026),
        AgeBand.band25_34,
      );
      expect(
        AgeBandConfig.evaluateAgeBand(1985, now: () => now2026),
        AgeBand.band35_44,
      );
      expect(
        AgeBandConfig.evaluateAgeBand(1975, now: () => now2026),
        AgeBand.band45_54,
      );
      expect(
        AgeBandConfig.evaluateAgeBand(1965, now: () => now2026),
        AgeBand.band55Plus,
      );
    });
  });

  group('AgeGateRetryPolicy', () {
    test('default policy is allow', () {
      expect(
        AgeBandConfig.ageGateRetryPolicy,
        equals(AgeGateRetryPolicy.allow),
      );
    });

    test(
      'retry policies contain expected values and behaviour documentation',
      () {
        expect(AgeGateRetryPolicy.values, contains(AgeGateRetryPolicy.allow));
        expect(
          AgeGateRetryPolicy.values,
          contains(AgeGateRetryPolicy.lockForSession),
        );
        expect(
          AgeGateRetryPolicy.values,
          contains(AgeGateRetryPolicy.lockOnDevice),
        );
      },
    );
  });
}
