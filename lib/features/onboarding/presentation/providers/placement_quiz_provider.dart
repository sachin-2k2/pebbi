import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/logging_interceptor.dart';
import '../../domain/placement_answer.dart';
import '../../domain/placement_question.dart';
import '../../domain/placement_result.dart';
import '../../domain/placement_submission_result.dart';
import 'onboarding_flow_provider.dart';
import 'placement_repository_provider.dart';

/// Provider fetching placement quiz questions for the current onboarding language pair.
final placementQuestionsProvider =
    FutureProvider.autoDispose<PlacementQuestionSet>((ref) async {
      final onboarding = ref.watch(onboardingFlowProvider);
      final repository = ref.watch(placementRepositoryProvider);

      return repository.getQuestions(
        nativeLanguage: onboarding.explanationLanguageCode,
        targetLanguage: onboarding.targetLanguageCode,
      );
    });

/// Immutable state for the active placement quiz session.
class PlacementQuizState {
  const PlacementQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.selectedOption,
    this.isAnswered = false,
    this.isSubmitting = false,
    this.submitError,
    this.submissionResult,
  });

  final List<PlacementQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers; // questionId -> chosenEmoji
  final PlacementOption? selectedOption;
  final bool isAnswered;
  final bool isSubmitting;
  final String? submitError;
  final PlacementSubmissionResult? submissionResult;

  PlacementQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex == questions.length - 1;

  int get totalQuestions => questions.length;
  int get currentQuestionNumber => currentIndex + 1;

  PlacementQuizState copyWith({
    List<PlacementQuestion>? questions,
    int? currentIndex,
    Map<String, String>? answers,
    PlacementOption? selectedOption,
    bool clearSelectedOption = false,
    bool? isAnswered,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    PlacementSubmissionResult? submissionResult,
  }) {
    return PlacementQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedOption: clearSelectedOption
          ? null
          : (selectedOption ?? this.selectedOption),
      isAnswered: isAnswered ?? this.isAnswered,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submissionResult: submissionResult ?? this.submissionResult,
    );
  }
}

/// Notifier driving the placement quiz progression and answer evaluation.
class PlacementQuizNotifier extends StateNotifier<PlacementQuizState> {
  PlacementQuizNotifier(this.ref) : super(const PlacementQuizState());

  final Ref ref;

  /// Initializes the quiz questions from [PlacementQuestionSet].
  void initQuestions(PlacementQuestionSet questionSet) {
    final validQuestions = <PlacementQuestion>[];

    for (final q in questionSet.sortedValidQuestions) {
      if (q.hasDuplicateEmojis) {
        LoggingPolicyInterceptor.logInvalidQuestion(
          q.id,
          'duplicate option emoji',
        );
        continue;
      }
      validQuestions.add(q);
    }

    state = state.copyWith(
      questions: List.unmodifiable(validQuestions),
      currentIndex: 0,
      answers: const {},
      clearSelectedOption: true,
      isAnswered: false,
    );
  }

  /// Selects an option tile and locks the question.
  void selectOption(PlacementOption option) {
    if (state.isAnswered || state.currentQuestion == null) return;

    final q = state.currentQuestion!;
    final updatedAnswers = Map<String, String>.from(state.answers);
    updatedAnswers[q.id] = option.emoji;

    state = state.copyWith(
      selectedOption: option,
      isAnswered: true,
      answers: updatedAnswers,
    );
  }

  /// Moves to the next question or triggers submission on completion.
  Future<bool> advanceOrSubmit() async {
    if (!state.isAnswered) return false;

    if (!state.isLastQuestion) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedOption: true,
        isAnswered: false,
      );
      return false; // Not finished yet
    }

    // Last question answered: submit to server
    return submit();
  }

  /// Submits the recorded answers to the backend.
  Future<bool> submit() async {
    if (state.isSubmitting) return false; // Double-tap protection

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);

    final repo = ref.read(placementRepositoryProvider);
    final onboarding = ref.read(onboardingFlowProvider);

    final answerList = state.answers.entries
        .map((e) => PlacementAnswer(questionId: e.key, chosenEmoji: e.value))
        .toList(growable: false);

    try {
      final result = await repo.submitAnswers(
        nativeLanguage: onboarding.explanationLanguageCode,
        answers: answerList,
      );

      // Collect praised phrases (up to 3 target phrases answered correctly on first try)
      final praisedPhrases = <String>[];
      for (final q in state.questions) {
        final chosen = state.answers[q.id];
        final correctOption = q.options.firstWhere(
          (o) => o.isCorrect,
          orElse: () => q.options.first,
        );
        if (chosen == correctOption.emoji) {
          praisedPhrases.add(q.targetPhrase);
          if (praisedPhrases.length >= 3) break;
        }
      }

      final placementResult = PlacementResult(
        suggestedLevel: result.level,
        chosenLevel: result.level,
        firstTryCorrect: result.score,
        totalQuestions: result.total,
        praisePhrases: praisedPhrases,
        streakDay: null, // Streak chip strictly hidden
        estimatedNote: result.estimatedNote,
      );

      ref
          .read(onboardingFlowProvider.notifier)
          .recordPlacementEvaluation(placementResult);

      state = state.copyWith(isSubmitting: false, submissionResult: result);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PlacementQuiz] Submit failed: $e');
      }
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Failed to submit placement quiz. Please try again.',
      );
      return false;
    }
  }

  /// Retries submission if previously failed.
  Future<bool> retrySubmit() => submit();
}

/// Provider for the active placement quiz notifier.
final placementQuizProvider =
    StateNotifierProvider<PlacementQuizNotifier, PlacementQuizState>((ref) {
      return PlacementQuizNotifier(ref);
    });
