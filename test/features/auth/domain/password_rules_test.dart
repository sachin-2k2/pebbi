import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/password_rules.dart';

void main() {
  group('PasswordRules', () {
    test('validateForLogin returns empty error for null or empty password', () {
      expect(
        PasswordRules.validateForLogin(null),
        PasswordValidationError.empty,
      );
      expect(PasswordRules.validateForLogin(''), PasswordValidationError.empty);
    });

    test(
      'validateForLogin returns null for non-empty string without enforcing complexity',
      () {
        expect(PasswordRules.validateForLogin('1'), isNull);
        expect(PasswordRules.validateForLogin('abc'), isNull);
        expect(PasswordRules.validateForLogin('password123'), isNull);
        expect(PasswordRules.validateForLogin('P@\$\$w0rd!#%^&*()'), isNull);
      },
    );

    test('validateForRegistration enforces boundary of 8 to 72 characters', () {
      expect(
        PasswordRules.validateForRegistration(null),
        PasswordValidationError.empty,
      );
      expect(
        PasswordRules.validateForRegistration(''),
        PasswordValidationError.empty,
      );
      // 7 chars -> tooShort
      expect(
        PasswordRules.validateForRegistration('1234567'),
        PasswordValidationError.tooShort,
      );
      // 8 chars -> valid
      expect(PasswordRules.validateForRegistration('12345678'), isNull);
      // 72 chars -> valid
      final seventyTwo = 'a' * 72;
      expect(PasswordRules.validateForRegistration(seventyTwo), isNull);
      // 73 chars -> tooLong
      final seventyThree = 'a' * 73;
      expect(
        PasswordRules.validateForRegistration(seventyThree),
        PasswordValidationError.tooLong,
      );
    });

    test(
      'validateConfirmPassword enforces presence and equality with primary',
      () {
        expect(
          PasswordRules.validateConfirmPassword(
            password: 'password123',
            confirmPassword: null,
          ),
          PasswordValidationError.empty,
        );
        expect(
          PasswordRules.validateConfirmPassword(
            password: 'password123',
            confirmPassword: '',
          ),
          PasswordValidationError.empty,
        );
        expect(
          PasswordRules.validateConfirmPassword(
            password: 'password123',
            confirmPassword: 'differentpassword',
          ),
          PasswordValidationError.mismatch,
        );
        expect(
          PasswordRules.validateConfirmPassword(
            password: 'password123',
            confirmPassword: 'password123',
          ),
          isNull,
        );
      },
    );
  });
}
