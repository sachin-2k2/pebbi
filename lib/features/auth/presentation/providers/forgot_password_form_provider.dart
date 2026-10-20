import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_result.dart';
import '../../domain/clock.dart';
import '../../domain/email_validator.dart';
import '../../domain/password_reset_cooldown.dart';
import 'auth_session_provider.dart';

/// State of the password reset request flow.
enum PasswordResetStatus { idle, submitting, sent, error }

/// Immutable state for the forgot password flow.
class ForgotPasswordFormState {
  const ForgotPasswordFormState({
    this.status = PasswordResetStatus.idle,
    this.emailError,
    this.generalError,
    this.sentToEmail = '',
    required this.cooldown,
  });

  final PasswordResetStatus status;
  final String? emailError;
  final String? generalError;
  final String sentToEmail;
  final PasswordResetCooldown cooldown;

  bool get isSubmitting => status == PasswordResetStatus.submitting;
  bool get isSent => status == PasswordResetStatus.sent;
  bool get canResend => cooldown.canResend;
  int get cooldownRemainingSeconds => cooldown.remainingSeconds;

  ForgotPasswordFormState copyWith({
    PasswordResetStatus? status,
    String? Function()? emailError,
    String? Function()? generalError,
    String? sentToEmail,
    PasswordResetCooldown? cooldown,
  }) {
    return ForgotPasswordFormState(
      status: status ?? this.status,
      emailError: emailError != null ? emailError() : this.emailError,
      generalError: generalError != null ? generalError() : this.generalError,
      sentToEmail: sentToEmail ?? this.sentToEmail,
      cooldown: cooldown ?? this.cooldown,
    );
  }
}

/// Provider for the clock abstraction.
final appClockProvider = Provider<AppClock>((ref) {
  return const SystemClock();
});

/// Provider for [ForgotPasswordFormNotifier].
final forgotPasswordFormProvider =
    StateNotifierProvider.autoDispose<
      ForgotPasswordFormNotifier,
      ForgotPasswordFormState
    >((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      final clock = ref.watch(appClockProvider);
      return ForgotPasswordFormNotifier(
        authRepository: authRepository,
        clock: clock,
      );
    });

/// Riverpod notifier managing the Forgot Password form and resend cooldown.
///
/// Follows AGENTS.md §2.3 & §6: Session state resets cleanly, no user data leakage.
class ForgotPasswordFormNotifier
    extends StateNotifier<ForgotPasswordFormState> {
  ForgotPasswordFormNotifier({
    required AuthRepository authRepository,
    AppClock clock = const SystemClock(),
  }) : _authRepository = authRepository,
       _clock = clock,
       super(
         ForgotPasswordFormState(cooldown: PasswordResetCooldown(clock: clock)),
       );

  final AuthRepository _authRepository;
  final AppClock _clock;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Validates and returns an initial email to pre-fill into the text field.
  ///
  /// Never pre-fills malformed email strings or passwords.
  String? sanitizeInitialEmail(String? rawEmail) {
    if (rawEmail == null) return null;
    final trimmed = rawEmail.trim();
    if (EmailValidator.validate(trimmed) == null) {
      return trimmed;
    }
    return null;
  }

  /// Submits a password reset request for [email].
  Future<void> submit({required String email}) async {
    if (state.isSubmitting) return;

    final trimmedEmail = email.trim();
    final validationError = EmailValidator.validate(trimmedEmail);

    if (validationError != null) {
      final errorMsg = validationError == EmailValidationError.empty
          ? AppStrings.authErrorEmailEmpty
          : AppStrings.authErrorEmailInvalid;

      state = state.copyWith(
        status: PasswordResetStatus.error,
        emailError: () => errorMsg,
        generalError: () => null,
      );
      return;
    }

    state = state.copyWith(
      status: PasswordResetStatus.submitting,
      emailError: () => null,
      generalError: () => null,
    );

    try {
      final result = await _authRepository.requestPasswordReset(
        email: trimmedEmail,
      );

      if (!mounted) return;

      switch (result) {
        case PasswordResetSuccess():
          _startCooldown();
          state = state.copyWith(
            status: PasswordResetStatus.sent,
            sentToEmail: trimmedEmail,
            emailError: () => null,
            generalError: () => null,
          );
          // ignore: deprecated_member_use
          SemanticsService.announce(
            AppStrings.resetLinkSuccessAnnouncement,
            TextDirection.ltr,
          );

        case AuthFailure(:final reason):
          final message = _mapFailureToMessage(reason);
          state = state.copyWith(
            status: PasswordResetStatus.error,
            generalError: () => message,
          );
          // ignore: deprecated_member_use
          SemanticsService.announce(message, TextDirection.ltr);

        case AuthSuccess():
          // Should not happen for reset link requests, treat as success
          _startCooldown();
          state = state.copyWith(
            status: PasswordResetStatus.sent,
            sentToEmail: trimmedEmail,
          );
      }
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        status: PasswordResetStatus.error,
        generalError: () => AppStrings.authErrorResetGeneric,
      );
    }
  }

  /// Resends a password reset link to the previously entered email.
  Future<void> resend() async {
    if (!state.canResend || state.isSubmitting || state.sentToEmail.isEmpty) {
      return;
    }
    await submit(email: state.sentToEmail);
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    final newCooldown = state.cooldown.startNewCooldown();
    state = state.copyWith(cooldown: newCooldown);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (state.cooldown.remainingSeconds <= 0) {
        timer.cancel();
        state = state.copyWith(cooldown: PasswordResetCooldown(clock: _clock));
        // ignore: deprecated_member_use
        SemanticsService.announce(
          AppStrings.resendAvailableAnnouncement,
          TextDirection.ltr,
        );
      } else {
        // Trigger state rebuild with updated remaining seconds
        state = state.copyWith(cooldown: state.cooldown);
      }
    });
  }

  String _mapFailureToMessage(AuthFailureReason reason) {
    switch (reason) {
      case AuthFailureReason.network:
        return AppStrings.authErrorNetwork;
      case AuthFailureReason.tooManyAttempts:
        return AppStrings.authErrorTooManyRequests;
      default:
        return AppStrings.authErrorResetGeneric;
    }
  }
}
