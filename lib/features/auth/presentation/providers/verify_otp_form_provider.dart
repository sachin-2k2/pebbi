import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../onboarding/data/registration_payload_builder.dart';
import '../../../onboarding/presentation/providers/onboarding_flow_provider.dart';
import '../../domain/auth_result.dart';
import 'auth_session_provider.dart';
import 'user_session_manager.dart';

/// Form state for the OTP verification screen.
///
/// Follows AGENTS.md §2.3 & §6.
class VerifyOtpFormState {
  const VerifyOtpFormState({
    this.otp = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.generalError,
    this.cooldownRemainingSeconds = 60,
    this.isResending = false,
    this.resendMessage,
  });

  final String otp;
  final bool isSubmitting;
  final bool isSuccess;
  final String? generalError;
  final int cooldownRemainingSeconds;
  final bool isResending;
  final String? resendMessage;

  bool get canResend => cooldownRemainingSeconds <= 0 && !isResending;

  VerifyOtpFormState copyWith({
    String? otp,
    bool? isSubmitting,
    bool? isSuccess,
    String? generalError,
    bool clearGeneralError = false,
    int? cooldownRemainingSeconds,
    bool? isResending,
    String? resendMessage,
  }) {
    return VerifyOtpFormState(
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      generalError: clearGeneralError ? null : (generalError ?? this.generalError),
      cooldownRemainingSeconds:
          cooldownRemainingSeconds ?? this.cooldownRemainingSeconds,
      isResending: isResending ?? this.isResending,
      resendMessage: resendMessage ?? this.resendMessage,
    );
  }
}

/// StateNotifier handling 6-digit OTP entry, verification, and resend cooldown.
class VerifyOtpFormNotifier extends StateNotifier<VerifyOtpFormState> {
  VerifyOtpFormNotifier(this.ref) : super(const VerifyOtpFormState()) {
    _startCooldownTimer();
  }

  final Ref ref;
  Timer? _timer;

  void _startCooldownTimer() {
    _timer?.cancel();
    state = state.copyWith(cooldownRemainingSeconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = state.cooldownRemainingSeconds - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(cooldownRemainingSeconds: 0);
      } else {
        state = state.copyWith(cooldownRemainingSeconds: remaining);
      }
    });
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp.trim(), clearGeneralError: true);
  }

  Future<bool> submitOtp({required String email}) async {
    if (state.isSubmitting) return false;
    final code = state.otp.trim();
    debugPrint('[VerifyOtpProvider] Submitting OTP: "$code" for email: "$email"');
    if (code.length != 6) {
      debugPrint('[VerifyOtpProvider] ⚠️ Code length is not 6');
      state = state.copyWith(
        generalError: 'Please enter all 6 digits of your verification code.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearGeneralError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.verifyOtp(email: email.trim(), otp: code);
      debugPrint('[VerifyOtpProvider] 📥 Result: $result');

      switch (result) {
        case AuthSuccess(:final session, :final profile):
          debugPrint('[VerifyOtpProvider] ✅ Verification success for user: ${session.userId}');
          await UserSessionManager.applyUserSwitch(ref, session, profile);
          state = state.copyWith(isSubmitting: false, isSuccess: true);
          return true;

        case AuthFailure(:final reason, :final message):
          debugPrint('[VerifyOtpProvider] ❌ Verification failed: reason=$reason, message=$message');
          final err = (message != null && message.isNotEmpty)
              ? message
              : (reason == AuthFailureReason.otpExpired
                  ? 'OTP expired. Please request a new one.'
                  : 'Invalid OTP. Please check and try again.');
          state = state.copyWith(isSubmitting: false, generalError: err);
          return false;

        default:
          state = state.copyWith(
            isSubmitting: false,
            generalError: 'Verification failed. Please try again.',
          );
          return false;
      }
    } catch (e, stack) {
      debugPrint('[VerifyOtpProvider] 💥 Exception: $e\n$stack');
      state = state.copyWith(
        isSubmitting: false,
        generalError: 'Connection error during verification.',
      );
      return false;
    }
  }

  Future<void> resendOtp({required String email}) async {
    if (!state.canResend || state.isSubmitting) return;

    state = state.copyWith(isResending: true, clearGeneralError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final onboardingData = RegistrationPayloadBuilder.build(
        ref.read(onboardingFlowProvider),
      );

      final result = await repo.registerWithEmail(
        email: email.trim(),
        password: '', // Kept on server or regenerated
        onboardingData: onboardingData,
      );

      if (result is RegisterOtpSent) {
        state = state.copyWith(
          isResending: false,
          resendMessage: result.message,
        );
        _startCooldownTimer();
      } else if (result is AuthFailure) {
        state = state.copyWith(
          isResending: false,
          generalError: result.message ?? 'Failed to resend code.',
        );
      } else {
        state = state.copyWith(isResending: false);
        _startCooldownTimer();
      }
    } catch (_) {
      state = state.copyWith(
        isResending: false,
        generalError: 'Network error resending code.',
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Auto-disposing provider for OTP verification form state.
final verifyOtpFormProvider =
    StateNotifierProvider.autoDispose<VerifyOtpFormNotifier, VerifyOtpFormState>(
      (ref) => VerifyOtpFormNotifier(ref),
    );
