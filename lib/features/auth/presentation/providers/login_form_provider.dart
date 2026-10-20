import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_scheduler_provider.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../../onboarding/domain/reminder_time.dart';
import '../../domain/auth_result.dart';
import '../../domain/auth_session.dart';
import '../../domain/email_validator.dart';
import '../../domain/password_rules.dart';
import '../../domain/user_profile.dart';
import 'auth_provider.dart';
import 'auth_session_provider.dart';

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

    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.signInWithEmail(
        email: email.trim(),
        password: password,
      );

      return await _handleAuthResult(result);
    } catch (_) {
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

      return await _handleAuthResult(result);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: AppStrings.authErrorUnknown,
      );
      return false;
    }
  }

  Future<bool> _handleAuthResult(AuthResult result) async {
    switch (result) {
      case AuthSuccess(:final session):
        await _applyUserSwitch(session);
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          session: session,
        );
        return true;

      case PasswordResetSuccess():
        state = state.copyWith(isSubmitting: false);
        return false;

      case AuthFailure(:final reason):
        if (reason == AuthFailureReason.cancelled) {
          // User cancelled third-party OAuth: silently return to idle
          state = state.copyWith(isSubmitting: false);
          return false;
        }

        final errorMsg = switch (reason) {
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

  /// Implements AGENTS.md §6 (User Isolation):
  /// 1. Outbox flush stub.
  /// 2. Guest progress merge.
  /// 3. Updates currentUserProvider to authenticated userId.
  /// 4. Cancels prior reminders and reschedules for new user.
  /// 5. Registers push token.
  /// 6. Streak is NOT counted.
  Future<void> _applyUserSwitch(AuthSession session) async {
    // 1. Stub for outbox flush before user switch
    // TODO(question): Try to flush previous user outbox; if offline, keep in old user DB.

    // 2. Guest progress migration
    final currentProfile = ref.read(currentUserProvider);
    final isGuest = currentProfile?.userId.startsWith('guest_') ?? true;
    final guestId = currentProfile?.userId ?? 'guest_default';

    if (isGuest) {
      final repo = ref.read(authRepositoryProvider);
      await repo.mergeGuestProgress(guestId: guestId, userId: session.userId);
    }

    // 3. Update single currentUserProvider driving all user-scoped data
    final newProfile = currentProfile != null
        ? currentProfile.copyWith(userId: session.userId)
        : UserProfile(
            userId: session.userId,
            ageBand: AgeBand.adult,
            explanationLanguageCode: 'en',
            targetLanguageCode: 'es',
            reasonIds: const {'travel'},
            dailyGoalId: 'regular',
            reminderTime: const ReminderTime(hour: 9, minute: 0),
            selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
            remindersEnabled: true,
            accentId: 'violet',
            plan: 'free',
            isOnboarded: true,
          );

    await ref.read(currentUserProvider.notifier).saveProfile(newProfile);

    // 4. Cancel previous user's reminders and reschedule for new user
    final scheduler = ref.read(notificationSchedulerProvider);
    await scheduler.cancelAllReminders();

    if (newProfile.remindersEnabled &&
        newProfile.selectedWeekdayNumbers.isNotEmpty) {
      await scheduler.scheduleWeeklyReminders(
        hour: newProfile.reminderTime.hour,
        minute: newProfile.reminderTime.minute,
        weekdays: newProfile.selectedWeekdayNumbers,
        title: AppStrings.reminderNotificationTitle,
        body: AppStrings.reminderNotificationBody,
      );
    }

    // 5. Register push notification token
    final pushService = ref.read(pushTokenServiceProvider);
    await pushService.registerToken(session.userId);
  }
}

/// Global provider for the login form notifier.
final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(ref);
    });
