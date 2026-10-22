import '../domain/lesson_repository.dart';
import '../domain/lesson_set.dart';
import 'sample_lesson_variants.dart';
import 'sample_lessons.dart';

/// In-memory mock implementation of [LessonRepository].
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
class MockLessonRepository implements LessonRepository {
  const MockLessonRepository();

  @override
  Future<LessonSet> loadLesson(String stopId) async {
    if (stopId == 'arabic_1') {
      return SampleLessonVariants.arabicLesson();
    }
    if (stopId == 'long_1') {
      return SampleLessonVariants.longPhraseLesson();
    }
    return SampleLessons.sayHelloLesson();
  }
}
