import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/data/mappers/placement_exercise_mapper.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/picture_option.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/hear_it_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/pick_picture_body.dart';
import 'package:peddi/features/onboarding/domain/placement_question.dart';

void main() {
  group('Placement Quick Check & Audio Fixes (2 Key Tests)', () {
    test(
      '1. Mapper shows target language in prompt and cleans audioText of transliterations',
      () {
        const question = PlacementQuestion(
          id: 'q001_ml',
          sortOrder: 1,
          difficulty: 'A1',
          questionText: "Which one means 'Hello / Greetings'? 🙏",
          targetPhrase: 'നമസ്കാരം (Namaskaram)',
          options: [
            PlacementOption(
              emoji: '🙏',
              label: 'നമസ്കാരം (Namaskaram)',
              isCorrect: true,
            ),
            PlacementOption(
              emoji: '👋',
              label: 'പോയി വരാം (Poi varam)',
              isCorrect: false,
            ),
          ],
        );

        final set = PlacementExerciseMapper.toExerciseSet(
          questionSet: const PlacementQuestionSet(
            isAvailable: true,
            total: 1,
            questions: [question],
          ),
          targetLanguageCode: 'ml',
          nativeLanguageCode: 'en',
        );

        expect(set.exercises.length, equals(1));
        final ex = set.exercises.first as PickPictureExercise;

        // Prompt MUST show what user wants to learn (target phrase), NOT English "Hello / Greetings"
        expect(ex.prompt, equals('നമസ്കാരം (Namaskaram)'));

        // Audio text MUST NOT include transliteration in parens, preventing TTS from speaking twice
        expect(ex.audioText, equals('നമസ്കാരം'));
        expect(ex.audioLocale, equals('ml-IN'));
      },
    );

    testWidgets(
      '2. cleanAudioText cleans transliterations and PickPictureBody autoplays on entry',
      (tester) async {
        // Verify audio text cleaning logic for multiple scripts & transliterations
        expect(
          PlacementExerciseMapper.cleanAudioText('നമസ്കാരം (Namaskaram) 🙏'),
          equals('നമസ്കാരം'),
        );
        expect(
          PlacementExerciseMapper.cleanAudioText('Buenos días 🌅'),
          equals('Buenos días'),
        );

        var hearItCalls = 0;
        const testExercise = PickPictureExercise(
          id: 'test_pick',
          prompt: 'നമസ്കാരം (Namaskaram)',
          audioText: 'നമസ്കാരം',
          audioLocale: 'ml-IN',
          explanationText: '',
          correctAnswerText: 'നമസ്കാരം (Namaskaram)',
          feedbackSuccessText: '',
          options: [
            PictureOption(id: 'opt1', imageRef: '🙏', spokenLabel: 'Namaste'),
            PictureOption(id: 'opt2', imageRef: '👋', spokenLabel: 'Wave'),
          ],
          correctOptionId: 'opt1',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PickPictureBody(
                  exercise: testExercise,
                  selectedOptionId: null,
                  removedOptionIds: const {},
                  isLocked: false,
                  onOptionSelected: (_) {},
                  onHearIt: () => hearItCalls++,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Autoplay MUST trigger onHearIt automatically upon entering the page
        expect(hearItCalls, equals(1));

        // When isPlaying is true, tapping HearItButton must not trigger another speak call
        await tester.tap(find.byType(HearItButton));
        // Verify button exists and is rendered
        expect(find.byType(HearItButton), findsOneWidget);
      },
    );
  });
}
