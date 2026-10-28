import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/onboarding/data/mock_placement_repository.dart';
import 'package:peddi/features/onboarding/data/remote_placement_repository.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/placement_answer.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  group('PlacementRepository', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late RemotePlacementRepository remoteRepo;
    late MockPlacementRepository mockRepo;

    setUp(() {
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      remoteRepo = RemotePlacementRepository(apiClient: apiClient);
      mockRepo = const MockPlacementRepository();
    });

    test(
      'RemotePlacementRepository.getIntro returns parsed intro DTO/domain',
      () async {
        final jsonStr = File(
          'test/fixtures/api/placement_intro_200.json',
        ).readAsStringSync();
        fakeAdapter.onJson('/api/placement/intro', jsonStr);

        final intro = await remoteRepo.getIntro(
          nativeLanguage: 'ml',
          targetLanguage: 'en',
        );

        expect(intro.nativeLanguage, equals('ml'));
        expect(intro.targetLanguage, equals('en'));
        expect(intro.title, equals('Quick Check'));
        expect(intro.estimatedMinutes, equals(2));
      },
    );

    test('RemotePlacementRepository.getQuestions parses 8 questions', () async {
      final jsonStr = File(
        'test/fixtures/api/placement_questions_200.json',
      ).readAsStringSync();
      fakeAdapter.onJson('/api/placement/questions', jsonStr);

      final questionSet = await remoteRepo.getQuestions(
        nativeLanguage: 'ml',
        targetLanguage: 'en',
      );

      expect(questionSet.isAvailable, isTrue);
      expect(questionSet.questions.length, equals(8));
      expect(questionSet.questions.first.prompt, contains('Good morning'));
      expect(questionSet.questions.first.options.length, equals(4));
    });

    test(
      'RemotePlacementRepository.getQuestions handles unavailable: false',
      () async {
        final jsonStr = File(
          'test/fixtures/api/placement_questions_unavailable_200.json',
        ).readAsStringSync();
        fakeAdapter.onJson('/api/placement/questions', jsonStr);

        final questionSet = await remoteRepo.getQuestions(
          nativeLanguage: 'ml',
          targetLanguage: 'en',
        );

        expect(questionSet.isAvailable, isFalse);
        expect(questionSet.unavailableMessage, contains('not available'));
      },
    );

    test(
      'RemotePlacementRepository.getQuestions sorts out-of-order questions by sort_order',
      () async {
        final jsonStr = File(
          'test/fixtures/api/placement_questions_out_of_order_200.json',
        ).readAsStringSync();
        fakeAdapter.onJson('/api/placement/questions', jsonStr);

        final questionSet = await remoteRepo.getQuestions(
          nativeLanguage: 'ml',
          targetLanguage: 'en',
        );

        final sorted = questionSet.sortedValidQuestions;
        expect(sorted[0].sortOrder, equals(1));
        expect(sorted[1].sortOrder, equals(2));
        expect(sorted[2].sortOrder, equals(3));
      },
    );

    test(
      'RemotePlacementRepository.getQuestions handles question with 6 options',
      () async {
        final jsonStr = File(
          'test/fixtures/api/placement_questions_six_options_200.json',
        ).readAsStringSync();
        fakeAdapter.onJson('/api/placement/questions', jsonStr);

        final questionSet = await remoteRepo.getQuestions(
          nativeLanguage: 'ml',
          targetLanguage: 'en',
        );

        expect(questionSet.questions.first.options.length, equals(6));
      },
    );

    test(
      'RemotePlacementRepository.submitAnswers posts answers and maps level',
      () async {
        final jsonStr = File(
          'test/fixtures/api/placement_submit_200.json',
        ).readAsStringSync();
        fakeAdapter.onJson('/api/placement/submit', jsonStr);

        final result = await remoteRepo.submitAnswers(
          nativeLanguage: 'ml',
          answers: [const PlacementAnswer(questionId: 'q1', chosenEmoji: '🌅')],
        );

        expect(result.score, equals(7));
        expect(result.total, equals(8));
        expect(
          result.level,
          equals(LanguageLevel.little),
        ); // 'starter' -> little
        expect(result.estimatedNote, equals('Estimated: Starter'));
        expect(fakeAdapter.recordedRequests.length, equals(1));
        expect(fakeAdapter.recordedRequests.first.method, equals('POST'));
      },
    );

    test('MockPlacementRepository works offline without network', () async {
      final questions = await mockRepo.getQuestions(
        nativeLanguage: 'ml',
        targetLanguage: 'en',
      );
      expect(questions.isAvailable, isTrue);
      expect(questions.questions.length, equals(8));

      final submission = await mockRepo.submitAnswers(
        nativeLanguage: 'ml',
        answers: [],
      );
      expect(submission.total, equals(8));
      expect(fakeAdapter.recordedRequests, isEmpty);
    });
  });
}
