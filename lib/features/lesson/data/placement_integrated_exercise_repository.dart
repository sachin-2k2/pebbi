import '../../onboarding/data/mock_placement_repository.dart';
import '../../onboarding/domain/placement_repository.dart';
import '../domain/exercise_repository.dart';
import '../domain/exercise_set.dart';
import 'mappers/placement_exercise_mapper.dart';
import 'mock_exercise_repository.dart';

/// Production implementation of [ExerciseRepository] bridging placement requests
/// to the [PlacementRepository] (remote backend or offline mock), and converting
/// placement questions into interactive [PickPictureExercise] sets.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
class PlacementIntegratedExerciseRepository implements ExerciseRepository {
  const PlacementIntegratedExerciseRepository({
    required this.placementRepository,
    this.fallbackRepository = const MockExerciseRepository(),
  });

  final PlacementRepository placementRepository;
  final ExerciseRepository fallbackRepository;

  @override
  Future<ExerciseSet> loadPlacementSet(
    String targetLanguageCode, {
    String nativeLanguageCode = 'en',
  }) async {
    try {
      final questionSet = await placementRepository.getQuestions(
        nativeLanguage: nativeLanguageCode,
        targetLanguage: targetLanguageCode,
      );

      if (questionSet.isAvailable &&
          questionSet.sortedValidQuestions.isNotEmpty) {
        return PlacementExerciseMapper.toExerciseSet(
          questionSet: questionSet,
          targetLanguageCode: targetLanguageCode,
          nativeLanguageCode: nativeLanguageCode,
        );
      }
    } catch (_) {
      // If remote fails, fallback to local mock placement repository
    }

    try {
      const mockRepo = MockPlacementRepository();
      final mockSet = await mockRepo.getQuestions(
        nativeLanguage: nativeLanguageCode,
        targetLanguage: targetLanguageCode,
      );
      if (mockSet.sortedValidQuestions.isNotEmpty) {
        return PlacementExerciseMapper.toExerciseSet(
          questionSet: mockSet,
          targetLanguageCode: targetLanguageCode,
          nativeLanguageCode: nativeLanguageCode,
        );
      }
    } catch (_) {}

    return fallbackRepository.loadPlacementSet(
      targetLanguageCode,
      nativeLanguageCode: nativeLanguageCode,
    );
  }

  @override
  Future<ExerciseSet> loadLessonSet(String lessonId) {
    return fallbackRepository.loadLessonSet(lessonId);
  }
}
