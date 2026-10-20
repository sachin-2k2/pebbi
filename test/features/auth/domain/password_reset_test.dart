import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/data/mock_auth_repository.dart';
import 'package:peddi/features/auth/domain/auth_result.dart';
import 'package:peddi/features/auth/domain/clock.dart';
import 'package:peddi/features/auth/domain/email_validator.dart';
import 'package:peddi/features/auth/domain/password_reset_cooldown.dart';

class FakeClock implements AppClock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}

void main() {
  group('PasswordResetDomain', () {
    test('EmailValidator rejects empty and invalid formats for reset', () {
      expect(EmailValidator.validate(''), isNotNull);
      expect(EmailValidator.validate('not-an-email'), isNotNull);
      expect(EmailValidator.validate('user@domain'), isNotNull);
      expect(EmailValidator.validate('valid@example.com'), isNull);
    });

    test(
      'MockAuthRepository returns identical success for any email (account enumeration defense)',
      () async {
        final repo = MockAuthRepository();

        final res1 = await repo.requestPasswordReset(
          email: 'registered@example.com',
        );
        final res2 = await repo.requestPasswordReset(
          email: 'unregistered@example.com',
        );

        expect(res1, isA<PasswordResetSuccess>());
        expect(res2, isA<PasswordResetSuccess>());
        expect(repo.passwordResetAttempts, 2);
      },
    );

    test('MockAuthRepository respects forced failure reasons', () async {
      final repo = MockAuthRepository(
        forceFailureReason: AuthFailureReason.network,
      );

      final res = await repo.requestPasswordReset(email: 'user@example.com');

      expect(res, isA<AuthFailure>());
      expect((res as AuthFailure).reason, AuthFailureReason.network);
    });

    test(
      'MockAuthRepository tracks attempts for double-submit prevention',
      () async {
        final repo = MockAuthRepository();

        await repo.requestPasswordReset(email: 'test@example.com');
        await repo.requestPasswordReset(email: 'test@example.com');

        expect(repo.passwordResetAttempts, 2);
      },
    );
  });

  group('PasswordResetCooldown', () {
    test('starts with no cooldown when endsAt is null', () {
      final clock = FakeClock(DateTime(2026, 10, 20, 12, 0, 0));
      final cooldown = PasswordResetCooldown(clock: clock);

      expect(cooldown.isInCooldown, isFalse);
      expect(cooldown.canResend, isTrue);
      expect(cooldown.remainingSeconds, 0);
    });

    test('initializes 60s cooldown and counts down with clock progression', () {
      final clock = FakeClock(DateTime(2026, 10, 20, 12, 0, 0));
      var cooldown = PasswordResetCooldown(clock: clock).startNewCooldown();

      expect(cooldown.isInCooldown, isTrue);
      expect(cooldown.canResend, isFalse);
      expect(cooldown.remainingSeconds, 60);

      clock.advance(const Duration(seconds: 15));
      expect(cooldown.remainingSeconds, 45);
      expect(cooldown.isInCooldown, isTrue);
      expect(cooldown.canResend, isFalse);

      clock.advance(const Duration(seconds: 45));
      expect(cooldown.remainingSeconds, 0);
      expect(cooldown.isInCooldown, isFalse);
      expect(cooldown.canResend, isTrue);
    });

    test('clear() cancels active cooldown immediately', () {
      final clock = FakeClock(DateTime(2026, 10, 20, 12, 0, 0));
      final cooldown = PasswordResetCooldown(clock: clock).startNewCooldown();

      expect(cooldown.isInCooldown, isTrue);
      final cleared = cooldown.clear();

      expect(cleared.isInCooldown, isFalse);
      expect(cleared.canResend, isTrue);
      expect(cleared.remainingSeconds, 0);
    });
  });
}
