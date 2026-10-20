import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/accent_swatch.dart';
import 'package:peddi/core/design_system/accent_swatch_row.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/meet_pebbi_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/hello_pill.dart';
import 'package:peddi/features/onboarding/presentation/widgets/pebbi_hero.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/sticker_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/sticker_row.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    GoRouter? router,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    FakeSpeechService? fakeTts,
    String? initialTargetLanguageCode,
  }) {
    final effectiveTts = fakeTts ?? FakeSpeechService();
    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/onboarding/setup/step-9',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-9',
              builder: (context, state) => const MeetPebbiStepScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-10',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 10 Offer Placeholder')),
            ),
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 8 Reminder Screen')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [textToSpeechServiceProvider.overrideWithValue(effectiveTts)],
      child: Consumer(
        builder: (context, ref, child) {
          if (initialTargetLanguageCode != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(onboardingFlowProvider.notifier)
                  .setTargetLanguageCode(initialTargetLanguageCode);
            });
          }

          final accent = ref.watch(accentColorProvider);

          return MaterialApp.router(
            theme: AppTheme.light(accent),
            darkTheme: AppTheme.dark(accent),
            themeMode: themeMode,
            routerConfig: effectiveRouter,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  group('MeetPebbiStepScreen UI & Interaction Tests', () {
    testWidgets(
      'Renders header 9/11 (9/11 fill), hero mascot, 6 swatches with violet selected, 3 sticker cards with none selected, hello pill, and Continue button',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // 1. Header
        expect(find.text('9/11'), findsOneWidget);
        final headerFinder = find.byType(StepProgressHeader);
        expect(headerFinder, findsOneWidget);
        final header = tester.widget<StepProgressHeader>(headerFinder);
        expect(header.currentStep, 9);
        expect(header.totalSteps, 11);

        // 2. Title & Subtitle
        expect(find.text(AppStrings.meetPebbiTitle), findsOneWidget);
        expect(find.text(AppStrings.meetPebbiSubtitle), findsOneWidget);

        // 3. Hero mascot
        expect(find.byType(PebbiHero), findsOneWidget);
        final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
        expect(mascot.expression, PebbiExpression.happyClosed);
        expect(mascot.accentColor, AppColors.accentViolet);

        // 4. Accent swatches
        expect(find.byType(AccentSwatchRow), findsOneWidget);
        expect(find.byType(AccentSwatch), findsNWidgets(6));
        final swatches = tester
            .widgetList<AccentSwatch>(find.byType(AccentSwatch))
            .toList();
        expect(swatches[0].name, 'Violet');
        expect(swatches[0].isSelected, isTrue);
        expect(swatches[1].name, 'Green');
        expect(swatches[1].isSelected, isFalse);

        // 5. Sticker cards
        expect(find.byType(StickerRow), findsOneWidget);
        expect(find.byType(StickerCard), findsNWidgets(3));
        expect(find.text('First hello'), findsOneWidget);
        expect(find.text('Little spark'), findsOneWidget);
        expect(find.text('Well said'), findsOneWidget);
        final stickerCards = tester
            .widgetList<StickerCard>(find.byType(StickerCard))
            .toList();
        for (final card in stickerCards) {
          expect(card.isSelected, isFalse);
        }

        // 6. Hello Pill & caption
        expect(find.byType(HelloPill), findsOneWidget);
        expect(find.text('¡Hola!'), findsOneWidget);
        expect(find.text('Your first Spanish sentence'), findsOneWidget);

        // 7. Continue button
        expect(find.text(AppStrings.continueAction), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping an accent swatch updates selected state, mascot color, and app settings',
      (tester) async {
        late WidgetRef capturedRef;
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                final accent = ref.watch(accentColorProvider);
                return MaterialApp.router(
                  theme: AppTheme.light(accent),
                  routerConfig: GoRouter(
                    initialLocation: '/onboarding/setup/step-9',
                    routes: [
                      GoRoute(
                        path: '/onboarding/setup/step-9',
                        builder: (context, state) =>
                            const MeetPebbiStepScreen(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap green swatch (2nd swatch)
        final greenSwatchFinder = find.byWidgetPredicate(
          (w) => w is AccentSwatch && w.name == 'Green',
        );
        await tester.tap(greenSwatchFinder);
        await tester.pumpAndSettle();

        // Green swatch is now selected
        final greenSwatch = tester.widget<AccentSwatch>(greenSwatchFinder);
        expect(greenSwatch.isSelected, isTrue);

        // State updated
        expect(capturedRef.read(onboardingFlowProvider).accentId, 'green');
        expect(capturedRef.read(appSettingsProvider).accentId, 'green');

        // Mascot accent matches green
        final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
        expect(mascot.accentColor, AppColors.accentGreen);
      },
    );

    testWidgets(
      'Tapping a sticker card selects it; tapping another changes selection; tapping it again deselects',
      (tester) async {
        late WidgetRef capturedRef;
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: GoRouter(
                    initialLocation: '/onboarding/setup/step-9',
                    routes: [
                      GoRoute(
                        path: '/onboarding/setup/step-9',
                        builder: (context, state) =>
                            const MeetPebbiStepScreen(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initially null
        expect(capturedRef.read(onboardingFlowProvider).firstStickerId, isNull);

        // 2. Scroll into view and tap "First hello" (wave)
        final waveText = find.text('First hello');
        await tester.ensureVisible(waveText);
        await tester.tap(waveText);
        await tester.pumpAndSettle();
        expect(capturedRef.read(onboardingFlowProvider).firstStickerId, 'wave');

        final waveCardFinder = find.byWidgetPredicate(
          (w) => w is StickerCard && w.sticker.id == 'wave',
        );
        expect(tester.widget<StickerCard>(waveCardFinder).isSelected, isTrue);

        // 3. Tap "Well said" (wellsaid) -> single-select switches
        final wellsaidText = find.text('Well said');
        await tester.ensureVisible(wellsaidText);
        await tester.tap(wellsaidText);
        await tester.pumpAndSettle();
        expect(
          capturedRef.read(onboardingFlowProvider).firstStickerId,
          'wellsaid',
        );
        expect(tester.widget<StickerCard>(waveCardFinder).isSelected, isFalse);
        final wellsaidCardFinder = find.byWidgetPredicate(
          (w) => w is StickerCard && w.sticker.id == 'wellsaid',
        );
        expect(
          tester.widget<StickerCard>(wellsaidCardFinder).isSelected,
          isTrue,
        );

        // 4. Tap "Well said" again -> deselects to null
        await tester.tap(wellsaidText);
        await tester.pumpAndSettle();
        expect(capturedRef.read(onboardingFlowProvider).firstStickerId, isNull);
        expect(
          tester.widget<StickerCard>(wellsaidCardFinder).isSelected,
          isFalse,
        );
      },
    );

    testWidgets(
      'Continue button is enabled with NO sticker selected and advances to Step 10',
      (tester) async {
        late WidgetRef capturedRef;
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: GoRouter(
                    initialLocation: '/onboarding/setup/step-9',
                    routes: [
                      GoRoute(
                        path: '/onboarding/setup/step-9',
                        builder: (context, state) =>
                            const MeetPebbiStepScreen(),
                      ),
                      GoRoute(
                        path: '/onboarding/setup/step-10',
                        builder: (context, state) =>
                            const Scaffold(body: Text('Step 10 Target')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.continueAction), findsOneWidget);
        await tester.tap(find.text(AppStrings.continueAction));
        await tester.pumpAndSettle();

        expect(find.text('Step 10 Target'), findsOneWidget);
        expect(capturedRef.read(onboardingFlowProvider).currentStep, 10);
      },
    );

    testWidgets(
      'Hello pill does not autoplay on open, but speaks target language phrase on tap',
      (tester) async {
        final fakeTts = FakeSpeechService();
        await tester.pumpWidget(buildTestableScreen(fakeTts: fakeTts));
        await tester.pumpAndSettle();

        // 1. Did NOT autoplay
        expect(fakeTts.spokenHistory, isEmpty);

        // 2. Tap pill button
        await tester.tap(find.text('¡Hola!'));
        await tester.pumpAndSettle();

        // 3. Spoke '¡Hola!' with locale 'es-ES'
        expect(fakeTts.spokenHistory.length, 1);
        expect(fakeTts.spokenHistory.first.text, '¡Hola!');
        expect(fakeTts.spokenHistory.first.locale, 'es-ES');
      },
    );

    testWidgets(
      'Hello pill respects sound setting: does not speak when sound is disabled',
      (tester) async {
        final fakeTts = FakeSpeechService();
        late WidgetRef capturedRef;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [textToSpeechServiceProvider.overrideWithValue(fakeTts)],
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: GoRouter(
                    initialLocation: '/onboarding/setup/step-9',
                    routes: [
                      GoRoute(
                        path: '/onboarding/setup/step-9',
                        builder: (context, state) =>
                            const MeetPebbiStepScreen(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Disable sound in settings
        capturedRef.read(appSettingsProvider.notifier).setSoundEnabled(false);
        await tester.pumpAndSettle();

        // Tap pill button
        await tester.tap(find.text('¡Hola!'));
        await tester.pumpAndSettle();

        // Did not speak
        expect(fakeTts.spokenHistory, isEmpty);
      },
    );

    testWidgets(
      'Hello pill adapts caption and phrase when target language is French',
      (tester) async {
        final fakeTts = FakeSpeechService();
        await tester.pumpWidget(
          buildTestableScreen(
            fakeTts: fakeTts,
            initialTargetLanguageCode: 'fr',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Bonjour !'), findsOneWidget);
        expect(find.text('Your first French sentence'), findsOneWidget);

        await tester.tap(find.text('Bonjour !'));
        await tester.pumpAndSettle();

        expect(fakeTts.spokenHistory.first.text, 'Bonjour !');
        expect(fakeTts.spokenHistory.first.locale, 'fr-FR');
      },
    );

    testWidgets('Selection survives forward and back navigation', (
      tester,
    ) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              return MaterialApp.router(
                theme: AppTheme.light(),
                routerConfig: GoRouter(
                  initialLocation: '/onboarding/setup/step-9',
                  routes: [
                    GoRoute(
                      path: '/onboarding/setup/step-9',
                      builder: (context, state) => const MeetPebbiStepScreen(),
                    ),
                    GoRoute(
                      path: '/onboarding/setup/step-10',
                      builder: (context, state) => Scaffold(
                        body: ElevatedButton(
                          onPressed: () =>
                              context.go('/onboarding/setup/step-9'),
                          child: const Text('Back to 9'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pick Blue accent and Sparkle sticker
      final blueSwatchFinder = find.byWidgetPredicate(
        (w) => w is AccentSwatch && w.name == 'Blue',
      );
      await tester.scrollUntilVisible(blueSwatchFinder, 100);
      await tester.tap(blueSwatchFinder);
      await tester.pumpAndSettle();

      final sparkleText = find.text('Little spark');
      await tester.scrollUntilVisible(sparkleText, 100);
      await tester.tap(sparkleText);
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text(AppStrings.continueAction));
      await tester.pumpAndSettle();
      expect(find.text('Back to 9'), findsOneWidget);

      // Return to 9
      await tester.tap(find.text('Back to 9'));
      await tester.pumpAndSettle();

      // Choices survived
      expect(capturedRef.read(onboardingFlowProvider).accentId, 'blue');
      expect(
        capturedRef.read(onboardingFlowProvider).firstStickerId,
        'sparkle',
      );
      expect(tester.widget<AccentSwatch>(blueSwatchFinder).isSelected, isTrue);
      final sparkleCardFinder = find.byWidgetPredicate(
        (w) => w is StickerCard && w.sticker.id == 'sparkle',
      );
      expect(tester.widget<StickerCard>(sparkleCardFinder).isSelected, isTrue);
    });
  });

  group('MeetPebbiStepScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet, portrait
      Size(1280, 800), // Android tablet, landscape
      Size(1024, 1366), // iPad Pro
      Size(700, 400), // Short landscape window
    ];

    for (final size in testSizes) {
      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 1.0x & 2.0x scale (button always visible)',
        (tester) async {
          for (final scale in [1.0, 2.0]) {
            tester.view.physicalSize = size * 2.0;
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(buildTestableScreen(textScale: scale));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            // Continue button must always be visible and tappable
            expect(find.text(AppStrings.continueAction), findsOneWidget);
            await tester.tap(find.text(AppStrings.continueAction));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  });
}
