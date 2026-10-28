import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/onboarding_config.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';

void main() {
  group('AgeBand Domain Tests (Pure Dart)', () {
    test(
      'contains exactly the 6 backend age bands with matching apiValues',
      () {
        expect(AgeBand.apiBands.length, equals(6));
        expect(AgeBand.band13_17.apiValue, equals('13-17'));
        expect(AgeBand.band18_24.apiValue, equals('18-24'));
        expect(AgeBand.band25_34.apiValue, equals('25-34'));
        expect(AgeBand.band35_44.apiValue, equals('35-44'));
        expect(AgeBand.band45_54.apiValue, equals('45-54'));
        expect(AgeBand.band55Plus.apiValue, equals('55+'));
      },
    );

    test('fromApiValue resolves string values correctly', () {
      expect(AgeBand.fromApiValue('13-17'), equals(AgeBand.band13_17));
      expect(AgeBand.fromApiValue('18-24'), equals(AgeBand.band18_24));
      expect(AgeBand.fromApiValue('25-34'), equals(AgeBand.band25_34));
      expect(AgeBand.fromApiValue('35-44'), equals(AgeBand.band35_44));
      expect(AgeBand.fromApiValue('45-54'), equals(AgeBand.band45_54));
      expect(AgeBand.fromApiValue('55+'), equals(AgeBand.band55Plus));
      expect(AgeBand.fromApiValue('invalid'), isNull);
      expect(AgeBand.fromApiValue(null), isNull);
    });

    test('isMinorBand is true ONLY for band13_17', () {
      expect(AgeBand.band13_17.isMinorBand, isTrue);
      expect(AgeBand.band18_24.isMinorBand, isFalse);
      expect(AgeBand.band25_34.isMinorBand, isFalse);
      expect(AgeBand.band35_44.isMinorBand, isFalse);
      expect(AgeBand.band45_54.isMinorBand, isFalse);
      expect(AgeBand.band55Plus.isMinorBand, isFalse);
    });

    test('privacyNote confirms storing age band only and never birthday', () {
      expect(
        AgeBand.band18_24.privacyNote,
        contains('store only the age band, never your birthday'),
      );
      expect(
        AgeBand.band13_17.privacyNote,
        contains('store only the age band, never your birthday'),
      );
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
        ageBand: AgeBand.band25_34,
      );

      expect(state.currentStep, equals(2));
      expect(state.totalSteps, equals(11));
      expect(state.ageBand, equals(AgeBand.band25_34));

      final updated = state.copyWith(ageBand: AgeBand.band13_17);
      expect(updated.ageBand, equals(AgeBand.band13_17));
      expect(updated.currentStep, equals(2));
    });
  });
}
