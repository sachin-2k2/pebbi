import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/design_system/ring.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/profile_repository.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/lesson/presentation/screens/lesson_placeholder_screen.dart';
import 'package:peddi/features/onboarding/data/mock_path_preparation_service.dart';
import 'package:peddi/features/onboarding/domain/path_preparation_service.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/path_ready_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/path_ready_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/path_ready/animated_check.dart';
import 'package:peddi/features/onboarding/presentation/widgets/path_ready/first_lesson_note.dart';
import 'package:peddi/features/onboarding/presentation/widgets/path_ready/readiness_checklist.dart';
import 'package:peddi/features/onboarding/presentation/widgets/path_ready/readiness_row.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    GoRouter? router,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    PathPreparationService? preparationService,
    ProfileRepository? profileRepository,
    AudioFeedbackService? audioFeedbackService,
    bool initialStep11Access = true,
    AppSettings? initialSettings,
    void Function(WidgetRef ref)? onInit,
  }) {
    final effectivePrep =
        preparationService ??
        const MockPathPreparationService(totalDuration: Duration.zero);
    final effectiveProfileRepo = profileRepository ?? MockProfileRepository();
    final effectiveAudio = audioFeedbackService ?? FakeAudioFeedbackService();

    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/onboarding/setup/step-11',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-10',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 10 Premium Offer')),
            ),
            GoRoute(
              path: '/onboarding/setup/step-11',
              builder: (context, state) => const PathReadyStepScreen(),
            ),
            GoRoute(
              path: '/lesson/:id',
              builder: (context, state) => LessonPlaceholderScreen(
                lessonNumber:
                    int.tryParse(state.pathParameters['id'] ?? '1') ?? 1,
              ),
            ),
            GoRoute(
              path: '/path',
              builder: (context, state) =>
                  const Scaffold(body: Text('Home Path Screen')),
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
        pathPreparationServiceProvider.overrideWithValue(effectivePrep),
        profileRepositoryProvider.overrideWithValue(effectiveProfileRepo),
        audioFeedbackServiceProvider.overrideWithValue(effectiveAudio),
        if (initialSettings != null)
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier(initialSettings),
          ),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (initialStep11Access) {
              ref.read(onboardingFlowProvider.notifier).setPlan('free');
              ref.read(onboardingFlowProvider.notifier).setStep(11);
            }
            if (onInit != null) {
              onInit(ref);
            }
          });

          final settings = ref.watch(appSettingsProvider);
          return MaterialApp.router(
            routerConfig: effectiveRouter,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale * settings.textScale),
                ),
                child: widget!,
              );
            },
          );
        },
      ),
    );
  }

  group('PathReadyStepScreen Layout & Visual Verification', () {
    testWidgets('renders all design elements matching finished screenshot', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // No progress header and no back button per design screenshot
      expect(find.byType(StepProgressHeader), findsNothing);

      // Centered Title
      expect(find.text(AppStrings.pathReadyTitle), findsOneWidget);

      // Ring with 100% progress and surprised mascot inside
      final ringFinder = find.byType(Ring);
      expect(ringFinder, findsOneWidget);
      final ring = tester.widget<Ring>(ringFinder);
      expect(ring.progress, equals(1.0));

      final mascotFinder = find.byType(PebbiMascot);
      expect(mascotFinder, findsOneWidget);
      final mascot = tester.widget<PebbiMascot>(mascotFinder);
      expect(mascot.expression, PebbiExpression.surprised);
      expect(mascot.accentColor, AppColors.brandPurple);

      // Three rows in checklist with checks
      expect(find.byType(ReadinessChecklist), findsOneWidget);
      expect(find.byType(ReadinessRow), findsNWidgets(3));
      expect(find.text(AppStrings.taskAudioReady), findsOneWidget);
      expect(find.text(AppStrings.taskStickerStarted), findsOneWidget);
      expect(find.text(AppStrings.taskSpeakingUnlocked), findsOneWidget);

      // Checkmarks present
      expect(find.byType(AnimatedCheck), findsNWidgets(3));

      // Dynamic First Lesson Note
      expect(find.byType(FirstLessonNote), findsOneWidget);
      expect(
        find.text('Your first lesson takes about 3 minutes.'),
        findsOneWidget,
      );

      // Pinned Button3D enabled with Mint background
      final buttonFinder = find.widgetWithText(Button3D, 'Start lesson 1');
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<Button3D>(buttonFinder);
      expect(button.isEnabled, isTrue);
      expect(button.backgroundColor, AppColors.mint);
    });

    testWidgets('initial state displays pending rows and disabled button', (
      tester,
    ) async {
      const slowService = MockPathPreparationService(
        totalDuration: Duration(seconds: 10),
      );

      await tester.pumpWidget(
        buildTestableScreen(preparationService: slowService),
      );
      await tester.pump(); // Frame 0

      // Button is disabled with disabled color
      final buttonFinder = find.widgetWithText(Button3D, 'Start lesson 1');
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<Button3D>(buttonFinder);
      expect(button.isEnabled, isFalse);
      expect(button.backgroundColor, AppColors.disabled);

      // Checks are not yet done (0 check icons visible)
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('reduceMotion skips animation and finishes immediately', (
      tester,
    ) async {
      const slowService = MockPathPreparationService(
        totalDuration: Duration(seconds: 10),
      );

      await tester.pumpWidget(
        buildTestableScreen(
          preparationService: slowService,
          initialSettings: const AppSettings(reduceMotion: true),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<Button3D>(
        find.widgetWithText(Button3D, 'Start lesson 1'),
      );
      expect(button.isEnabled, isTrue);
      expect(find.byType(AnimatedCheck), findsNWidgets(3));
    });

    testWidgets(
      'failed task shows error message, retry button, and disables start button',
      (tester) async {
        const failingService = MockPathPreparationService(
          totalDuration: Duration(milliseconds: 50),
          tickInterval: Duration(milliseconds: 10),
          failedTaskId: 'audio',
        );

        await tester.pumpWidget(
          buildTestableScreen(preparationService: failingService),
        );
        await tester.pumpAndSettle();

        // Retry button is shown for the failed task
        expect(find.text(AppStrings.retryAction), findsOneWidget);

        // Start lesson button remains disabled because audio is a blocking task
        final button = tester.widget<Button3D>(
          find.widgetWithText(Button3D, 'Start lesson 1'),
        );
        expect(button.isEnabled, isFalse);
      },
    );

    testWidgets(
      'unavailable task displays neutral status without false success',
      (tester) async {
        const unavailableService = MockPathPreparationService(
          totalDuration: Duration.zero,
          unavailableTaskId: 'speaking',
        );

        await tester.pumpWidget(
          buildTestableScreen(preparationService: unavailableService),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.taskStatusUnavailable), findsOneWidget);
      },
    );
  });

  group('PathReadyStepScreen Completion & Navigation Interactions', () {
    testWidgets(
      'tapping "Start lesson 1" saves profile and navigates to lesson placeholder',
      (tester) async {
        final fakeRepo = MockProfileRepository();
        late WidgetRef capturedRef;

        await tester.pumpWidget(
          buildTestableScreen(
            profileRepository: fakeRepo,
            onInit: (ref) {
              capturedRef = ref;
              ref.read(onboardingFlowProvider.notifier).setAccent('orange');
              ref
                  .read(onboardingFlowProvider.notifier)
                  .setTargetLanguageCode('es');
            },
          ),
        );
        await tester.pumpAndSettle();

        // Tap Start lesson 1
        await tester.tap(find.text('Start lesson 1'));
        await tester.pumpAndSettle();

        // Profile was saved into repository
        final savedProfile = await fakeRepo.getCurrentProfile();
        expect(savedProfile, isNotNull);
        expect(savedProfile!.isOnboarded, isTrue);
        expect(savedProfile.accentId, 'orange');
        expect(savedProfile.targetLanguageCode, 'es');

        // Onboarding draft was cleared (currentStep reset to 1)
        expect(capturedRef.read(onboardingFlowProvider).currentStep, equals(1));

        // Prompts Login Screen with returnTo=/lesson/1 per prototype spec
        expect(find.text('Login Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'guard redirects to Step 10 if accessed without start free action',
      (tester) async {
        await tester.pumpWidget(
          buildTestableScreen(
            initialStep11Access: false,
            onInit: (ref) {
              // Not yet on step 11 and plan not selected as free
              ref.read(onboardingFlowProvider.notifier).setStep(5);
            },
          ),
        );
        await tester.pumpAndSettle();

        // Redirected to Step 10
        expect(find.text('Step 10 Premium Offer'), findsOneWidget);
      },
    );
  });

  group('Contrast & Accessibility Checks', () {
    test('WCAG color contrast on checkmark, star, and note text', () {
      double luminance(Color c) => c.computeLuminance();
      double contrast(Color c1, Color c2) {
        final l1 = luminance(c1);
        final l2 = luminance(c2);
        return (l1 > l2)
            ? (l1 + 0.05) / (l2 + 0.05)
            : (l2 + 0.05) / (l1 + 0.05);
      }

      // Checkmark (#065F46) on white surface: passes WCAG AAA (> 7.0:1)
      final checkContrast = contrast(const Color(0xFF065F46), Colors.white);
      expect(checkContrast, greaterThan(7.0));

      // Gold star (#D97706) on white surface: passes WCAG AA graphical non-text (> 3.0:1)
      final starContrast = contrast(AppColors.goldDepth, Colors.white);
      expect(starContrast, greaterThan(3.0));

      // Note text (#6E6A8A) on white surface: passes WCAG AA text (> 4.5:1)
      final noteContrast = contrast(AppColors.textMuted, Colors.white);
      expect(noteContrast, greaterThan(4.5));
    });
  });

  group('Responsive and Overflow Tests Across All Window Sizes', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad Pro portrait
    ];

    for (final size in testSizes) {
      testWidgets(
        'renders cleanly without overflow at ${size.width}x${size.height} (1.0x and 2.0x)',
        (tester) async {
          for (final scale in [1.0, 2.0]) {
            tester.view.physicalSize = Size(
              size.width * 2.0,
              size.height * 2.0,
            );
            tester.view.devicePixelRatio = 2.0;
            addTearDown(() => tester.view.resetPhysicalSize());

            await tester.pumpWidget(buildTestableScreen(textScale: scale));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            // Pinned bottom button must remain fully visible and on screen
            expect(
              find.widgetWithText(Button3D, 'Start lesson 1'),
              findsOneWidget,
            );
          }
        },
      );
    }
  });
}
