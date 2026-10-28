import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/auth_result.dart';
import '../../domain/auth_session.dart';
import '../../domain/email_validator.dart';
import '../../domain/password_rules.dart';
import 'auth_session_provider.dart';
import 'user_session_manager.dart';

/// Form state for the login screen.
///
/// Follows AGENTS.md §2.3 & §6: Auto-disposing, zero password storage in long-lived state.
class LoginFormState {
  const LoginFormState({
    this.isSubmitting = false,
    this.emailError,
    this.passwordError,
    this.generalError,
    this.isPasswordObscured = true,
    this.isSuccess = false,
    this.session,
  });

  final bool isSubmitting;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final bool isPasswordObscured;
  final bool isSuccess;
  final AuthSession? session;

  LoginFormState copyWith({
    bool? isSubmitting,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? generalError,
    bool clearGeneralError = false,
    bool? isPasswordObscured,
    bool? isSuccess,
    AuthSession? session,
  }) {
    return LoginFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isSuccess: isSuccess ?? this.isSuccess,
      session: session ?? this.session,
    );
  }
}

/// State notifier managing login form interactions, validation, and session switching.
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier(this.ref) : super(const LoginFormState());

  final Ref ref;

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordObscured: !state.isPasswordObscured);
  }

  void clearErrors() {
    state = state.copyWith(
      clearEmailError: true,
      clearPasswordError: true,
      clearGeneralError: true,
    );
  }

  Future<bool> submitWithEmail({
    required String email,
    required String password,
  }) async {
    // Double-tap rejection
    if (state.isSubmitting) return false;

    clearErrors();

    // Field-level validation
    final emailFormatError = EmailValidator.validate(email);
    final passwordRuleError = PasswordRules.validateForLogin(password);

    String? emailMessage;
    if (emailFormatError != null) {
      emailMessage = emailFormatError == EmailValidationError.empty
          ? AppStrings.authErrorEmailEmpty
          : AppStrings.authErrorEmailInvalid;
    }

    String? passwordMessage;
    if (passwordRuleError != null) {
      passwordMessage = AppStrings.authErrorPasswordEmpty;
    }

    if (emailMessage != null || passwordMessage != null) {
      state = state.copyWith(
        emailError: emailMessage,
        passwordError: passwordMessage,
      );
      return false;
    }

    debugPrint('[LoginFormProvider] submitWithEmail called (email: "${email.trim()}")');
    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.signInWithEmail(
        email: email.trim(),
        password: password,
      );

      if (!mounted) return false;
      return await _handleAuthResult(result);
    } catch (e, stack) {
      if (!mounted) return false;
      debugPrint('[LoginFormProvider] 💥 Unexpected exception during login: $e\n$stack');
      state = state.copyWith(
        isSubmitting: false,
        generalError: AppStrings.authErrorUnknown,
      );
      return false;
    }
  }

  Future<bool> submitWithGoogle() async {
    // Double-tap rejection
    if (state.isSubmitting) return false;

    clearErrors();
    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.signInWithGoogle();

      if (!mounted) return false;
      return await _handleAuthResult(result);
    } catch (e, stack) {
      if (!mounted) return false;
      debugPrint('[LoginFormProvider] 💥 Unexpected exception during Google sign-in: $e\n$stack');
      state = state.copyWith(
        isSubmitting: false,
        generalError: AppStrings.authErrorUnknown,
      );
      return false;
    }
  }

  Future<bool> _handleAuthResult(AuthResult result) async {
    switch (result) {
      case AuthSuccess(:final session, :final profile):
        debugPrint(
          '[LoginFormProvider] ✅ Login successful: userId=${session.userId}, email=${session.email}',
        );
        await UserSessionManager.applyUserSwitch(ref, session, profile);
        if (!mounted) return false;
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          session: session,
        );
        return true;

      case PasswordResetSuccess():
        if (!mounted) return false;
        state = state.copyWith(isSubmitting: false);
        return false;

      case RegisterOtpSent():
        if (!mounted) return false;
        state = state.copyWith(isSubmitting: false);
        return false;

      case AuthFailure(:final reason, :final message):
        debugPrint(
          '[LoginFormProvider] ❌ Login failed: reason=$reason, message=$message',
        );
        if (!mounted) return false;
        if (reason == AuthFailureReason.cancelled) {
          // User cancelled third-party OAuth: silently return to idle
          state = state.copyWith(isSubmitting: false);
          return false;
        }

        final errorMsg = (message != null && message.trim().isNotEmpty)
            ? message
            : switch (reason) {
                AuthFailureReason.invalidCredentials =>
                  AppStrings.authErrorInvalidCredentials,
                AuthFailureReason.network => AppStrings.authErrorNetwork,
                AuthFailureReason.tooManyAttempts =>
                  AppStrings.authErrorTooManyAttempts,
                AuthFailureReason.accountDisabled =>
                  AppStrings.authErrorAccountDisabled,
                _ => AppStrings.authErrorUnknown,
              };

        state = state.copyWith(isSubmitting: false, generalError: errorMsg);
        return false;
    }
  }

  // Handled via UserSessionManager
}

/// Global provider for the login form notifier.
final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(ref);
    });
