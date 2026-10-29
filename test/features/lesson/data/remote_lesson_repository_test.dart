import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/lesson/data/mock_lesson_repository.dart';
import 'package:peddi/features/lesson/data/remote_lesson_repository.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteLessonRepository Integration Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late MockLessonRepository localFallback;
    late RemoteLessonRepository lessonRepository;
    String? expiredUserId;

    const sampleLessonJson = {
      'lesson_id': 'daily-starter-1',
      'track': 'daily',
      'level': 'starter',
      'lesson_number': 1,
      'title': 'Say Hello',
      'pebbi_intro': "Let's learn how to say hello!",
      'icon': '👋',
      'xp_reward': 10,
      'total_phrases': 1,
      'phrases': [
        {
          'position': 1,
          'phrase_id': 'ph_good_morning',
          'target_text': 'Good morning',
          'translation': 'സുപ്രഭാതം',
          'tags': ['greeting'],
          'image_emoji': '🌅',
          'distractors': ['Good night'],
        },
      ],
      'assessment_config': {
        'total_questions': 1,
        'pass_score': 1,
        'include_speak_attempt': false,
      },
      'questions': [
        {
          'question_id': 'q_1',
          'question_type': 'pick_meaning',
          'phrase_id': 'ph_good_morning',
          'answer_choices': ['സുപ്രഭാതം', 'ഹലോ'],
          'hint': 'Morning greeting',
          'points': 1,
          'order': 1,
        },
      ],
    };

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      localFallback = const MockLessonRepository();
      lessonRepository = RemoteLessonRepository(
        apiClient: apiClient,
        fallbackRepository: localFallback,
        onSessionExpired: (uid) => expiredUserId = uid,
      );
      expiredUserId = null;
    });

    test('loadLesson fetches dynamic lesson details from GET /api/lessons/{id}', () async {
      fakeAdapter.onJson(
        '/api/lessons/daily-starter-1',
        jsonEncode(sampleLessonJson),
      );

      final lessonSet = await lessonRepository.loadLesson(
        'daily-starter-1',
        nativeLanguage: 'ml',
        learningLanguage: 'en',
      );

      expect(lessonSet.id, equals('daily-starter-1'));
      expect(lessonSet.title, equals('Say Hello'));
      expect(lessonSet.items.length, equals(2));
      expect(lessonSet.items[0], isA<NewPhraseCardExercise>());
      final card = lessonSet.items[0] as NewPhraseCardExercise;
      expect(card.phrase, equals('Good morning'));
      expect(card.meaning, equals('സുപ്രഭാതം'));
      expect(card.audioLocale, equals('en-US'));

      expect(lessonSet.items[1], isA<ChooseMeaningExercise>());
      final q = lessonSet.items[1] as ChooseMeaningExercise;
      expect(q.correctAnswerText, equals('സുപ്രഭാതം'));
    });

    test('loadLesson falls back cleanly to local fallback on network failure', () async {
      fakeAdapter.onJson(
        '/api/lessons/daily-starter-1',
        '{"detail":"Server error"}',
        statusCode: 500,
      );

      final lessonSet = await lessonRepository.loadLesson(
        'daily-starter-1',
        nativeLanguage: 'ml',
        learningLanguage: 'en',
      );

      // Falls back to mock repository
      expect(lessonSet.items.isNotEmpty, isTrue);
    });

    test('loadLesson calls onSessionExpired when receiving 401 Unauthorized', () async {
      await apiClient.tokenStorage.saveSession(
        'user_active_1',
        'jwt_expired_1',
      );

      fakeAdapter.on(
        '/api/lessons/daily-starter-1',
        (options) => throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'detail': 'Invalid token'},
          ),
        ),
      );

      await lessonRepository.loadLesson(
        'daily-starter-1',
        nativeLanguage: 'ml',
        learningLanguage: 'en',
      );

      expect(expiredUserId, equals('user_active_1'));
    });

    test('checkAnswer calls POST /api/lessons/{id}/check and returns result', () async {
      fakeAdapter.onJson(
        '/api/lessons/daily-starter-1/check',
        jsonEncode({
          'question_id': 'q_1',
          'is_correct': true,
          'correct_answer': 'സുപ്രഭാതം',
          'chosen_answer': 'സുപ്രഭാതം',
          'points_earned': 1,
        }),
      );

      final result = await lessonRepository.checkAnswer(
        lessonId: 'daily-starter-1',
        questionId: 'q_1',
        chosenAnswer: 'സുപ്രഭാതം',
      );

      expect(result, isNotNull);
      expect(result!.isCorrect, isTrue);
      expect(result.pointsEarned, equals(1));
    });
  });
}
