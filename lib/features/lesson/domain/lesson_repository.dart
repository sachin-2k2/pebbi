import '../data/dtos/check_answer_dto.dart';
import '../data/dtos/submit_lesson_dto.dart';
import 'lesson_set.dart';

/// Repository interface for loading and submitting curriculum lessons.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class LessonRepository {
  /// Loads the [LessonSet] associated with the given curriculum [stopId].
  Future<LessonSet> loadLesson(
    String stopId, {
    String? nativeLanguage,
    String? learningLanguage,
  });

  /// Evaluates an assessment answer via `POST /api/lessons/{lessonId}/check`.
  Future<CheckAnswerResponseDto?> checkAnswer({
    required String lessonId,
    required String questionId,
    required String chosenAnswer,
  });

  /// Submits assessment answers to `POST /api/lessons/{lessonId}/submit`.
  Future<SubmitLessonResponseDto?> submitLesson({
    required String lessonId,
    required List<SubmitLessonAnswerItemDto> answers,
  });
}
