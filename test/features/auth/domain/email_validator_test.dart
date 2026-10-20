import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('returns EmailValidationError.empty when null or whitespace only', () {
      expect(EmailValidator.validate(null), EmailValidationError.empty);
      expect(EmailValidator.validate(''), EmailValidationError.empty);
      expect(EmailValidator.validate('   '), EmailValidationError.empty);
      expect(EmailValidator.validate('\t\n'), EmailValidationError.empty);
    });

    test('returns EmailValidationError.invalidFormat for malformed emails', () {
      expect(
        EmailValidator.validate('plainaddress'),
        EmailValidationError.invalidFormat,
      );
      expect(
        EmailValidator.validate('@missingusername.com'),
        EmailValidationError.invalidFormat,
      );
      expect(
        EmailValidator.validate('username@.com'),
        EmailValidationError.invalidFormat,
      );
      expect(
        EmailValidator.validate('username@domain'),
        EmailValidationError.invalidFormat,
      );
      expect(
        EmailValidator.validate('username@domain.'),
        EmailValidationError.invalidFormat,
      );
      expect(
        EmailValidator.validate('username@domain..com'),
        EmailValidationError.invalidFormat,
      );
      expect(
        EmailValidator.validate('user space@domain.com'),
        EmailValidationError.invalidFormat,
      );
    });

    test('returns null for valid email formats and trims outer whitespace', () {
      expect(EmailValidator.validate('you@example.com'), isNull);
      expect(EmailValidator.validate('  you@example.com  '), isNull);
      expect(EmailValidator.validate('user.name+tag@sub.domain.org'), isNull);
      expect(EmailValidator.validate('first.last@company.co.uk'), isNull);
      expect(EmailValidator.validate('student_123@university.edu'), isNull);
    });
  });
}
