import '../domain/lesson_repository.dart';
import '../domain/lesson_set.dart';
import 'dtos/check_answer_dto.dart';
import 'dtos/submit_lesson_dto.dart';
import 'sample_lesson_variants.dart';
import 'sample_lessons.dart';

/// In-memory mock implementation of [LessonRepository].
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
class MockLessonRepository implements LessonRepository {
  const MockLessonRepository({this.checkAnswerHandler});

  final Future<CheckAnswerResponseDto?> Function({
    required String lessonId,
    required String questionId,
    required String chosenAnswer,
  })?
  checkAnswerHandler;

  @override
  Future<LessonSet> loadLesson(
    String stopId, {
    String? nativeLanguage,
    String? learningLanguage,
  }) async {
    if (learningLanguage == 'ml') {
      return SampleLessonVariants.malayalamLesson(stopId: stopId);
    }
    if (stopId == 'arabic_1') {
      return SampleLessonVariants.arabicLesson();
    }
    if (stopId == 'long_1') {
      return SampleLessonVariants.longPhraseLesson();
    }
    return SampleLessons.sayHelloLesson();
  }

  @override
  Future<CheckAnswerResponseDto?> checkAnswer({
    required String lessonId,
    required String questionId,
    required String chosenAnswer,
  }) async {
    if (checkAnswerHandler != null) {
      return checkAnswerHandler!(
        lessonId: lessonId,
        questionId: questionId,
        chosenAnswer: chosenAnswer,
      );
    }
    return null;
  }

  @override
  Future<SubmitLessonResponseDto?> submitLesson({
    required String lessonId,
    required List<SubmitLessonAnswerItemDto> answers,
  }) async {
    final total = answers.isNotEmpty ? answers.length : 6;
    return SubmitLessonResponseDto(
      passed: true,
      score: total,
      total: total,
      scorePct: 100,
      xpAwarded: 10,
      nextLessonId: 'next_$lessonId',
      pebbiSays: '¡Perfecto! 🎉 You scored $total/$total! Keep going!',
    );
  }
}
