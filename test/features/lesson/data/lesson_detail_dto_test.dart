import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/data/dtos/check_answer_dto.dart';
import 'package:peddi/features/lesson/data/dtos/lesson_detail_dto.dart';
import 'package:peddi/features/lesson/data/dtos/submit_lesson_dto.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';

void main() {
  group('LessonDetailDto & Sub-DTOs', () {
    final sampleJson = {
      'lesson_id': 'daily-starter-1',
      'track': 'daily',
      'level': 'starter',
      'lesson_number': 1,
      'level_order': 1,
      'title': 'Say Hello',
      'goal': 'Greet someone and tell them your name',
      'pebbi_intro': "Let's learn how to say hello!",
      'dialogue_prompt': "Hi! What's your name?",
      'dialogue_correct': 'My name is Sam.',
      'icon': '👋',
      'xp_reward': 10,
      'total_phrases': 2,
      'phrases': [
        {
          'position': 1,
          'phrase_id': 'ph_good_morning',
          'target_text': 'Good morning',
          'translation': 'സുപ്രഭാതം',
          'tags': ['greeting'],
          'image_emoji': '🌅',
          'distractors': ['Good evening', 'Goodbye', 'See you later'],
        },
        {
          'position': 2,
          'phrase_id': 'ph_hello',
          'target_text': 'Hello',
          'translation': 'ഹലോ',
          'tags': ['greeting'],
          'image_emoji': '👋',
          'distractors': ['No', 'Yes'],
        },
      ],
      'assessment_config': {
        'total_questions': 2,
        'pass_score': 1,
        'include_speak_attempt': true,
      },
      'questions': [
        {
          'question_id': 'q_1',
          'question_type': 'pick_meaning',
          'phrase_id': 'ph_good_morning',
          'answer_choices': ['സുപ്രഭാതം', 'ഹലോ', 'നന്ദി'],
          'hint': 'Morning greeting',
          'points': 1,
          'order': 1,
        },
      ],
      'user_progress': {
        'status': 'not_started',
        'score': null,
        'xp_earned': 0,
        'attempts': 0,
      },
    };

    test('parses from backend JSON correctly', () {
      final dto = LessonDetailDto.fromJson(sampleJson);
      expect(dto.lessonId, equals('daily-starter-1'));
      expect(dto.track, equals('daily'));
      expect(dto.title, equals('Say Hello'));
      expect(dto.phrases.length, equals(2));
      expect(dto.phrases.first.targetText, equals('Good morning'));
      expect(dto.phrases.first.translation, equals('സുപ്രഭാതം'));
      expect(dto.questions.length, equals(1));
      expect(dto.assessmentConfig.passScore, equals(1));
      expect(dto.userProgress?.status, equals('not_started'));
    });

    test('converts to domain LessonSet with teach cards, questions, and dialogue', () {
      final dto = LessonDetailDto.fromJson(sampleJson);
      final set = dto.toLessonSet(learningLanguage: 'en', nativeLanguage: 'ml');

      expect(set.id, equals('daily-starter-1'));
      expect(set.title, equals('Say Hello'));
      // 2 teach cards + 1 question + 1 dialogue speak exercise = 4 items
      expect(set.items.length, equals(4));

      // Item 1: Teach card
      expect(set.items[0], isA<NewPhraseCardExercise>());
      final card1 = set.items[0] as NewPhraseCardExercise;
      expect(card1.phrase, equals('Good morning'));
      expect(card1.meaning, equals('സുപ്രഭാതം'));
      expect(card1.audioLocale, equals('en-US'));

      // Item 2: Teach card 2
      expect(set.items[1], isA<NewPhraseCardExercise>());

      // Item 3: ChooseMeaning question
      expect(set.items[2], isA<ChooseMeaningExercise>());
      final q1 = set.items[2] as ChooseMeaningExercise;
      expect(q1.phrase, equals('Good morning'));
      expect(q1.correctAnswerText, equals('സുപ്രഭാതം'));
      expect(q1.options.length, equals(3));

      // Item 4: Speak dialogue exercise
      expect(set.items[3], isA<SpeakExercise>());
      final spk = set.items[3] as SpeakExercise;
      expect(spk.phrase, equals('My name is Sam.'));
      expect(spk.meaning, equals("Hi! What's your name?"));
    });

    test('CheckAnswerRequestDto & ResponseDto serialize/deserialize accurately', () {
      final req = CheckAnswerRequestDto(
        questionId: 'q_1',
        chosenAnswer: 'സുപ്രഭാതം',
      );
      expect(req.toJson()['question_id'], equals('q_1'));

      final respJson = {
        'question_id': 'q_1',
        'is_correct': true,
        'correct_answer': 'സുപ്രഭാതം',
        'chosen_answer': 'സുപ്രഭാതം',
        'points_earned': 1,
      };
      final resp = CheckAnswerResponseDto.fromJson(respJson);
      expect(resp.isCorrect, isTrue);
      expect(resp.pointsEarned, equals(1));
    });

    test('SubmitLessonRequestDto & ResponseDto serialize/deserialize accurately', () {
      final req = SubmitLessonRequestDto(
        answers: [
          const SubmitLessonAnswerItemDto(
            questionId: 'q_1',
            chosenAnswer: 'സുപ്രഭാതം',
          ),
        ],
      );
      expect(req.toJson()['answers'], isList);

      final respJson = {
        'passed': true,
        'score': 2,
        'total': 2,
        'score_pct': 100,
        'xp_awarded': 10,
        'next_lesson_id': 'daily-starter-2',
        'pebbi_says': 'Great job! 🎉',
      };
      final resp = SubmitLessonResponseDto.fromJson(respJson);
      expect(resp.passed, isTrue);
      expect(resp.xpAwarded, equals(10));
      expect(resp.nextLessonId, equals('daily-starter-2'));
    });
  });
}
