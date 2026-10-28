import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/onboarding/data/dtos/placement_questions_response_dto.dart';
import 'package:peddi/features/onboarding/data/remote_placement_repository.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/domain/placement_result.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/placement_quiz_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/placement_repository_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/placement_result_notifier.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_intro_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_result_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_quiz/placement_feedback_panel.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_quiz/placement_option_grid.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_quiz/placement_quiz_prompt.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Placement Flow & Quiz Widget Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late FakeTextToSpeechService fakeTts;

    setUp(() {
      fakeAdapter = FakeHttpClientAdapter();
      fakeTts = FakeTextToSpeechService();

      final questionsJson = File(
        'test/fixtures/api/placement_questions_200.json',
      ).readAsStringSync();
      fakeAdapter.onJson('/api/placement/questions', questionsJson);

      final submitJson = File(
        'test/fixtures/api/placement_submit_200.json',
      ).readAsStringSync();
      fakeAdapter.onJson('/api/placement/submit', submitJson);
    });

    Widget buildTestApp({
      required Widget child,
      List<Override> additionalOverrides = const [],
    }) {
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWith(
            (ref) => ApiClient(adapter: fakeAdapter),
          ),
          placementRepositoryProvider.overrideWith(
            (ref) => RemotePlacementRepository(
              apiClient: ref.watch(apiClientProvider),
            ),
          ),
          onboardingFlowProvider.overrideWith(
            (ref) => OnboardingFlowNotifier(
              initialState: const OnboardingState(
                targetLanguageCode: 'en',
                explanationLanguageCode: 'ml',
              ),
            ),
          ),
          textToSpeechServiceProvider.overrideWithValue(fakeTts),
          ...additionalOverrides,
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets(
      'PlacementIntroScreen prefetches questions and does NOT call /api/placement/intro',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: const PlacementIntroScreen()),
        );
        await tester.pumpAndSettle();

        // Assert /api/placement/questions was called (prefetch)
        final questionCalls = fakeAdapter.recordedRequests.where(
          (r) => r.path.contains('/api/placement/questions'),
        );
        expect(questionCalls.length, equals(1));

        // Assert /api/placement/intro was NEVER called
        final introCalls = fakeAdapter.recordedRequests.where(
          (r) => r.path.contains('/api/placement/intro'),
        );
        expect(introCalls, isEmpty);
      },
    );

    testWidgets(
      'PlacementQuizScreen displays question, plays audio, and shows local feedback',
      (tester) async {
        final rawJson =
            jsonDecode(
                  File(
                    'test/fixtures/api/placement_questions_200.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        final questionSet = PlacementQuestionsResponseDto.fromJson(
          rawJson,
        ).toDomain();

        Widget testQuizView() {
          return Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(placementQuizProvider);
              final q = state.currentQuestion!;
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      PlacementQuizPrompt(
                        prompt: q.questionText,
                        targetPhrase: q.targetPhrase,
                        onSpeak: () => fakeTts.speak(q.targetPhrase, locale: 'en-US'),
                      ),
                      PlacementOptionGrid(
                        options: q.options,
                        selectedOption: state.selectedOption,
                        isAnswered: state.isAnswered,
                        onSelect: (opt) => ref
                            .read(placementQuizProvider.notifier)
                            .selectOption(opt),
                      ),
                      if (state.isAnswered && state.selectedOption != null)
                        PlacementFeedbackPanel(
                          selectedOption: state.selectedOption!,
                          question: q,
                          isLastQuestion: false,
                          isSubmitting: false,
                          onContinue: () {},
                          onRetry: () {},
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        await tester.pumpWidget(
          buildTestApp(
            child: testQuizView(),
            additionalOverrides: [
              placementQuizProvider.overrideWith((ref) {
                final notifier = PlacementQuizNotifier(ref);
                notifier.initQuestions(questionSet);
                return notifier;
              }),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Verify prompt and Hear It button
        expect(find.text("Which one means 'Good morning'?"), findsOneWidget);
        expect(
          find.byKey(const Key('placement_hear_it_button')),
          findsOneWidget,
        );

        // Tap Hear It button
        await tester.tap(find.byKey(const Key('placement_hear_it_button')));
        await tester.pump();
        expect(fakeTts.speakCallCount, equals(1));
        expect(fakeTts.lastSpokenText, equals('Good morning'));

        // Verify no hint button exists
        expect(find.text('Hint'), findsNothing);
        expect(find.byIcon(Icons.lightbulb_outline), findsNothing);

        // Tap correct option (Sunrise 🌅)
        final sunriseOption = find.byKey(const Key('placement_option_🌅'));
        expect(sunriseOption, findsOneWidget);
        await tester.tap(sunriseOption);
        await tester.pumpAndSettle();

        // Feedback panel appears with correct message
        expect(find.text('Spot on!'), findsOneWidget);

        // Verify "Why?" button toggles fun fact
        final whyButton = find.byKey(const Key('placement_why_button'));
        expect(whyButton, findsOneWidget);
        await tester.ensureVisible(whyButton);
        await tester.tap(whyButton);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('placement_fun_fact_text')),
          findsOneWidget,
        );
        expect(find.text("'Good morning' is used until noon."), findsOneWidget);

        // Verify Continue button
        expect(
          find.byKey(const Key('placement_continue_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'PlacementResultScreen renders score chip, hides streak chip, and shows estimated note',
      (tester) async {
        const customResult = PlacementResult(
          suggestedLevel: LanguageLevel.little,
          chosenLevel: LanguageLevel.little,
          firstTryCorrect: 6,
          totalQuestions: 8,
          streakDay: null,
          estimatedNote: 'Estimated from quick check',
        );

        await tester.pumpWidget(
          buildTestApp(
            child: const PlacementResultScreen(),
            additionalOverrides: [
              placementResultProvider.overrideWith(
                (ref) => PlacementResultNotifier(initialResult: customResult),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Score chip visible (6/8 first try)
        expect(find.textContaining('first try'), findsOneWidget);

        // Streak chip strictly hidden when streakDay is null
        expect(find.textContaining('day streak'), findsNothing);

        // Estimated note visible
        expect(find.text('Estimated from quick check'), findsOneWidget);
      },
    );
  });
}
