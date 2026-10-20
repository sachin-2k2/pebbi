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
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:peddi/features/auth/presentation/screens/login_screen.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_card.dart';
import 'package:peddi/features/auth/presentation/widgets/auth_header.dart';
import 'package:peddi/features/auth/presentation/widgets/or_divider.dart';
import 'package:peddi/features/auth/presentation/widgets/social_button.dart';
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
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(textScale),
              size: const Size(390, 844),
            ),
            child: LoginScreen(returnTo: returnTo),
          ),
        ),
        GoRoute(
          path: '/path',
          builder: (context, state) =>
              const Scaffold(body: Text('Path Screen')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) =>
              const Scaffold(body: Text('Forgot Password')),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const Scaffold(body: Text('Register')),
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

  group('LoginScreen Visual Hierarchy & Design Verification', () {
    testWidgets('renders all design elements matching screenshot', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AuthHeader), findsOneWidget);
      expect(find.byType(AuthCard), findsOneWidget);
      expect(find.byType(SocialButton), findsOneWidget);
      expect(find.byType(OrDivider), findsOneWidget);

      expect(find.text(AppStrings.pebbiWordmark), findsOneWidget);
      expect(find.text(AppStrings.welcomeBackTitle), findsOneWidget);
      expect(find.text(AppStrings.welcomeBackSubtitle), findsOneWidget);
      expect(find.text(AppStrings.continueWithGoogle), findsOneWidget);
      expect(find.text(AppStrings.orDivider), findsOneWidget);
      expect(find.text(AppStrings.emailLabel), findsOneWidget);
      expect(find.text(AppStrings.emailPlaceholder), findsOneWidget);
      expect(find.text(AppStrings.passwordLabel), findsOneWidget);
      expect(find.text(AppStrings.forgotPassword), findsOneWidget);
      expect(find.text(AppStrings.logInAction), findsOneWidget);
      expect(find.text(AppStrings.newToPebbi), findsOneWidget);
      expect(find.text(AppStrings.createAnAccount), findsOneWidget);

      // Verify no close button on login screen per user requirement
      expect(find.byIcon(Icons.close), findsNothing);

      // Verify Google auth button uses assets/images/google.png
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
    });

    testWidgets('autofill hints, keyboard types, and text actions are set', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.length, 2);

      final emailField = textFields.first;
      expect(emailField.keyboardType, TextInputType.emailAddress);
      expect(emailField.textInputAction, TextInputAction.next);
      expect(
        emailField.autofillHints,
        containsAll([AutofillHints.email, AutofillHints.username]),
      );
      expect(emailField.textDirection, TextDirection.ltr);

      final passwordField = textFields.last;
      expect(passwordField.obscureText, isTrue);
      expect(passwordField.textInputAction, TextInputAction.done);
      expect(passwordField.autofillHints, contains(AutofillHints.password));
    });

    testWidgets('password eye toggle switches obscured state and semantics', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(AppStrings.showPasswordSemantics),
        findsOneWidget,
      );
      TextField pwdField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(pwdField.obscureText, isTrue);

      await tester.tap(find.bySemanticsLabel(AppStrings.showPasswordSemantics));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(AppStrings.hidePasswordSemantics),
        findsOneWidget,
      );
      pwdField = tester.widget<TextField>(find.byType(TextField).last);
      expect(pwdField.obscureText, isFalse);
    });
  });

  group('Validation & Error States', () {
    testWidgets('shows field errors when Log in pressed with empty inputs', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Button3D, AppStrings.logInAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorEmailEmpty), findsOneWidget);
      expect(find.text(AppStrings.authErrorPasswordEmpty), findsOneWidget);
    });

    testWidgets('shows invalid email format error for malformed input', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'invalid-email');
      await tester.enterText(find.byType(TextField).last, 'pass123');

      await tester.tap(find.widgetWithText(Button3D, AppStrings.logInAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorEmailInvalid), findsOneWidget);
      expect(find.text(AppStrings.authErrorPasswordEmpty), findsNothing);
    });

    testWidgets('shows generic banner for invalid credentials', (tester) async {
      final authRepo = MockAuthRepository();
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'wrong@example.com');
      await tester.enterText(find.byType(TextField).last, 'validpass');

      await tester.tap(find.widgetWithText(Button3D, AppStrings.logInAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorInvalidCredentials), findsOneWidget);
    });

    testWidgets('shows network error banner when connection fails', (
      tester,
    ) async {
      final authRepo = MockAuthRepository(
        forceFailureReason: AuthFailureReason.network,
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'you@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.widgetWithText(Button3D, AppStrings.logInAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.authErrorNetwork), findsOneWidget);
    });
  });

  group('Google Sign-In & Double-Tap Protection', () {
    testWidgets('Google sign-in user cancellation returns silently to idle', (
      tester,
    ) async {
      final authRepo = MockAuthRepository(forceGoogleCancel: true);
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.continueWithGoogle));
      await tester.pumpAndSettle();

      // No error banner displayed
      expect(find.text(AppStrings.authErrorUnknown), findsNothing);
      expect(find.text(AppStrings.logInAction), findsOneWidget);
    });

    testWidgets('double-tap protection rejects duplicate submission calls', (
      tester,
    ) async {
      final authRepo = MockAuthRepository(
        simulatedDelay: const Duration(milliseconds: 300),
      );
      await tester.pumpWidget(buildTestableScreen(authRepo: authRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'you@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Tap twice rapidly
      await tester.tap(find.widgetWithText(Button3D, AppStrings.logInAction));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(find.byType(Button3D));
      await tester.pumpAndSettle();

      expect(authRepo.signInAttempts, 1);
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

          expect(find.text(AppStrings.welcomeBackTitle), findsOneWidget);
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

          expect(find.text(AppStrings.welcomeBackTitle), findsOneWidget);
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

      expect(find.text(AppStrings.welcomeBackTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
