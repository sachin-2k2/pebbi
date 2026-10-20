import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_settings_provider.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_result_screen.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/answer_option_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/audio_play_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/check_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/choose_meaning_body.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exercise_bottom_bar.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exercise_header.dart';
import 'package:peddi/core/design_system/tip_pill.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exercise_prompt.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exit_confirm_sheet.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/feedback_panel.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/hear_it_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/hint_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/phrase_text.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/picture_option_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/picture_option_grid.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/sentence/answer_area.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/sentence/build_sentence_body.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/sentence/prompt_bubble.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/sentence/word_bank.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/sentence/word_tile.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/why_link.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/why_sheet.dart';
import 'package:peddi/features/settings/domain/lesson_settings.dart';

import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('ExerciseScreen Visual States & Flow Tests (Screenshots 1-4)', () {
    late FakeSpeechService fakeSpeech;
    late FakeAudioFeedbackService fakeAudio;

    setUp(() {
      fakeSpeech = FakeSpeechService();
      fakeAudio = FakeAudioFeedbackService();
    });

    Widget createScreen({
      ThemeData? theme,
      VoidCallback? onCompleted,
      LessonSettings? settings,
    }) {
      return ProviderScope(
        overrides: [
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
          audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
          if (settings != null)
            lessonSettingsProvider.overrideWith((ref) => settings),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: ExerciseScreen(onCompleted: onCompleted),
        ),
      );
    }

    testWidgets(
      'State 1: Nothing selected (Idle) - Check disabled flat pale lavender',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Header: X, Progress bar, counter 1/8
        expect(find.byType(ExerciseHeader), findsOneWidget);
        expect(find.text('1/8'), findsOneWidget);

        // Prompt area
        expect(find.byType(ExercisePrompt), findsOneWidget);
        expect(find.text(AppStrings.pickThePictureTitle), findsOneWidget);
        expect(find.text('A ticket to Madrid, please'), findsOneWidget);
        expect(find.byType(HearItButton), findsOneWidget);

        // 4 Picture cards in 2x2 grid
        expect(find.byType(PictureOptionGrid), findsOneWidget);
        expect(find.byType(PictureOptionCard), findsNWidgets(4));
        expect(find.text('🎫'), findsOneWidget);
        expect(find.text('🌙'), findsOneWidget);
        expect(find.text('😊'), findsOneWidget);
        expect(find.text('❓'), findsOneWidget);

        // Bottom bar with Hint and flat disabled Check
        expect(find.byType(ExerciseBottomBar), findsOneWidget);
        expect(find.byType(HintButton), findsOneWidget);
        expect(find.byType(CheckButton), findsOneWidget);
        expect(find.text(AppStrings.check), findsOneWidget);

        // Disabled state semantics
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'State 2: Option selected - Lavender fill, purple border, Mint Check Button3D',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Tap ticket option
        await tester.tap(find.text('🎫'));
        await tester.pumpAndSettle();

        // Ticket option is selected
        final selectedCardFinder = find.byWidgetPredicate(
          (w) =>
              w is PictureOptionCard &&
              w.option.id == 'opt_ticket' &&
              w.isSelected,
        );
        expect(selectedCardFinder, findsOneWidget);

        // Check button is now an enabled Button3D with mint color
        final checkButton3D = find.descendant(
          of: find.byType(CheckButton),
          matching: find.byWidgetPredicate(
            (w) => w is Button3D && w.backgroundColor == AppColors.mint,
          ),
        );
        expect(checkButton3D, findsOneWidget);
      },
    );

    testWidgets(
      'State 3: Correct feedback panel slides up with mint background, happy mascot, and mint Continue',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Select correct answer (ticket)
        await tester.tap(find.text('🎫'));
        await tester.pumpAndSettle();

        // Tap Check
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        // Bottom bar replaced by FeedbackPanel
        expect(find.byType(ExerciseBottomBar), findsNothing);
        expect(find.byType(FeedbackPanel), findsOneWidget);

        // Correct header: ✓ Nice one! and Happy mascot
        expect(find.text(AppStrings.feedbackCorrectTitle), findsOneWidget);
        final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
        expect(mascot.expression, equals(PebbiExpression.happy));

        // Body text from data
        expect(
          find.text(
            '“Un billete a Madrid, por favor” means A ticket to Madrid, please',
          ),
          findsOneWidget,
        );

        // "Why?" text link and Mint Continue button
        expect(find.byType(WhyLink), findsOneWidget);
        final continueButton = find.byWidgetPredicate(
          (w) =>
              w is Button3D &&
              w.label == AppStrings.continueExercise &&
              w.backgroundColor == AppColors.mint,
        );
        expect(continueButton, findsOneWidget);
      },
    );

    testWidgets(
      'State 4: Wrong feedback panel slides up with rose background, sad mascot, and purple Continue',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Select wrong answer (moon)
        await tester.tap(find.text('🌙'));
        await tester.pumpAndSettle();

        // Tap Check
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        expect(find.byType(FeedbackPanel), findsOneWidget);

        // Wrong header: ✕ Not quite — you're learning! and Sad mascot
        expect(find.text(AppStrings.feedbackWrongTitle), findsOneWidget);
        final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
        expect(mascot.expression, equals(PebbiExpression.sad));

        // Correct answer text & redo notice
        expect(
          find.text('Correct answer: Un billete a Madrid, por favor'),
          findsOneWidget,
        );
        expect(find.text(AppStrings.feedbackRedoNotice), findsOneWidget);

        // "Why?" link and PURPLE Continue button (specifically purple for wrong)
        expect(find.byType(WhyLink), findsOneWidget);
        final continueButton = find.byWidgetPredicate(
          (w) =>
              w is Button3D &&
              w.label == AppStrings.continueExercise &&
              w.backgroundColor == AppColors.brandPurple,
        );
        expect(continueButton, findsOneWidget);
      },
    );

    testWidgets(
      '"Hear it" button calls TextToSpeechService with phrase and locale',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.hearIt));
        await tester.pumpAndSettle();

        expect(
          fakeSpeech.lastSpokenText,
          equals('Un billete a Madrid, por favor'),
        );
        expect(fakeSpeech.lastLocale, equals('es-ES'));
      },
    );

    testWidgets(
      '"Hint" removes a distractor card and keeps correct & selected cards',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // 4 cards visible initially
        expect(find.byType(PictureOptionCard), findsNWidgets(4));

        // Tap Hint
        await tester.tap(find.text(AppStrings.hint));
        await tester.pumpAndSettle();

        // 1 card removed (rendered as SizedBox.shrink)
        final visibleCards = find.byWidgetPredicate(
          (w) => w is PictureOptionCard && !w.isRemoved,
        );
        expect(visibleCards, findsNWidgets(3));

        // Ticket (correct) is still visible
        expect(find.text('🎫'), findsOneWidget);
      },
    );

    testWidgets('"Why?" opens AdaptiveSheet with explanation text', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Select ticket & check
      await tester.tap(find.text('🎫'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();

      // Tap Why?
      await tester.tap(find.text(AppStrings.why));
      await tester.pumpAndSettle();

      // WhySheet is open
      expect(find.byType(WhySheet), findsOneWidget);
      expect(find.text(AppStrings.whySheetTitle), findsOneWidget);
      expect(
        find.textContaining('“Un billete” is used specifically in Spain'),
        findsOneWidget,
      );
    });

    testWidgets('X button opens ExitConfirmSheet and asks for confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Tap close (X)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // ExitConfirmSheet is open
      expect(find.byType(ExitConfirmSheet), findsOneWidget);
      expect(find.text(AppStrings.exitConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.exitConfirmBody), findsOneWidget);

      // Tap Stay
      await tester.tap(find.text(AppStrings.exitConfirmStay));
      await tester.pumpAndSettle();

      // Stays on ExerciseScreen
      expect(find.byType(ExitConfirmSheet), findsNothing);
      expect(find.byType(ExerciseScreen), findsOneWidget);
    });

    testWidgets(
      'Tapping Continue after correct answer advances to question 2',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Answer question 1
        await tester.tap(find.text('🎫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        // Tap Continue
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Advances to Question 2 ("Good morning")
        expect(find.text('2/8'), findsOneWidget);
        expect(find.text('Good morning'), findsOneWidget);
      },
    );
  });

  group('ExerciseScreen Router Navigation & Completion Tests', () {
    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/onboarding/placement-quiz',
        routes: [
          GoRoute(
            path: '/onboarding/placement-quiz',
            builder: (context, state) => const ExerciseScreen(),
          ),
          GoRoute(
            path: '/onboarding/placement-results',
            builder: (context, state) => const PlacementResultScreen(),
          ),
        ],
      );
    }

    testWidgets(
      'Finishing all questions navigates to placement results placeholder',
      (tester) async {
        final router = createTestRouter();
        final fakeSpeech = FakeSpeechService();
        final fakeAudio = FakeAudioFeedbackService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
              audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light(),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Step through all 8 questions
        for (int i = 0; i < 8; i++) {
          final pictureOptions = find.byType(PictureOptionCard);
          final textOptions = find.byType(AnswerOptionCard);
          final wordTiles = find.byType(WordTile);
          if (pictureOptions.evaluate().isNotEmpty) {
            await tester.tap(pictureOptions.first);
          } else if (textOptions.evaluate().isNotEmpty) {
            await tester.tap(textOptions.first);
          } else if (wordTiles.evaluate().isNotEmpty) {
            await tester.tap(wordTiles.first);
          }
          await tester.pumpAndSettle();

          // Tap Check
          await tester.tap(find.text(AppStrings.check));
          await tester.pumpAndSettle();

          // Tap Continue
          await tester.tap(find.text(AppStrings.continueExercise));
          await tester.pumpAndSettle();
        }

        // If any wrong answers occurred in redo, step through redo as well
        while (find.byType(ExerciseScreen).evaluate().isNotEmpty) {
          final pictureOptions = find.byType(PictureOptionCard);
          final textOptions = find.byType(AnswerOptionCard);
          final wordTiles = find.byType(WordTile);
          if (pictureOptions.evaluate().isNotEmpty) {
            await tester.tap(pictureOptions.first);
          } else if (textOptions.evaluate().isNotEmpty) {
            await tester.tap(textOptions.first);
          } else if (wordTiles.evaluate().isNotEmpty) {
            await tester.tap(wordTiles.first);
          } else {
            break;
          }
          await tester.pumpAndSettle();
          await tester.tap(find.text(AppStrings.check));
          await tester.pumpAndSettle();
          await tester.tap(find.text(AppStrings.continueExercise));
          await tester.pumpAndSettle();
        }

        // Navigated to PlacementResultScreen
        expect(find.byType(PlacementResultScreen), findsOneWidget);
        expect(find.text(AppStrings.startFromHere), findsOneWidget);
      },
    );
  });

  group('ExerciseScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad Pro portrait
      Size(700, 900), // Foldable / split screen
    ];

    for (final size in testSizes) {
      testWidgets(
        'renders cleanly without overflow at ${size.width}x${size.height}',
        (tester) async {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                textToSpeechServiceProvider.overrideWithValue(
                  FakeSpeechService(),
                ),
                audioFeedbackServiceProvider.overrideWithValue(
                  FakeAudioFeedbackService(),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.light(),
                home: const ExerciseScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(ExerciseScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'renders cleanly with 200% text scale in both feedback states without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textToSpeechServiceProvider.overrideWithValue(
                FakeSpeechService(),
              ),
              audioFeedbackServiceProvider.overrideWithValue(
                FakeAudioFeedbackService(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
                child: ExerciseScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ExerciseScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Select & check to test feedback panel at 200% scale
        await tester.tap(find.text('🎫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        expect(find.byType(FeedbackPanel), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('renders cleanly in dark mode without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
            audioFeedbackServiceProvider.overrideWithValue(
              FakeAudioFeedbackService(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const ExerciseScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ChooseMeaningExercise Widget Tests (Questions 4, 5, 6)', () {
    late FakeSpeechService fakeSpeech;
    late FakeAudioFeedbackService fakeAudio;

    setUp(() {
      fakeSpeech = FakeSpeechService();
      fakeAudio = FakeAudioFeedbackService();
    });

    Widget createScreen({
      ThemeData? theme,
      VoidCallback? onCompleted,
      LessonSettings? settings,
    }) {
      return ProviderScope(
        overrides: [
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
          audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
          if (settings != null)
            lessonSettingsProvider.overrideWith((ref) => settings),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: ExerciseScreen(onCompleted: onCompleted),
        ),
      );
    }

    Future<void> advanceToQuestion4(WidgetTester tester) async {
      // Q1: ticket
      await tester.tap(find.text('🎫'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q2: sun
      await tester.tap(find.text('☀️'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q3 (temporary coffee)
      await tester.tap(find.text('☕'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Question 4 Idle state: counter 4/8, title, purple audio button, phrase, 3 cards, Check disabled',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion4(tester);

        // Header: counter 4/8
        expect(find.text('4/8'), findsOneWidget);

        // Title and body components
        expect(find.text(AppStrings.whatDoesThisMean), findsOneWidget);
        expect(find.byType(AudioPlayButton), findsOneWidget);
        expect(find.text('Soy de México'), findsOneWidget);

        // 3 Answer options
        expect(find.byType(AnswerOptionCard), findsNWidgets(3));
        expect(find.text('How much does it cost?'), findsOneWidget);
        expect(find.text('Sparkling water'), findsOneWidget);
        expect(find.text("I'm from Mexico"), findsOneWidget);

        // Check button is flat pale lavender and disabled
        expect(find.text(AppStrings.check), findsOneWidget);
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );

        // Hint button is available
        expect(find.byType(HintButton), findsOneWidget);

        // Listen-first check: no audio played on open unless Autoplay is on
        expect(fakeSpeech.spokenHistory, isEmpty);
      },
    );

    testWidgets('Question 4 selecting an answer enables Check button', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();
      await advanceToQuestion4(tester);

      // Select Option 3 ("I'm from Mexico")
      await tester.tap(find.text("I'm from Mexico"));
      await tester.pumpAndSettle();

      // Check button is now enabled
      expect(
        find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
        findsNothing,
      );
      expect(find.text(AppStrings.check), findsOneWidget);
    });

    testWidgets(
      'Question 4 correct feedback panel slides up with mint background & advances to Q5',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion4(tester);

        // Select correct answer and check
        await tester.tap(find.text("I'm from Mexico"));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        // Feedback panel with happy mascot and correct title
        expect(find.byType(FeedbackPanel), findsOneWidget);
        expect(find.text(AppStrings.feedbackCorrectTitle), findsOneWidget);
        expect(find.byType(WhyLink), findsOneWidget);

        // Tap Continue -> advances to Question 5
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        expect(find.text('5/8'), findsOneWidget);
        expect(find.text('¿Cuánto cuesta?'), findsOneWidget);
      },
    );

    testWidgets(
      'Question 4 wrong feedback panel slides up with rose background & purple Continue',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion4(tester);

        // Select wrong answer ("Sparkling water") and check
        await tester.tap(find.text('Sparkling water'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        // Wrong feedback panel
        expect(find.byType(FeedbackPanel), findsOneWidget);
        expect(find.text(AppStrings.feedbackWrongTitle), findsOneWidget);
        expect(
          find.text(AppStrings.feedbackCorrectAnswer("I'm from Mexico")),
          findsOneWidget,
        );
        expect(find.text(AppStrings.feedbackRedoNotice), findsOneWidget);

        // Continue button has Purple background
        final continueBtn = tester.widget<Button3D>(
          find.descendant(
            of: find.byType(FeedbackPanel),
            matching: find.byType(Button3D),
          ),
        );
        expect(continueBtn.backgroundColor, equals(AppColors.brandPurple));
      },
    );

    testWidgets(
      'AudioPlayButton calls speech service with phrase and locale, and replays on second tap',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion4(tester);

        // Tap purple audio button
        await tester.tap(find.byType(AudioPlayButton));
        await tester.pump();

        expect(fakeSpeech.lastSpokenText, equals('Soy de México'));
        expect(fakeSpeech.lastLocale, equals('es-ES'));
        expect(fakeSpeech.spokenHistory.length, equals(1));

        // Tap again to replay from start
        await tester.tap(find.byType(AudioPlayButton));
        await tester.pump();

        expect(fakeSpeech.spokenHistory.length, equals(2));
        expect(fakeSpeech.lastSpokenText, equals('Soy de México'));
      },
    );

    testWidgets(
      'Hint button removes 1 wrong answer and disables on Question 4',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion4(tester);

        // Select correct answer
        await tester.tap(find.text("I'm from Mexico"));
        await tester.pumpAndSettle();

        // Tap Hint
        await tester.tap(find.byType(HintButton));
        await tester.pumpAndSettle();

        // Correct option "I'm from Mexico" is still visible
        // Hint button is now disabled (only 2 active cards remain)
        final hintButton = tester.widget<HintButton>(find.byType(HintButton));
        expect(hintButton.isEnabled, isFalse);
        expect(
          find.bySemanticsLabel(AppStrings.hintDisabledSemantics),
          findsOneWidget,
        );
      },
    );

    testWidgets('Helper line displays under phrase when setting is enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        createScreen(settings: const LessonSettings(showHelperLine: true)),
      );
      await tester.pumpAndSettle();

      await advanceToQuestion4(tester);
      expect(find.byType(PhraseText), findsOneWidget);
    });

    testWidgets(
      'Full flow Q1 -> Q2 -> temporary Q3 -> Q4 -> Q5 -> Q6 maintains correct progress and clean resets',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Q1
        expect(find.text('1/8'), findsOneWidget);
        await tester.tap(find.text('🎫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Q2
        expect(find.text('2/8'), findsOneWidget);
        await tester.tap(find.text('☀️'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Q3 (temporary)
        expect(find.text('3/8'), findsOneWidget);
        await tester.tap(find.text('☕'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Q4 (Choose meaning: "Soy de México")
        expect(find.text('4/8'), findsOneWidget);
        expect(find.text('Soy de México'), findsOneWidget);
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );
        await tester.tap(find.text("I'm from Mexico"));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Q5 (Choose meaning: "¿Cuánto cuesta?")
        expect(find.text('5/8'), findsOneWidget);
        expect(find.text('¿Cuánto cuesta?'), findsOneWidget);
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );
        await tester.tap(find.text('How much does it cost?'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Q6 (Choose meaning: "Un café, por favor")
        expect(find.text('6/8'), findsOneWidget);
        expect(find.text('Un café, por favor'), findsOneWidget);
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );
        await tester.tap(find.text('A coffee, please'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Advances to Q7
        expect(find.text('7/8'), findsOneWidget);
      },
    );

    testWidgets(
      'Question 4 renders cleanly at 200% text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textToSpeechServiceProvider.overrideWithValue(
                FakeSpeechService(),
              ),
              audioFeedbackServiceProvider.overrideWithValue(
                FakeAudioFeedbackService(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
                child: ExerciseScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await advanceToQuestion4(tester);

        expect(find.byType(ChooseMeaningBody), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('BuildSentenceExercise Widget Tests (Questions 7, 8)', () {
    late FakeSpeechService fakeSpeech;
    late FakeAudioFeedbackService fakeAudio;

    setUp(() {
      fakeSpeech = FakeSpeechService();
      fakeAudio = FakeAudioFeedbackService();
    });

    Widget createScreen({ThemeData? theme, VoidCallback? onCompleted}) {
      return ProviderScope(
        overrides: [
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
          audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: ExerciseScreen(onCompleted: onCompleted),
        ),
      );
    }

    Future<void> advanceToQuestion7(WidgetTester tester) async {
      Future<void> tapVisible(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      // Q1: ticket
      await tapVisible(find.text('🎫'));
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q2: sun
      await tapVisible(find.text('☀️'));
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q3 (coffee)
      await tapVisible(find.text('☕'));
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q4: "Soy de México" -> "I'm from Mexico"
      await tapVisible(find.text("I'm from Mexico"));
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q5: "¿Cuánto cuesta?" -> "How much does it cost?"
      await tapVisible(find.text("How much does it cost?"));
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Q6: "Un café, por favor" -> "A coffee, please"
      await tapVisible(find.text("A coffee, please"));
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Question 7 Idle state: counter 7/8, prompt Return ticket, empty answer area hint, 4 active word tiles, tip pill, Check disabled, NO hint button',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion7(tester);

        // Header: counter 7/8
        expect(find.text('7/8'), findsOneWidget);

        // Middle body components
        expect(find.byType(BuildSentenceBody), findsOneWidget);
        expect(find.byType(PromptBubble), findsOneWidget);
        expect(find.text('Return ticket'), findsOneWidget);
        expect(find.byType(PebbiMascot), findsWidgets);

        // Answer Area: empty with placeholder hint
        expect(find.byType(AnswerArea), findsOneWidget);
        expect(find.text(AppStrings.tapWordsInOrderHint), findsOneWidget);

        // Word Bank: 4 active word tiles in order ("A", "y", "Ida", "vuelta")
        expect(find.byType(WordBank), findsOneWidget);
        expect(
          find.byKey(const ValueKey('bank_active_q7_tile_a')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('bank_active_q7_tile_y')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('bank_active_q7_tile_ida')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('bank_active_q7_tile_vuelta')),
          findsOneWidget,
        );

        // Tip pill
        expect(find.byType(TipPill), findsOneWidget);
        expect(find.text(AppStrings.tilesFlyUpTip), findsOneWidget);

        // Bottom bar: Check button disabled, NO Hint button
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );
        expect(find.byType(Button3D), findsNothing);
        expect(find.text(AppStrings.hint), findsNothing);
      },
    );

    testWidgets(
      'Question 7 tile placement and removal toggles Check button and ghost placeholders',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion7(tester);

        // Tap "Ida" in bank
        await tester.tap(find.byKey(const ValueKey('bank_active_q7_tile_ida')));
        await tester.pumpAndSettle();

        // "Ida" is now placed in AnswerArea
        expect(
          find.byKey(const ValueKey('placed_q7_tile_ida')),
          findsOneWidget,
        );
        // Bank shows placeholder for "Ida"
        expect(
          find.byKey(const ValueKey('bank_placeholder_q7_tile_ida')),
          findsOneWidget,
        );
        // Hint text is gone from AnswerArea
        expect(find.text(AppStrings.tapWordsInOrderHint), findsNothing);

        // Check button is now enabled
        expect(find.byType(Button3D), findsOneWidget);

        // Tap "Ida" in AnswerArea to remove it
        await tester.tap(find.byKey(const ValueKey('placed_q7_tile_ida')));
        await tester.pumpAndSettle();

        // AnswerArea is empty again
        expect(find.byKey(const ValueKey('placed_q7_tile_ida')), findsNothing);
        expect(find.text(AppStrings.tapWordsInOrderHint), findsOneWidget);
        // Bank active tile for "Ida" is restored
        expect(
          find.byKey(const ValueKey('bank_active_q7_tile_ida')),
          findsOneWidget,
        );

        // Check button is disabled again
        expect(
          find.bySemanticsLabel(AppStrings.checkDisabledSemantics),
          findsOneWidget,
        );
        expect(find.byType(Button3D), findsNothing);
      },
    );

    testWidgets(
      'Question 7 correct feedback: placing Ida y vuelta in order shows mint feedback panel & locked tiles',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion7(tester);

        // Place "Ida", "y", "vuelta"
        await tester.tap(find.byKey(const ValueKey('bank_active_q7_tile_ida')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('bank_active_q7_tile_y')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('bank_active_q7_tile_vuelta')),
        );
        await tester.pumpAndSettle();

        // Tap Check
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        // Success panel appears
        expect(find.byType(FeedbackPanel), findsOneWidget);
        expect(find.text(AppStrings.feedbackCorrectTitle), findsOneWidget);
        expect(find.text('“Ida y vuelta” means Return ticket'), findsOneWidget);

        // Sound played
        expect(fakeAudio.successCount, greaterThan(0));
      },
    );

    testWidgets(
      'Question 7 wrong feedback: incorrect order shows rose panel and Why? sheet',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();
        await advanceToQuestion7(tester);

        // Place wrong sequence: "A", "vuelta"
        await tester.tap(find.byKey(const ValueKey('bank_active_q7_tile_a')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('bank_active_q7_tile_vuelta')),
        );
        await tester.pumpAndSettle();

        // Tap Check
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();

        // Wrong feedback panel appears
        expect(find.byType(FeedbackPanel), findsOneWidget);
        expect(find.text(AppStrings.feedbackWrongTitle), findsOneWidget);
        expect(find.text('Correct answer: Ida y vuelta'), findsOneWidget);
        expect(find.text(AppStrings.feedbackRedoNotice), findsOneWidget);

        // Why sheet opens on tap
        await tester.tap(find.text(AppStrings.why));
        await tester.pumpAndSettle();

        expect(find.byType(WhySheet), findsOneWidget);
        expect(find.text(AppStrings.whySheetTitle), findsOneWidget);
      },
    );

    testWidgets(
      'Question 7 renders cleanly at 200% text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textToSpeechServiceProvider.overrideWithValue(
                FakeSpeechService(),
              ),
              audioFeedbackServiceProvider.overrideWithValue(
                FakeAudioFeedbackService(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
                child: ExerciseScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await advanceToQuestion7(tester);

        expect(find.byType(BuildSentenceBody), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
