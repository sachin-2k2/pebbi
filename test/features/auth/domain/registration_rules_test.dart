import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/registration_rules.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';

void main() {
  group('RegistrationRules Domain Tests', () {
    test('canRegister returns true across all age bands and null', () {
      expect(RegistrationRules.canRegister(AgeBand.child), isTrue);
      expect(RegistrationRules.canRegister(AgeBand.teen), isTrue);
      expect(RegistrationRules.canRegister(AgeBand.adult), isTrue);
      expect(RegistrationRules.canRegister(null), isTrue);
    });

    test('registrationRequirements returns empty list for all age bands', () {
      expect(
        RegistrationRules.registrationRequirements(AgeBand.child),
        isEmpty,
      );
      expect(RegistrationRules.registrationRequirements(AgeBand.teen), isEmpty);
      expect(
        RegistrationRules.registrationRequirements(AgeBand.adult),
        isEmpty,
      );
      expect(RegistrationRules.registrationRequirements(null), isEmpty);
    });
  });
}
