import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/difficulty_pips.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/learn_language_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/coming_soon_badge.dart';
import 'package:peddi/features/onboarding/presentation/widgets/learn_language_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_title_block.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('LearnLanguageStepScreen Widget & State Tests', () {
    late FakeSpeechService fakeTts;

    setUp(() {
      fakeTts = FakeSpeechService();
    });

    Widget createScreen({
      String? initialCode,
      VoidCallback? onContinue,
      VoidCallback? onBack,
      ProviderContainer? container,
    }) {
      final scope = container != null
          ? UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: AppTheme.light(),
                home: LearnLanguageStepScreen(
                  initialCode: initialCode,
                  onContinue: onContinue,
                  onBack: onBack,
                ),
              ),
            )
          : ProviderScope(
              overrides: [
                textToSpeechServiceProvider.overrideWithValue(fakeTts),
              ],
              child: MaterialApp(
                theme: AppTheme.light(),
                home: LearnLanguageStepScreen(
                  initialCode: initialCode,
                  onContinue: onContinue,
                  onBack: onBack,
                ),
              ),
            );

      return scope;
    }

    testWidgets('renders header, title, cards, and default Español selection', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // 1. Header (4/11) and Title
      expect(find.byType(StepProgressHeader), findsOneWidget);
      expect(find.text('4/11'), findsOneWidget);
      expect(find.byType(StepTitleBlock), findsOneWidget);
      expect(find.byType(PebbiMascot), findsOneWidget);
      expect(find.text(AppStrings.iWantToLearnTitle), findsOneWidget);
      expect(find.text(AppStrings.iWantToLearnSubtitle), findsOneWidget);

      // 2. 10 language cards total (5 available, 5 coming soon)
      expect(find.byType(LearnLanguageCard), findsNWidgets(10));
      expect(find.byType(DifficultyPips), findsNWidgets(5));
      expect(find.byType(ComingSoonBadge), findsNWidgets(5));

      // 3. Check icon visible on Español (default)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // 4. Continue button is enabled
      expect(find.byType(StepFooterButton), findsOneWidget);
      expect(find.text(AppStrings.continueAction), findsOneWidget);

      // 5. No sound played automatically on screen load
      expect(fakeTts.lastSpokenText, isNull);
      expect(fakeTts.spokenHistory, isEmpty);
    });

    testWidgets(
      'tapping available card selects it and plays hello via speech service',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Tap Français card
        await tester.tap(find.text('Français'));
        await tester.pumpAndSettle();

        // Speech called with French hello
        expect(fakeTts.lastSpokenText, equals('Bonjour !'));
        expect(fakeTts.lastLocale, equals('fr-FR'));
        expect(fakeTts.spokenHistory.length, equals(1));

        // Tap Deutsch card
        await tester.tap(find.text('Deutsch'));
        await tester.pumpAndSettle();

        // Previous stopped and German played
        expect(fakeTts.lastSpokenText, equals('Hallo!'));
        expect(fakeTts.lastLocale, equals('de-DE'));
        expect(fakeTts.spokenHistory.length, equals(2));
      },
    );

    testWidgets(
      'tapping coming soon card does not change selection and plays nothing',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Tap Hindi (Coming Soon)
        await tester.tap(find.text('हिन्दी'));
        await tester.pumpAndSettle();

        // No audio played
        expect(fakeTts.lastSpokenText, isNull);
        expect(fakeTts.spokenHistory, isEmpty);

        // Feedback snackbar shown
        expect(find.text(AppStrings.comingSoonFeedback), findsOneWidget);
      },
    );

    testWidgets(
      'Continue saves targetLanguageCode to state and invokes callback',
      (tester) async {
        final container = ProviderContainer(
          overrides: [textToSpeechServiceProvider.overrideWithValue(fakeTts)],
        );
        var continueCalled = false;

        await tester.pumpWidget(
          createScreen(
            container: container,
            onContinue: () => continueCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        // Select Japanese
        await tester.tap(find.text('日本語'));
        await tester.pumpAndSettle();

        // Tap Continue
        await tester.tap(find.text(AppStrings.continueAction));
        await tester.pumpAndSettle();

        expect(continueCalled, isTrue);

        final state = container.read(onboardingFlowProvider);
        expect(state.targetLanguageCode, equals('ja'));
        expect(state.currentStep, equals(4));
      },
    );

    testWidgets('cards have accessible semantics', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Español selected label
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (w) => w is LearnLanguageCard && w.language.code == 'es',
          ),
        ),
        matchesSemantics(
          label: 'Español, Spanish, difficulty 1 of 3, 42M learners, selected',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      // Hindi coming soon label
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (w) => w is LearnLanguageCard && w.language.code == 'hi',
          ),
        ),
        matchesSemantics(
          label: 'Hindi, coming soon, not available',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });
  });

  group('LearnLanguageStepScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad portrait
      Size(700, 900), // Foldable / split screen
    ];

    for (final size in testSizes) {
      testWidgets('renders without overflow at ${size.width}x${size.height}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textToSpeechServiceProvider.overrideWithValue(
                FakeSpeechService(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const LearnLanguageStepScreen(initialCode: 'de'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LearnLanguageStepScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('renders cleanly with 200% text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: LearnLanguageStepScreen(initialCode: 'es'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LearnLanguageStepScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
