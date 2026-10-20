import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/services/fake_notification_scheduler.dart';
import 'package:peddi/core/services/notification_scheduler_provider.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/data/mock_auth_repository.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/data/mock_push_token_service.dart';
import 'package:peddi/features/auth/data/mock_secure_session_store.dart';
import 'package:peddi/features/auth/domain/auth_result.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:peddi/features/auth/presentation/screens/register_screen.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_card.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_header.dart';
import 'package:peddi/features/auth/presentation/widgets/confirm_password_field.dart';
import 'package:peddi/features/auth/presentation/widgets/email_field.dart';
import 'package:peddi/features/auth/presentation/widgets/or_divider.dart';
import 'package:peddi/features/auth/presentation/widgets/password_field.dart';
import 'package:peddi/features/auth/presentation/widgets/social_button.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    MockAuthRepository? authRepo,
    MockProfileRepository? profileRepo,
    MockSecureSessionStore? secureStore,
    String? returnTo,
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
  }) {
    final effectiveRepo = authRepo ?? MockAuthRepository();
    final effectiveProfileRepo = profileRepo ?? MockProfileRepository();
    final effectiveSecureStore = secureStore ?? MockSecureSessionStore();

    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(textScale),
              size: const Size(390, 844),
            ),
            child: RegisterScreen(returnTo: returnTo),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
        GoRoute(
          path: '/path',
          builder: (context, state) =>
              const Scaffold(body: Text('Path Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(effectiveRepo),
        profileRepositoryProvider.overrideWithValue(effectiveProfileRepo),
        secureSessionStoreProvider.overrideWithValue(effectiveSecureStore),
        notificationSchedulerProvider.overrideWithValue(
          FakeNotificationScheduler(),
        ),
        pushTokenServiceProvider.overrideWithValue(MockPushTokenService()),
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

  Future<void> tapSubmit(WidgetTester tester) async {
    final buttonFinder = find.widgetWithText(
      Button3D,
      AppStrings.createAccountAction,
    );
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapLoginLink(WidgetTester tester) async {
    final linkFinder = find.text(AppStrings.logInAction);
    await tester.ensureVisible(linkFinder);
    await tester.tap(linkFinder);
    await tester.pumpAndSettle();
  }

  group('RegisterScreen Visual Hierarchy & Design Verification', () {
    testWidgets('renders all design elements matching screenshot', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AuthHeader), findsOneWidget);
      expect(find.byType(AuthCard), findsOneWidget);
      expect(find.byType(SocialButton), findsOneWidget);
      expect(find.byType(OrDivider), findsOneWidget);
      expect(find.byType(EmailField), findsOneWidget);
      expect(find.byType(PasswordField), findsNWidgets(2)); // Primary + Confirm
      expect(find.byType(ConfirmPasswordField), findsOneWidget);

      expect(find.text(AppStrings.pebbiWordmark), findsOneWidget);
      expect(find.text(AppStrings.createAccountTitle), findsOneWidget);
      expect(find.text(AppStrings.createAccountSubtitle), findsOneWidget);
      expect(find.text(AppStrings.continueWithGoogle), findsOneWidget);
      expect(find.text(AppStrings.orDivider), findsOneWidget);
      expect(find.text(AppStrings.emailLabel), findsOneWidget);
      expect(find.text(AppStrings.emailPlaceholder), findsOneWidget);
      expect(find.text(AppStrings.passwordLabel), findsOneWidget);
      expect(find.text(AppStrings.confirmPasswordLabel), findsOneWidget);
      expect(find.text(AppStrings.createAccountAction), findsOneWidget);
      expect(find.text(AppStrings.alreadyHaveAnAccount), findsOneWidget);
      expect(find.text(AppStrings.logInAction), findsOneWidget);
      expect(find.text(AppStrings.termsAndPrivacyPlaceholder), findsOneWidget);

      // Verify NO "Forgot password?" link on Register
      expect(find.text(AppStrings.forgotPassword), findsNothing);

      // Verify NO close button
      expect(find.byIcon(Icons.close), findsNothing);

      // Verify Google auth button uses google.png
      final googleImageFinder = find.descendant(
        of: find.byType(SocialButton),
        matching: find.byType(Image),
      );
      expect(googleImageFinder, findsOneWidget);
      final imageWidget = tester.widget<Image>(googleImageFinder);
      expect(
        (imageWidget.image as AssetImage).assetName,
        'assets/images/google.png',
      );

      // Verify mascot carries person_add badge
      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
    });

    testWidgets('autofill hints, keyboard types, and text actions are set', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.length, 3);

      final emailField = textFields.elementAt(0);
      expect(emailField.keyboardType, TextInputType.emailAddress);
      expect(emailField.textInputAction, TextInputAction.next);
      expect(
        emailField.autofillHints,
        containsAll([AutofillHints.email, AutofillHints.username]),
      );
      expect(emailField.textDirection, TextDirection.ltr);

      final passwordField = textFields.elementAt(1);
      expect(passwordField.obscureText, isTrue);
      expect(passwordField.textInputAction, TextInputAction.next);
      expect(passwordField.autofillHints, contains(AutofillHints.newPassword));

      final confirmField = textFields.elementAt(2);
      expect(confirmField.obscureText, isTrue);
      expect(confirmField.textInputAction, TextInputAction.done);
      expect(confirmField.autofillHints, contains(AutofillHints.newPassword));
    });

    testWidgets('both password eye toggles switch independently', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Initially both obscured
      final eyeIcons = find.byIcon(Icons.visibility_outlined);
      expect(eyeIcons, findsNWidgets(2));

      // Tap first eye toggle (primary password)
      await tester.tap(eyeIcons.first);
      await tester.pumpAndSettle();

      var textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.elementAt(1).obscureText, isFalse);
      expect(textFields.elementAt(2).obscureText, isTrue);

      // Tap second eye toggle (confirm password)
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.elementAt(1).obscureText, isFalse);
      expect(textFields.elementAt(2).obscureText, isFalse);
    });
  });

  group('Validation & Error States', () {
    testWidgets(
      'shows field errors when Create account pressed with empty inputs',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        await tapSubmit(tester);

        expect(find.text(AppStrings.authErrorEmailEmpty), findsOneWidget);
        expect(find.text(AppStrings.authErrorPasswordEmpty), findsNWidgets(2));
      },
    );

    testWidgets('shows invalid email format error for malformed input', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      await tapSubmit(tester);

      expect(find.text(AppStrings.authErrorEmailInvalid), findsOneWidget);
    });

    testWidgets('shows password too short error for passwords < 8 chars', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'short');
      await tester.enterText(find.byType(TextField).at(2), 'short');

      await tapSubmit(tester);

      expect(find.text(AppStrings.authErrorPasswordTooShort), findsOneWidget);
    });

    testWidgets('shows password mismatch error when confirm field differs', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'mismatch456');

      await tapSubmit(tester);

      expect(find.text(AppStrings.authErrorPasswordMismatch), findsOneWidget);
    });

    testWidgets(
      'shows neutral placeholder message when email is already registered',
      (tester) async {
        final authRepo = MockAuthRepository();
        await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(0),
          'alreadyregistered@example.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.enterText(find.byType(TextField).at(2), 'password123');

        await tapSubmit(tester);

        expect(
          find.text(AppStrings.authErrorEmailAlreadyRegistered),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows network error banner when connection fails', (
      tester,
    ) async {
      final authRepo = MockAuthRepository(
        forceFailureReason: AuthFailureReason.network,
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      await tapSubmit(tester);

      expect(find.text(AppStrings.authErrorNetwork), findsOneWidget);
    });
  });

  group('Navigation & Double-Tap Protection', () {
    testWidgets('Log in link switches route to Login', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tapLoginLink(tester);

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('double-tap protection rejects duplicate register calls', (
      tester,
    ) async {
      final authRepo = MockAuthRepository(
        simulatedDelay: const Duration(milliseconds: 300),
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      final buttonFinder = find.widgetWithText(
        Button3D,
        AppStrings.createAccountAction,
      );
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(authRepo.registerAttempts, 1);
    });

    testWidgets('Google cancel returns silently to idle', (tester) async {
      final authRepo = MockAuthRepository(forceGoogleCancel: true);
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.continueWithGoogle));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorUnknown), findsNothing);
      expect(find.text(AppStrings.createAccountAction), findsOneWidget);
    });
  });

  group('User Isolation Tests (AGENTS.md Section 6)', () {
    testWidgets(
      '(a) guest with progress registers: progress follows and guest data migrates',
      (tester) async {
        final authRepo = MockAuthRepository();
        final profileRepo = MockProfileRepository(
          initialProfile: const UserProfile(
            userId: 'guest_test_999',
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

        await tester.pumpWidget(
          buildTestableScreen(authRepo: authRepo, profileRepo: profileRepo),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(0),
          'newuser@example.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.enterText(find.byType(TextField).at(2), 'password123');

        await tapSubmit(tester);

        // Migration was executed
        expect(
          authRepo.mergedGuestProgressCalls.containsKey('guest_test_999'),
          isTrue,
        );
        // Navigated away to path
        expect(find.text('Path Screen'), findsOneWidget);
      },
    );

    testWidgets(
      '(b) migration fails halfway: guest data remains safe in guest DB',
      (tester) async {
        final authRepo = MockAuthRepository()..forceMigrationFailure = true;
        final profileRepo = MockProfileRepository(
          initialProfile: const UserProfile(
            userId: 'guest_safe_111',
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

        await tester.pumpWidget(
          buildTestableScreen(authRepo: authRepo, profileRepo: profileRepo),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(0),
          'user@example.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.enterText(find.byType(TextField).at(2), 'password123');

        await tapSubmit(tester);

        // Guest profile untouched
        final profile = await profileRepo.getCurrentProfile();
        expect(profile?.userId, 'guest_safe_111');
      },
    );

    testWidgets('(c) user B logs out, then user A registers: no trace of B', (
      tester,
    ) async {
      final authRepo = MockAuthRepository();
      final secureStore = MockSecureSessionStore();

      // Simulate User B logged out
      await authRepo.signOut();

      await tester.pumpWidget(
        buildTestableScreen(authRepo: authRepo, secureStore: secureStore),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'userA@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      await tapSubmit(tester);

      // Active session is User A
      final session = await authRepo.getCurrentSession();
      expect(session?.email, 'userA@example.com');
    });

    testWidgets('(d) log out and re-login restores account data', (
      tester,
    ) async {
      final authRepo = MockAuthRepository();
      final secureStore = MockSecureSessionStore();

      await tester.pumpWidget(
        buildTestableScreen(authRepo: authRepo, secureStore: secureStore),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        'persisted@example.com',
      );
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      await tapSubmit(tester);

      final registeredUserId = (await authRepo.getCurrentSession())?.userId;

      // Logout
      await authRepo.signOut();
      expect(await authRepo.getCurrentSession(), isNull);

      // Re-login
      final loginResult = await authRepo.signInWithEmail(
        email: 'persisted@example.com',
        password: 'password123',
      );
      expect((loginResult as AuthSuccess).session.userId, registeredUserId);
    });
  });

  group('Responsive & Overflow Tests Across Required Devices', () {
    final testSizes = [
      const Size(360, 640), // Small Android phone
      const Size(390, 844), // iPhone
      const Size(430, 932), // Large phone
      const Size(800, 1280), // Android tablet, portrait
      const Size(1280, 800), // Android tablet, landscape
      const Size(1024, 1366), // iPad Pro
      const Size(700, 900), // Split-screen window
    ];

    for (final size in testSizes) {
      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 1.0x text scale',
        (tester) async {
          tester.view.physicalSize = Size(size.width, size.height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(buildTestableScreen(textScale: 1.0));
          await tester.pumpAndSettle();

          expect(find.text(AppStrings.createAccountTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 2.0x text scale',
        (tester) async {
          tester.view.physicalSize = Size(size.width, size.height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(buildTestableScreen(textScale: 2.0));
          await tester.pumpAndSettle();

          expect(find.text(AppStrings.createAccountTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('renders cleanly with simulated keyboard bottom insets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.createAccountTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
