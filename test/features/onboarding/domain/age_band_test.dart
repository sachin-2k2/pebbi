import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/onboarding_config.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';

void main() {
  group('AgeBand Domain Tests (Pure Dart)', () {
    test('correctly maps birth year to AgeBand across boundaries', () {
      const fixedNow = 2026;

      // Adult (18+)
      expect(
        AgeBand.fromBirthYear(2002, currentYear: fixedNow),
        equals(AgeBand.adult),
      );
      expect(
        AgeBand.fromBirthYear(2008, currentYear: fixedNow), // exactly 18
        equals(AgeBand.adult),
      );
      expect(
        AgeBand.fromBirthYear(1950, currentYear: fixedNow),
        equals(AgeBand.adult),
      );

      // Teen (13–17)
      expect(
        AgeBand.fromBirthYear(2009, currentYear: fixedNow), // 17
        equals(AgeBand.teen),
      );
      expect(
        AgeBand.fromBirthYear(2013, currentYear: fixedNow), // 13
        equals(AgeBand.teen),
      );

      // Child (< 13)
      expect(
        AgeBand.fromBirthYear(2014, currentYear: fixedNow), // 12
        equals(AgeBand.child),
      );
      expect(
        AgeBand.fromBirthYear(2020, currentYear: fixedNow), // 6
        equals(AgeBand.child),
      );
      expect(
        AgeBand.fromBirthYear(fixedNow, currentYear: fixedNow), // 0
        equals(AgeBand.child),
      );
    });

    test('privacyNote is data-driven and provides adult privacy copy', () {
      expect(
        AgeBand.adult.privacyNote,
        contains('store only the age band, never your birthday'),
      );
      expect(
        AgeBand.teen.privacyNote,
        contains('store only the age band, never your birthday'),
      );
      expect(
        AgeBand.child.privacyNote,
        contains(
          'Pebbi is for ages 13 and up. Ask a grown-up to set this up with you',
        ),
      );
      expect(AgeBand.child.hasShieldIcon, isTrue);
      expect(AgeBand.adult.hasShieldIcon, isFalse);
    });
  });

  group('OnboardingConfig Tests', () {
    test('totalSteps is 11 and defaultBirthYear is 2002', () {
      expect(OnboardingConfig.totalSteps, equals(11));
      expect(OnboardingConfig.defaultBirthYear, equals(2002));
    });

    test('generateSelectableYears creates years spanning ~100 years', () {
      final years = OnboardingConfig.generateSelectableYears(currentYear: 2026);
      expect(years.first, equals(2022)); // 2026 - 4
      expect(years.last, equals(1926)); // 2026 - 100
      expect(years.contains(2002), isTrue);
      expect(years.length, equals(97));
    });
  });

  group('OnboardingState Strict Privacy Tests', () {
    test('stores only ageBand and strictly no raw birth year', () {
      const state = OnboardingState(
        currentStep: 2,
        totalSteps: 11,
        ageBand: AgeBand.adult,
      );

      expect(state.currentStep, equals(2));
      expect(state.totalSteps, equals(11));
      expect(state.ageBand, equals(AgeBand.adult));

      final updated = state.copyWith(ageBand: AgeBand.teen);
      expect(updated.ageBand, equals(AgeBand.teen));
      expect(updated.currentStep, equals(2));
    });
  });
}
