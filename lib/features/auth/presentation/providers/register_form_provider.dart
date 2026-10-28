import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/auth_result.dart';
import '../../domain/auth_session.dart';
import '../../domain/email_validator.dart';
import '../../domain/password_rules.dart';
import '../../../onboarding/data/registration_payload_builder.dart';
import '../../../onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'auth_session_provider.dart';
import 'user_session_manager.dart';

/// Form state for the registration screen.
///
/// Follows AGENTS.md §2.3 & §6: Auto-disposing, zero password retention in long-lived state.
class RegisterFormState {
  const RegisterFormState({
    this.isSubmitting = false,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.generalError,
    this.isPasswordObscured = true,
    this.isConfirmPasswordObscured = true,
    this.isSuccess = false,
    this.isOtpSent = false,
    this.otpEmail,
    this.otpMessage,
    this.session,
  });

  final bool isSubmitting;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;
  final bool isPasswordObscured;
  final bool isConfirmPasswordObscured;
  final bool isSuccess;
  final bool isOtpSent;
  final String? otpEmail;
  final String? otpMessage;
  final AuthSession? session;

  RegisterFormState copyWith({
    bool? isSubmitting,
    String? nameError,
    bool clearNameError = false,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
    String? generalError,
    bool clearGeneralError = false,
    bool? isPasswordObscured,
    bool? isConfirmPasswordObscured,
    bool? isSuccess,
    bool? isOtpSent,
    String? otpEmail,
    String? otpMessage,
    AuthSession? session,
  }) {
    return RegisterFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmPasswordObscured:
          isConfirmPasswordObscured ?? this.isConfirmPasswordObscured,
      isSuccess: isSuccess ?? this.isSuccess,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otpEmail: otpEmail ?? this.otpEmail,
      otpMessage: otpMessage ?? this.otpMessage,
      session: session ?? this.session,
    );
  }
}

/// State notifier managing registration form interactions, validation, and session migration.
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier(this.ref) : super(const RegisterFormState());

  final Ref ref;

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordObscured: !state.isPasswordObscured);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
    );
  }

  void clearErrors() {
    state = state.copyWith(
      clearNameError: true,
      clearEmailError: true,
      clearPasswordError: true,
      clearConfirmPasswordError: true,
      clearGeneralError: true,
    );
  }

  void validateName(String name) {
    if (name.trim().isEmpty) {
      state = state.copyWith(nameError: AppStrings.authErrorNameEmpty);
    } else {
      state = state.copyWith(clearNameError: true);
    }
  }

  void validateEmail(String email) {
    final error = EmailValidator.validate(email);
    if (error != null) {
      state = state.copyWith(
        emailError: error == EmailValidationError.empty
            ? AppStrings.authErrorEmailEmpty
            : AppStrings.authErrorEmailInvalid,
      );
    } else {
      state = state.copyWith(clearEmailError: true);
    }
  }

  void validatePassword(String password) {
    final error = PasswordRules.validateForRegistration(password);
    if (error != null) {
      final msg = switch (error) {
        PasswordValidationError.empty => AppStrings.authErrorPasswordEmpty,
        PasswordValidationError.tooShort =>
          AppStrings.authErrorPasswordTooShort,
        PasswordValidationError.tooLong => AppStrings.authErrorPasswordTooLong,
        PasswordValidationError.mismatch =>
          AppStrings.authErrorPasswordMismatch,
      };
      state = state.copyWith(passwordError: msg);
    } else {
      state = state.copyWith(clearPasswordError: true);
    }
  }

  void validateConfirmPassword(String password, String confirmPassword) {
    final error = PasswordRules.validateConfirmPassword(
      password: password,
      confirmPassword: confirmPassword,
    );
    if (error != null) {
      final msg = switch (error) {
        PasswordValidationError.empty => AppStrings.authErrorPasswordEmpty,
        PasswordValidationError.mismatch =>
          AppStrings.authErrorPasswordMismatch,
        _ => AppStrings.authErrorPasswordMismatch,
      };
      state = state.copyWith(confirmPasswordError: msg);
    } else {
      state = state.copyWith(clearConfirmPasswordError: true);
    }
  }

  Future<bool> submitWithEmail({
    String? name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    debugPrint('[RegisterFormProvider] submitWithEmail called (name: "$name", email: "$email")');
    // Double-tap rejection
    if (state.isSubmitting) {
      debugPrint('[RegisterFormProvider] Ignored: already submitting.');
      return false;
    }

    clearErrors();

    // Field-level validation across all fields
    String? nameMessage;
    if (name != null && name.trim().isEmpty) {
      nameMessage = AppStrings.authErrorNameEmpty;
    }

    final emailFormatError = EmailValidator.validate(email);
    final passwordRuleError = PasswordRules.validateForRegistration(password);
    final confirmRuleError = PasswordRules.validateConfirmPassword(
      password: password,
      confirmPassword: confirmPassword,
    );

    String? emailMessage;
    if (emailFormatError != null) {
      emailMessage = emailFormatError == EmailValidationError.empty
          ? AppStrings.authErrorEmailEmpty
          : AppStrings.authErrorEmailInvalid;
    }

    String? passwordMessage;
    if (passwordRuleError != null) {
      passwordMessage = switch (passwordRuleError) {
        PasswordValidationError.empty => AppStrings.authErrorPasswordEmpty,
        PasswordValidationError.tooShort =>
          AppStrings.authErrorPasswordTooShort,
        PasswordValidationError.tooLong => AppStrings.authErrorPasswordTooLong,
        _ => AppStrings.authErrorPasswordEmpty,
      };
    }

    String? confirmMessage;
    if (confirmRuleError != null) {
      confirmMessage = confirmRuleError == PasswordValidationError.empty
          ? AppStrings.authErrorPasswordEmpty
          : AppStrings.authErrorPasswordMismatch;
    }

    if (nameMessage != null ||
        emailMessage != null ||
        passwordMessage != null ||
        confirmMessage != null) {
      debugPrint('[RegisterFormProvider] ⚠️ Validation failed: name=$nameMessage, email=$emailMessage, password=$passwordMessage, confirm=$confirmMessage');
      state = state.copyWith(
        nameError: nameMessage,
        emailError: emailMessage,
        passwordError: passwordMessage,
        confirmPasswordError: confirmMessage,
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final onboardingState = ref.read(onboardingFlowProvider);
      final onboardingData = RegistrationPayloadBuilder.build(onboardingState);
      debugPrint('[RegisterFormProvider] 📦 Built onboarding data: $onboardingData');

      final result = await repo.registerWithEmail(
        email: email.trim(),
        password: password,
        displayName: name?.trim(),
        onboardingData: onboardingData,
      );
      debugPrint('[RegisterFormProvider] 📥 Received result: $result');

      return await _handleAuthResult(result);
    } catch (e, stack) {
      debugPrint('[RegisterFormProvider] 💥 Exception in submitWithEmail: $e\n$stack');
      state = state.copyWith(
        isSubmitting: false,
        generalError: AppStrings.authErrorRegistrationGeneric,
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

      return await _handleAuthResult(result);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: AppStrings.authErrorRegistrationGeneric,
      );
      return false;
    }
  }

  Future<bool> _handleAuthResult(AuthResult result) async {
    switch (result) {
      case AuthSuccess(:final session, :final profile):
        debugPrint('[RegisterFormProvider] ✅ AuthSuccess (userId: ${session.userId})');
        await UserSessionManager.applyUserSwitch(ref, session, profile);
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          session: session,
        );
        return true;

      case RegisterOtpSent(:final message, :final email):
        debugPrint('[RegisterFormProvider] 📧 RegisterOtpSent: $message for $email');
        state = state.copyWith(
          isSubmitting: false,
          isOtpSent: true,
          otpEmail: email,
          otpMessage: message,
        );
        return true;

      case PasswordResetSuccess():
        state = state.copyWith(isSubmitting: false);
        return false;

      case AuthFailure(:final reason, :final message):
        debugPrint('[RegisterFormProvider] ❌ AuthFailure: reason=$reason, message=$message');
        if (reason == AuthFailureReason.cancelled) {
          // User cancelled third-party OAuth: silently return to idle
          state = state.copyWith(isSubmitting: false);
          return false;
        }

        final errorMsg = (message != null && message.isNotEmpty)
            ? message
            : switch (reason) {
                AuthFailureReason.emailAlreadyInUse =>
                  AppStrings.authErrorEmailAlreadyRegistered,
                AuthFailureReason.sameLanguageError =>
                  'Spoken language and learning language cannot be the same',
                AuthFailureReason.network => AppStrings.authErrorNetwork,
                AuthFailureReason.tooManyAttempts =>
                  AppStrings.authErrorTooManyAttempts,
                AuthFailureReason.accountDisabled =>
                  AppStrings.authErrorAccountDisabled,
                AuthFailureReason.weakPassword =>
                  AppStrings.authErrorPasswordTooShort,
                AuthFailureReason.invalidOtp =>
                  'Invalid OTP code. Please check and try again.',
                AuthFailureReason.otpExpired =>
                  'OTP code has expired. Please request a new one.',
                _ => AppStrings.authErrorRegistrationGeneric,
              };

        state = state.copyWith(isSubmitting: false, generalError: errorMsg);
        return false;
    }
  }

  // Handled via UserSessionManager
}

/// Global provider for the register form notifier.
final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((
      ref,
    ) {
      return RegisterFormNotifier(ref);
    });
