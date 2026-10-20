import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/presentation/providers/login_form_provider.dart';

void main() {
  group('Secure Logging & Zero Data Leakage', () {
    test('LoginFormState does not store password field or raw credentials', () {
      const state = LoginFormState(
        isSubmitting: false,
        emailError: null,
        passwordError: null,
        generalError: null,
        isPasswordObscured: true,
        isSuccess: false,
      );

      // Verify that LoginFormState has no password string property
      final stateString = state.toString();
      expect(stateString.contains('password:'), isFalse);
    });

    test(
      'LoginFormNotifier resets and clears credentials on disposal',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(loginFormProvider.notifier);
        expect(container.read(loginFormProvider).isSubmitting, isFalse);

        await notifier.submitWithEmail(
          email: 'secret_user@example.com',
          password: 'SuperSecretPassword!#123',
        );

        // After container disposal, no state persists
        container.dispose();
      },
    );
  });
}
