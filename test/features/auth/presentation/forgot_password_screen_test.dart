import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/data/mock_auth_repository.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/auth_result.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:peddi/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_card.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_header.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_text_link.dart';
import 'package:peddi/features/auth/presentation/widgets/forgot_password_form.dart';
import 'package:peddi/features/auth/presentation/widgets/general_error_banner.dart';
import 'package:peddi/features/auth/presentation/widgets/resend_button.dart';
import 'package:peddi/features/auth/presentation/widgets/reset_link_sent_view.dart';
import 'package:peddi/l10n/app_strings.dart';

import 'package:peddi/features/auth/domain/clock.dart';
import 'package:peddi/features/auth/presentation/providers/forgot_password_form_provider.dart';

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
  Widget buildTestableScreen({
    MockAuthRepository? authRepo,
    MockProfileRepository? profileRepo,
    AppClock? clock,
    String? initialEmail,
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
    Size windowSize = const Size(390, 844),
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    final effectiveRepo = authRepo ?? MockAuthRepository();
    final effectiveProfileRepo = profileRepo ?? MockProfileRepository();
    final effectiveClock = clock ?? const SystemClock();

    final router = GoRouter(
      initialLocation: '/forgot-password',
      routes: [
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => MediaQuery(
            data: MediaQueryData(
              size: windowSize,
              viewInsets: viewInsets,
              textScaler: TextScaler.linear(textScale),
            ),
            child: ForgotPasswordScreen(initialEmail: initialEmail),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(effectiveRepo),
        profileRepositoryProvider.overrideWithValue(effectiveProfileRepo),
        appClockProvider.overrideWithValue(effectiveClock),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
    );
  }

  group('ForgotPasswordScreen Visual Hierarchy & Design', () {
    testWidgets('renders all design elements matching screenshot', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AuthHeader), findsOneWidget);
      expect(find.byType(AuthCard), findsOneWidget);
      expect(find.byType(ForgotPasswordForm), findsOneWidget);

      expect(find.text(AppStrings.resetPasswordTitle), findsOneWidget);
      expect(find.text(AppStrings.resetPasswordSubtitle), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsWidgets);

      expect(find.text(AppStrings.emailAddressLabel), findsOneWidget);
      expect(find.text(AppStrings.emailPlaceholder), findsOneWidget);
      expect(find.text(AppStrings.sendResetLinkAction), findsOneWidget);
      expect(find.text(AppStrings.backToLogIn), findsOneWidget);

      // Verify absence of close/back control in the header
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('pre-fills valid email from login screen', (tester) async {
      await tester.pumpWidget(
        buildTestableScreen(initialEmail: 'alex@example.com'),
      );
      await tester.pumpAndSettle();

      expect(find.text('alex@example.com'), findsOneWidget);
    });

    testWidgets('ignores invalid email string on pre-fill', (tester) async {
      await tester.pumpWidget(
        buildTestableScreen(initialEmail: 'invalid-email-address'),
      );
      await tester.pumpAndSettle();

      expect(find.text('invalid-email-address'), findsNothing);
      expect(find.text(AppStrings.emailPlaceholder), findsOneWidget);
    });
  });

  group('Form Validation and Submission', () {
    testWidgets('shows error for empty email submission', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorEmailEmpty), findsOneWidget);
    });

    testWidgets('shows error for malformed email submission', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'notanemail');
      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorEmailInvalid), findsOneWidget);
    });

    testWidgets('submits via TextInputAction.done', (tester) async {
      final repo = MockAuthRepository();
      await tester.pumpWidget(buildTestableScreen(authRepo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'valid@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repo.passwordResetAttempts, 1);
      expect(find.byType(ResetLinkSentView), findsOneWidget);
    });

    testWidgets('locks form and prevents double-taps while submitting', (
      tester,
    ) async {
      final repo = MockAuthRepository(
        simulatedDelay: const Duration(milliseconds: 300),
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'user@example.com');

      // First tap initiates submission
      await tester.tap(find.byType(Button3D));
      await tester.pump(const Duration(milliseconds: 50));

      // Button is loading
      expect(find.text(AppStrings.sendingResetLinkProcessing), findsOneWidget);

      // Attempt second tap while submitting
      await tester.tap(find.byType(Button3D));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(repo.passwordResetAttempts, 1);
    });
  });

  group('Success State, Account Enumeration, and Cooldown', () {
    testWidgets(
      'replaces form with neutral confirmation message and typed email',
      (tester) async {
        final repo = MockAuthRepository();
        await tester.pumpWidget(buildTestableScreen(authRepo: repo));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'alex.hunter@example.com',
        );
        await tester.tap(find.byType(Button3D));
        await tester.pumpAndSettle();

        expect(find.byType(ResetLinkSentView), findsOneWidget);
        expect(find.text(AppStrings.checkYourInboxTitle), findsOneWidget);
        expect(
          find.text(
            AppStrings.resetLinkSentNeutralMessage('alex.hunter@example.com'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('resend link is disabled during 60s cooldown', (tester) async {
      final repo = MockAuthRepository();
      final clock = FakeClock(DateTime(2026, 10, 20, 12, 0, 0));
      await tester.pumpWidget(
        buildTestableScreen(authRepo: repo, clock: clock),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'alex@example.com');
      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(find.byType(ResendButton), findsOneWidget);
      expect(find.text(AppStrings.resendCooldownAction(60)), findsOneWidget);

      // Tap disabled resend button during cooldown
      await tester.tap(find.byType(ResendButton));
      await tester.pump();
      expect(repo.passwordResetAttempts, 1);

      // Advance clock and timer past 60s cooldown
      clock.advance(const Duration(seconds: 61));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.resendLinkAction), findsOneWidget);

      // Tap enabled resend button
      await tester.tap(find.byType(ResendButton));
      await tester.pumpAndSettle();
      expect(repo.passwordResetAttempts, 2);
    });
  });

  group('Failure States & Navigation', () {
    testWidgets('network failure keeps typed email and shows error banner', (
      tester,
    ) async {
      final repo = MockAuthRepository(
        forceFailureReason: AuthFailureReason.network,
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'keepme@example.com');
      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(find.byType(GeneralErrorBanner), findsOneWidget);
      expect(find.text(AppStrings.authErrorNetwork), findsOneWidget);
      expect(find.text('keepme@example.com'), findsOneWidget);
    });

    testWidgets('rate limit failure shows too many requests banner', (
      tester,
    ) async {
      final repo = MockAuthRepository(
        forceFailureReason: AuthFailureReason.tooManyAttempts,
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(find.byType(GeneralErrorBanner), findsOneWidget);
      expect(find.text(AppStrings.authErrorTooManyRequests), findsOneWidget);
    });

    testWidgets(
      'tapping Back to log in navigates to Login without duplicate stacks',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        final linkFinder = find.byType(AuthTextLink);
        await tester.ensureVisible(linkFinder);
        await tester.tap(linkFinder);
        await tester.pumpAndSettle();

        expect(find.text('Login Screen'), findsOneWidget);
      },
    );

    testWidgets('signed-in user can open forgot password screen', (
      tester,
    ) async {
      final profileRepo = MockProfileRepository(
        initialProfile: const UserProfile(
          userId: 'user_123',
          ageBand: AgeBand.adult,
          explanationLanguageCode: 'en',
          targetLanguageCode: 'es',
          reasonIds: {'travel'},
          dailyGoalId: 'regular',
          reminderTime: ReminderTime(hour: 9, minute: 0),
          selectedWeekdayNumbers: {1, 2, 3, 4, 5},
          remindersEnabled: true,
          accentId: 'violet',
          plan: 'free',
          isOnboarded: true,
        ),
      );
      await tester.pumpWidget(buildTestableScreen(profileRepo: profileRepo));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text(AppStrings.resetPasswordTitle), findsOneWidget);
    });
  });

  group('Responsive Layout Verification (7 sizes, 1.0x & 2.0x text scale)', () {
    final testSizes = [
      const Size(360, 640), // Small Android phone
      const Size(390, 844), // iPhone
      const Size(430, 932), // Large phone
      const Size(800, 1280), // Android tablet portrait
      const Size(1280, 800), // Android tablet landscape
      const Size(1024, 1366), // iPad Pro portrait
      const Size(700, 900), // Split-screen / foldable
    ];

    for (final size in testSizes) {
      testWidgets(
        'no overflow at ${size.width.toInt()}x${size.height.toInt()} at 1.0x',
        (tester) async {
          await tester.pumpWidget(
            buildTestableScreen(
              windowSize: size,
              textScale: 1.0,
              viewInsets: const EdgeInsets.only(
                bottom: 280,
              ), // simulated keyboard
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ForgotPasswordScreen), findsOneWidget);
        },
      );

      testWidgets(
        'no overflow at ${size.width.toInt()}x${size.height.toInt()} at 2.0x',
        (tester) async {
          await tester.pumpWidget(
            buildTestableScreen(
              windowSize: size,
              textScale: 2.0,
              viewInsets: const EdgeInsets.only(
                bottom: 280,
              ), // simulated keyboard
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ForgotPasswordScreen), findsOneWidget);
        },
      );
    }
  });
}
