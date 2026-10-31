import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../../review/domain/phrase.dart';
import '../../../review/domain/phrase_repository.dart';
import '../../data/dtos/check_answer_dto.dart';
import '../../data/dtos/submit_lesson_dto.dart';
import '../../data/mock_lesson_repository.dart';
import '../../domain/lesson_completion.dart';
import '../../domain/answer_checker.dart';
import '../../domain/exercise.dart';
import '../../domain/exercise_repository.dart';
import '../../domain/exercise_result.dart';
import '../../domain/lesson_repository.dart';
import '../../domain/lesson_result.dart';
import '../../domain/match_pairs_logic.dart';
import '../../domain/phrase_token.dart';
import '../../domain/progress_repository.dart';
import '../../domain/self_check_reason.dart';
import '../../domain/session_streak_rules.dart';
import '../../domain/speaking_config.dart';
import 'exercise_session_state.dart';

/// StateNotifier managing exercise lifecycle, selections, checking, hints, match pairs, and redo rounds.
///
/// Follows AGENTS.md §2.3: autoDispose notifier resetting when leaving screen.
class ExerciseSessionNotifier extends StateNotifier<ExerciseSessionState> {
  ExerciseSessionNotifier({
    required this.repository,
    this.lessonRepository,
    this.progressRepository,
    this.phraseRepository,
    this.userId = 'guest_default',
    required this.answerChecker,
    required this.audioFeedback,
    this.onStatsUpdated,
  }) : super(const ExerciseSessionState());

  final ExerciseRepository repository;
  final LessonRepository? lessonRepository;
  final ProgressRepository? progressRepository;
  final PhraseRepository? phraseRepository;
  final String userId;
  final AnswerChecker answerChecker;
  final AudioFeedbackService audioFeedback;
  final void Function(int streak, int stars, int xp)? onStatsUpdated;

  /// Loads the placement set for [targetLanguageCode].
  Future<void> loadPlacement(
    String targetLanguageCode, {
    String nativeLanguageCode = 'en',
  }) async {
    state = state.copyWith(isLoading: true);
    final exerciseSet = await repository.loadPlacementSet(
      targetLanguageCode,
      nativeLanguageCode: nativeLanguageCode,
    );
    if (!mounted) return;
    state = ExerciseSessionState(
      mainExercises: exerciseSet.exercises,
      currentMainIndex: 0,
      isLoading: false,
    );
  }

  /// Loads a curriculum lesson set for [stopId].
  Future<void> loadLesson(
    String stopId, {
    String? nativeLanguageCode,
    String? targetLanguageCode,
  }) async {
    state = state.copyWith(isLoading: true);
    final repo = lessonRepository ?? const MockLessonRepository();
    final lessonSet = await repo.loadLesson(
      stopId,
      nativeLanguage: nativeLanguageCode,
      learningLanguage: targetLanguageCode,
    );
    if (!mounted) return;
    state = ExerciseSessionState(
      mainExercises: lessonSet.items,
      currentMainIndex: 0,
      isLoading: false,
      stopId: stopId,
      lessonTitle: lessonSet.title,
    );
  }

  /// Advances a teach card or self-contained card after user taps "Got it".
  Future<void> onGotIt() async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    final updatedRecords = Map<String, ItemRecord>.from(state.itemRecords)
      ..[exercise.id] = ItemRecord(
        itemId: exercise.id,
        seen: true,
        firstTryCorrect: null,
      );

    state = state.copyWith(
      itemRecords: updatedRecords,
      status: ExerciseStatus.checked,
    );
    await next();
  }

  /// Skips an audio item without penalty when user taps "Can't listen now".
  Future<void> skipItemWithoutPenalty() async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    final updatedRecords = Map<String, ItemRecord>.from(state.itemRecords)
      ..[exercise.id] = ItemRecord(
        itemId: exercise.id,
        seen: true,
        skipped: true,
        firstTryCorrect: null,
      );

    state = state.copyWith(
      itemRecords: updatedRecords,
      currentStreak: SessionStreakRules.onSkip(),
      status: ExerciseStatus.checked,
    );
    await next();
  }

  /// Toggles saving an individual word token into the user's phrasebook.
  Future<void> toggleTokenSaved(PhraseToken token) async {
    final isCurrentlySaved = state.savedTokenIds.contains(token.id);
    final updated = Set<String>.from(state.savedTokenIds);
    if (isCurrentlySaved) {
      updated.remove(token.id);
    } else {
      updated.add(token.id);
    }
    state = state.copyWith(savedTokenIds: updated);

    if (phraseRepository != null) {
      try {
        await phraseRepository!.savePhrase(
          Phrase(
            id: token.id,
            languageCode: 'es',
            targetText: token.text,
            meaning: token.meaning ?? token.text,
            isSaved: !isCurrentlySaved,
            status: PhraseStatus.newPhrase,
          ),
          userId: userId,
        );
      } catch (_) {}
    }
  }

  /// Selects a matching card in either the target column or meaning column.
  Future<void> selectMatchCard({
    required String id,
    required bool isTargetColumn,
  }) async {
    if (state.matchedPairIds.contains(id)) return;
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }

    final exercise = state.currentExercise;
    if (exercise is! MatchPairsExercise) return;

    String? newTarget = state.selectedTargetMatchId;
    String? newMeaning = state.selectedMeaningMatchId;

    if (isTargetColumn) {
      newTarget = (newTarget == id) ? null : id;
    } else {
      newMeaning = (newMeaning == id) ? null : id;
    }

    if (newTarget != null && newMeaning != null) {
      final isMatch = MatchPairsLogic.isPairMatch(newTarget, newMeaning);
      if (isMatch) {
        final updatedMatched = Set<String>.from(state.matchedPairIds)
          ..add(newTarget);
        final allMatched = MatchPairsLogic.isAllMatched(
          exercise: exercise,
          matchedPairIds: updatedMatched,
        );

        if (allMatched) {
          final isFirstTry = state.matchMistakes == 0 && !state.isRedoRound;
          final updatedStreak = SessionStreakRules.onAnswerChecked(
            currentStreak: state.currentStreak,
            isCorrect: state.matchMistakes == 0,
            isFirstTry: isFirstTry,
          );

          final updatedRecords = Map<String, ItemRecord>.from(state.itemRecords)
            ..[exercise.id] = ItemRecord(
              itemId: exercise.id,
              seen: true,
              firstTryCorrect: state.matchMistakes == 0,
              attempts: 1 + state.matchMistakes,
            );

          var updatedRedo = List<Exercise>.from(state.redoQueue);
          if (state.matchMistakes > 0 && !state.isRedoRound) {
            updatedRedo.add(exercise);
          }

          state = state.copyWith(
            matchedPairIds: updatedMatched,
            selectedTargetMatchId: null,
            selectedMeaningMatchId: null,
            status: ExerciseStatus.checked,
            feedbackKind: FeedbackKind.correct,
            currentStreak: updatedStreak,
            itemRecords: updatedRecords,
            redoQueue: updatedRedo,
          );
          await audioFeedback.playSuccess();
        } else {
          state = state.copyWith(
            matchedPairIds: updatedMatched,
            selectedTargetMatchId: null,
            selectedMeaningMatchId: null,
          );
          await audioFeedback.playSuccess();
        }
      } else {
        // Mismatch: soft shake, increment mistake counter, then clear selection
        state = state.copyWith(
          selectedTargetMatchId: newTarget,
          selectedMeaningMatchId: newMeaning,
          isWrongPairShake: true,
          matchMistakes: state.matchMistakes + 1,
        );
        await audioFeedback.playWrong();
        if (!mounted) return;
        state = state.copyWith(
          selectedTargetMatchId: null,
          selectedMeaningMatchId: null,
          isWrongPairShake: false,
        );
      }
    } else {
      state = state.copyWith(
        selectedTargetMatchId: newTarget,
        selectedMeaningMatchId: newMeaning,
        status: (newTarget != null || newMeaning != null)
            ? ExerciseStatus.selected
            : ExerciseStatus.idle,
      );
    }
  }

  /// Selects an option by [id].
  void selectOption(String id) {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    if (state.removedOptionIds.contains(id)) return;

    state = state.copyWith(
      selectedOptionId: id,
      status: ExerciseStatus.selected,
    );
  }

  /// Uses a hint to eliminate one wrong distractor option.
  void useHint() {
    if (!state.canUseHint) return;

    final exercise = state.currentExercise;
    if (exercise is! SingleChoiceExercise) return;
    final singleChoice = exercise as SingleChoiceExercise;

    final candidates = singleChoice.optionIds.where((id) {
      final isCorrect = id == singleChoice.correctOptionId;
      final isSelected = id == state.selectedOptionId;
      final isRemoved = state.removedOptionIds.contains(id);
      return !isCorrect && !isSelected && !isRemoved;
    }).toList();

    if (candidates.isEmpty) return;

    final optionToRemoveId = candidates.first;
    final updatedRemoved = Set<String>.from(state.removedOptionIds)
      ..add(optionToRemoveId);

    state = state.copyWith(
      removedOptionIds: updatedRemoved,
      hintsUsed: state.hintsUsed + 1,
    );
  }

  /// Places a word tile into the answer area for sentence building.
  void placeTile(String tileId) {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    if (state.placedTileIds.contains(tileId)) return;
    final updated = [...state.placedTileIds, tileId];
    state = state.copyWith(
      placedTileIds: updated,
      status: ExerciseStatus.selected,
    );
  }

  /// Removes a word tile from the answer area, returning it to the word bank.
  void removeTile(String tileId) {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    if (!state.placedTileIds.contains(tileId)) return;
    final updated = state.placedTileIds.where((id) => id != tileId).toList();
    state = state.copyWith(
      placedTileIds: updated,
      status: updated.isEmpty ? ExerciseStatus.idle : ExerciseStatus.selected,
    );
  }

  /// Checks the learner's answer and presents feedback.
  Future<void> checkAnswer() async {
    if (!state.canCheck || state.isCheckingAnswer) return;

    final exercise = state.currentExercise;
    if (exercise == null) return;

    state = state.copyWith(isCheckingAnswer: true);

    final String recordedAnswer;
    if (exercise is BuildSentenceExercise) {
      recordedAnswer = state.placedTileIds.join(',');
    } else {
      final selectedId = state.selectedOptionId ?? '';
      recordedAnswer = selectedId;
    }

    // Resolve human-readable text chosen for backend evaluation
    String chosenText = recordedAnswer;
    if (exercise is ChooseMeaningExercise) {
      final opt = exercise.options
          .where((o) => o.id == recordedAnswer)
          .firstOrNull;
      chosenText = opt?.text ?? recordedAnswer;
    } else if (exercise is PickPictureExercise) {
      final opt = exercise.options
          .where((o) => o.id == recordedAnswer)
          .firstOrNull;
      chosenText = opt?.spokenLabel ?? opt?.imageRef ?? recordedAnswer;
    } else if (exercise is ListenChooseExercise) {
      final opt = exercise.options
          .where((o) => o.id == recordedAnswer)
          .firstOrNull;
      chosenText = opt?.text ?? recordedAnswer;
    } else if (exercise is ChooseReplyExercise) {
      final opt = exercise.options
          .where((o) => o.id == recordedAnswer)
          .firstOrNull;
      chosenText = opt?.text ?? recordedAnswer;
    }

    CheckAnswerResponseDto? serverCheck;
    if (state.stopId != null && lessonRepository != null) {
      try {
        serverCheck = await lessonRepository!.checkAnswer(
          lessonId: state.stopId!,
          questionId: exercise.id,
          chosenAnswer: chosenText,
        );
      } catch (_) {}
    }
    if (!mounted) return;

    final bool isCorrect;
    final String revealedCorrectAnswer;
    final int pointsEarned;

    if (serverCheck != null) {
      isCorrect = serverCheck.isCorrect;
      revealedCorrectAnswer = serverCheck.correctAnswer;
      pointsEarned = serverCheck.pointsEarned;
    } else {
      if (exercise is BuildSentenceExercise) {
        isCorrect = answerChecker.isSentenceCorrect(
          exercise,
          state.placedTileIds,
        );
      } else {
        isCorrect = answerChecker.isCorrect(exercise, recordedAnswer);
      }
      revealedCorrectAnswer = exercise.correctAnswerText;
      pointsEarned = isCorrect ? 1 : 0;
    }

    final isFirstTry =
        !state.isRedoRound && (state.itemRecords[exercise.id] == null);
    final updatedStreak = SessionStreakRules.onAnswerChecked(
      currentStreak: state.currentStreak,
      isCorrect: isCorrect,
      isFirstTry: isFirstTry,
    );

    final existingResult = state.results[exercise.id];
    final updatedResult = existingResult != null
        ? existingResult.copyWith(
            attempts: existingResult.attempts + 1,
            selectedOptionId: recordedAnswer,
          )
        : ExerciseResult(
            exerciseId: exercise.id,
            isFirstTryCorrect: isCorrect,
            hintsUsed: state.hintsUsed,
            attempts: 1,
            selectedOptionId: recordedAnswer,
          );

    final updatedResults = Map<String, ExerciseResult>.from(state.results)
      ..[exercise.id] = updatedResult;

    final existingItemRecord = state.itemRecords[exercise.id];
    final updatedItemRecord = existingItemRecord != null
        ? existingItemRecord.copyWith(attempts: existingItemRecord.attempts + 1)
        : ItemRecord(
            itemId: exercise.id,
            seen: true,
            firstTryCorrect: isCorrect,
            hintsUsed: state.hintsUsed,
            attempts: 1,
          );

    final updatedItemRecords = Map<String, ItemRecord>.from(state.itemRecords)
      ..[exercise.id] = updatedItemRecord;

    var updatedRedo = List<Exercise>.from(state.redoQueue);
    if (!isCorrect && !state.isRedoRound) {
      updatedRedo.add(exercise);
    }

    final updatedPoints = state.earnedPoints + (isFirstTry ? pointsEarned : 0);
    final updatedCheckMap = Map<String, CheckAnswerResponseDto>.from(
      state.checkedAnswerMap,
    );
    if (serverCheck != null) {
      updatedCheckMap[exercise.id] = serverCheck;
    }

    state = state.copyWith(
      isCheckingAnswer: false,
      status: ExerciseStatus.checked,
      feedbackKind: isCorrect ? FeedbackKind.correct : FeedbackKind.wrong,
      revealedCorrectAnswer: revealedCorrectAnswer,
      lastCheckResult: serverCheck,
      earnedPoints: updatedPoints,
      checkedAnswerMap: updatedCheckMap,
      results: updatedResults,
      itemRecords: updatedItemRecords,
      redoQueue: updatedRedo,
      currentStreak: updatedStreak,
    );

    if (isCorrect) {
      await audioFeedback.playSuccess();
    } else {
      await audioFeedback.playWrong();
    }
  }

  /// Advances to the next question, enters the redo queue, or completes.
  Future<void> next() async {
    if (state.status != ExerciseStatus.checked) return;

    if (!state.isRedoRound) {
      if (state.currentMainIndex + 1 < state.mainExercises.length) {
        state = state.copyWith(
          currentMainIndex: state.currentMainIndex + 1,
          selectedOptionId: null,
          placedTileIds: const [],
          status: ExerciseStatus.idle,
          feedbackKind: null,
          removedOptionIds: const {},
          hintsUsed: 0,
          revealedCorrectAnswer: null,
          lastCheckResult: null,
          selectedTargetMatchId: null,
          selectedMeaningMatchId: null,
          matchedPairIds: const {},
          isWrongPairShake: false,
          matchMistakes: 0,
        );
        return;
      }

      if (state.redoQueue.isNotEmpty) {
        state = state.copyWith(
          isRedoRound: true,
          currentRedoIndex: 0,
          selectedOptionId: null,
          placedTileIds: const [],
          status: ExerciseStatus.idle,
          feedbackKind: null,
          removedOptionIds: const {},
          hintsUsed: 0,
          revealedCorrectAnswer: null,
          lastCheckResult: null,
          selectedTargetMatchId: null,
          selectedMeaningMatchId: null,
          matchedPairIds: const {},
          isWrongPairShake: false,
          matchMistakes: 0,
        );
        return;
      }

      await _finishSession();
    } else {
      if (state.currentRedoIndex + 1 < state.redoQueue.length) {
        state = state.copyWith(
          currentRedoIndex: state.currentRedoIndex + 1,
          selectedOptionId: null,
          placedTileIds: const [],
          status: ExerciseStatus.idle,
          feedbackKind: null,
          removedOptionIds: const {},
          hintsUsed: 0,
          revealedCorrectAnswer: null,
          lastCheckResult: null,
          selectedTargetMatchId: null,
          selectedMeaningMatchId: null,
          matchedPairIds: const {},
          isWrongPairShake: false,
          matchMistakes: 0,
        );
        return;
      }

      await _finishSession();
    }
  }

  /// Called when speech recognition matches the target phrase.
  /// Full credit (1.0), increments streak on first try, displays FeedbackPanel.
  Future<void> onSpeakMatched() async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    final isFirstTry =
        !state.isRedoRound && (state.itemRecords[exercise.id] == null);
    final updatedStreak = SessionStreakRules.onAnswerChecked(
      currentStreak: state.currentStreak,
      isCorrect: true,
      isFirstTry: isFirstTry,
    );

    final existingItemRecord = state.itemRecords[exercise.id];
    final updatedItemRecord = existingItemRecord != null
        ? existingItemRecord.copyWith(
            attempts: existingItemRecord.attempts + 1,
            credit: SpeakingConfig.fullCreditValue,
          )
        : ItemRecord(
            itemId: exercise.id,
            seen: true,
            firstTryCorrect: true,
            attempts: 1,
            credit: SpeakingConfig.fullCreditValue,
          );

    final updatedItemRecords = Map<String, ItemRecord>.from(state.itemRecords)
      ..[exercise.id] = updatedItemRecord;

    state = state.copyWith(
      status: ExerciseStatus.checked,
      feedbackKind: FeedbackKind.correct,
      itemRecords: updatedItemRecords,
      currentStreak: updatedStreak,
    );

    await audioFeedback.playSuccess();
  }

  /// Called when the learner confirms "I said it ✓" on Screen B (self-check fallback).
  /// Half credit (0.5), does NOT increment streak, displays FeedbackPanel.
  Future<void> onSelfCheckConfirmed({SelfCheckReason? reason}) async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    final existingItemRecord = state.itemRecords[exercise.id];
    final updatedItemRecord = existingItemRecord != null
        ? existingItemRecord.copyWith(
            attempts: existingItemRecord.attempts + 1,
            credit: SpeakingConfig.halfCreditValue,
            selfCheckReason: reason,
          )
        : ItemRecord(
            itemId: exercise.id,
            seen: true,
            firstTryCorrect: null,
            attempts: 1,
            credit: SpeakingConfig.halfCreditValue,
            selfCheckReason: reason,
          );

    final updatedItemRecords = Map<String, ItemRecord>.from(state.itemRecords)
      ..[exercise.id] = updatedItemRecord;

    state = state.copyWith(
      status: ExerciseStatus.checked,
      feedbackKind: FeedbackKind.correct,
      itemRecords: updatedItemRecords,
    );

    await audioFeedback.playSuccess();
  }

  /// Called when the learner taps "Skip for now" on Screen B.
  /// Zero credit (0.0), skipped = true, advances immediately without redo or penalty.
  Future<void> onSpeakSkipped({SelfCheckReason? reason}) async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    final existingItemRecord = state.itemRecords[exercise.id];
    final updatedItemRecord = existingItemRecord != null
        ? existingItemRecord.copyWith(
            attempts: existingItemRecord.attempts + 1,
            skipped: true,
            credit: SpeakingConfig.zeroCreditValue,
            selfCheckReason: reason,
          )
        : ItemRecord(
            itemId: exercise.id,
            seen: true,
            skipped: true,
            firstTryCorrect: null,
            attempts: 1,
            credit: SpeakingConfig.zeroCreditValue,
            selfCheckReason: reason,
          );

    final updatedItemRecords = Map<String, ItemRecord>.from(state.itemRecords)
      ..[exercise.id] = updatedItemRecord;

    state = state.copyWith(
      status: ExerciseStatus.checked,
      itemRecords: updatedItemRecords,
    );

    await next();
  }

  Future<void> _finishSession() async {
    if (state.status == ExerciseStatus.completed || state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);

    if (state.stopId != null) {
      final answers = <SubmitLessonAnswerItemDto>[];
      for (final ex in state.mainExercises) {
        // Strictly skip teach cards and non-question synthetic items
        if (ex is NewPhraseCardExercise || ex.id.endsWith('_dialogue')) {
          continue;
        }

        final res = state.results[ex.id];
        final chosenAnswer = res?.selectedOptionId ?? '';
        String chosen = '';
        if (ex is ChooseMeaningExercise) {
          final opt = ex.options.where((o) => o.id == chosenAnswer).firstOrNull;
          chosen = opt?.text ?? chosenAnswer;
        } else if (ex is PickPictureExercise) {
          final opt = ex.options.where((o) => o.id == chosenAnswer).firstOrNull;
          chosen = opt?.spokenLabel ?? opt?.imageRef ?? chosenAnswer;
        } else if (ex is SpeakExercise) {
          chosen = ex.phrase;
        } else {
          chosen = chosenAnswer;
        }

        if (chosen.isEmpty) {
          chosen = ex.correctAnswerText;
        }

        answers.add(
          SubmitLessonAnswerItemDto(questionId: ex.id, chosenAnswer: chosen),
        );
      }

      SubmitLessonResponseDto? submitResponse;
      if (lessonRepository != null) {
        try {
          submitResponse = await lessonRepository!.submitLesson(
            lessonId: state.stopId!,
            answers: answers,
          );
        } catch (_) {}
      }
      if (!mounted) return;

      final lessonResult = LessonResult(
        stopId: state.stopId!,
        userId: userId,
        totalItems: state.mainExercises.length,
        itemRecords: state.itemRecords,
        completedAt: DateTime.now(),
      );

      final learnedPhrases = state.mainExercises
          .whereType<NewPhraseCardExercise>()
          .map(
            (ex) => LearnedPhrase(
              id: ex.id,
              emoji: ex.picture,
              text: ex.phrase,
              meaning: ex.meaning,
              audioText: ex.audioText,
              audioLocale: ex.audioLocale,
            ),
          )
          .toList();

      if (progressRepository != null) {
        await progressRepository!.saveLessonProgress(
          userId: userId,
          result: lessonResult,
        );
        final eventId =
            'evt_${userId}_${state.stopId}_${DateTime.now().millisecondsSinceEpoch}';
        await progressRepository!.completeLesson(
          userId: userId,
          stopId: state.stopId!,
          result: lessonResult,
          clientEventId: eventId,
          learnedPhrases: learnedPhrases.isNotEmpty ? learnedPhrases : null,
          passed: submitResponse?.passed,
          xpAwarded: submitResponse?.xpAwarded,
          backendScore: submitResponse?.score,
          backendTotal: submitResponse?.total,
          nextStopId: submitResponse?.nextLessonId,
          pebbiSays: submitResponse?.pebbiSays,
          currentStreak: submitResponse?.currentStreak,
          totalStars: submitResponse?.totalStars,
          totalXp: submitResponse?.totalXp,
        );
      }
      if (!mounted) return;

      if (submitResponse != null) {
        onStatsUpdated?.call(
          submitResponse.currentStreak ?? 0,
          submitResponse.totalStars ?? 0,
          submitResponse.totalXp ?? 0,
        );
      }

      state = state.copyWith(
        isSubmitting: false,
        submitResult: submitResponse,
        status: ExerciseStatus.completed,
      );
    } else {
      state = state.copyWith(
        isSubmitting: false,
        status: ExerciseStatus.completed,
      );
    }
  }
}
