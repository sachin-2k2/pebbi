import 'placement_answer.dart';
import 'placement_intro.dart';
import 'placement_question.dart';
import 'placement_submission_result.dart';

/// Repository interface managing placement test content and submission.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class PlacementRepository {
  /// Fetches Pebbi's welcome intro message for the placement quiz.
  Future<PlacementIntro> getIntro({
    required String nativeLanguage,
    required String targetLanguage,
  });

  /// Fetches the set of placement quiz questions for the language pair.
  Future<PlacementQuestionSet> getQuestions({
    required String nativeLanguage,
    required String targetLanguage,
  });

  /// Submits the user's placement answers and returns the server-evaluated proficiency level.
  Future<PlacementSubmissionResult> submitAnswers({
    required String nativeLanguage,
    required List<PlacementAnswer> answers,
  });
}
