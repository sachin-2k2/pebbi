import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/features/auth/domain/profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/onboarding/data/mock_path_preparation_service.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/domain/path_preparation_service.dart';
import 'package:peddi/features/onboarding/domain/path_ready_state.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';

/// Provider for the [PathPreparationService].
final pathPreparationServiceProvider = Provider<PathPreparationService>((ref) {
  return const MockPathPreparationService();
});

/// State notifier driving the Path Ready step sequence and finish action.
///
/// Follows AGENTS.md §2.3: autoDispose / session notifier that cleans up subscriptions.
class PathReadyNotifier extends StateNotifier<PathReadyState> {
  PathReadyNotifier({
    required this.service,
    required this.audioFeedback,
    required this.reduceMotion,
  }) : super(PathReadyState.initial()) {
    _startPreparation();
  }

  final PathPreparationService service;
  final AudioFeedbackService audioFeedback;
  final bool reduceMotion;

  StreamSubscription<PathPreparationProgress>? _subscription;

  Future<void> _startPreparation() async {
    final lessonInfo = await service.getFirstLessonInfo();
    if (!mounted) return;
    state = state.copyWith(firstLessonInfo: lessonInfo);

    await _subscription?.cancel();
    _subscription = service.startPreparation(reduceMotion: reduceMotion).listen(
      (update) {
        if (!mounted) return;

        final allBlockingDone = update.tasks
            .where((t) => t.isBlocking)
            .every((t) => t.isDone);

        final newlyPrepared = allBlockingDone && !state.isPrepared;
        if (newlyPrepared) {
          audioFeedback.playSuccess();
        }

        state = state.copyWith(
          progress: update.progress,
          tasks: update.tasks,
          isPrepared: allBlockingDone,
        );
      },
    );
  }

  /// Retries preparation sequence from the beginning.
  void retry() {
    state = PathReadyState.initial().copyWith(
      firstLessonInfo: state.firstLessonInfo,
    );
    _startPreparation();
  }

  /// Saves user profile and marks onboarding completed.
  ///
  /// Double-tap protected via `state.isSaving`.
  Future<bool> finishOnboarding({
    required OnboardingState answers,
    required ProfileRepository profileRepo,
  }) async {
    if (state.isSaving || !state.canStartLesson) {
      return false;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final guestId =
          'guest_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';

      final profile = UserProfile(
        userId: guestId,
        ageBand: answers.ageBand ?? AgeBand.adult,
        explanationLanguageCode: answers.explanationLanguageCode,
        targetLanguageCode: answers.targetLanguageCode,
        reasonIds: answers.selectedReasonIds,
        selectedLevel: answers.selectedLevel,
        dailyGoalId: answers.selectedGoalId,
        reminderTime: answers.reminderTime,
        selectedWeekdayNumbers: answers.selectedWeekdayNumbers,
        remindersEnabled: answers.remindersEnabled,
        accentId: answers.accentId,
        firstStickerId: answers.firstStickerId,
        plan: answers.selectedPlan,
        isOnboarded: true,
        createdAt: DateTime.now(),
      );

      await profileRepo.saveProfile(profile);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveErrorMessage:
            'Unable to complete setup. Please check your connection and tap Retry.',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for the [PathReadyNotifier].
final pathReadyProvider =
    StateNotifierProvider.autoDispose<PathReadyNotifier, PathReadyState>((ref) {
      final service = ref.watch(pathPreparationServiceProvider);
      final audioFeedback = ref.watch(audioFeedbackServiceProvider);
      final reduceMotion = ref.watch(
        appSettingsProvider.select((s) => s.reduceMotion),
      );

      return PathReadyNotifier(
        service: service,
        audioFeedback: audioFeedback,
        reduceMotion: reduceMotion,
      );
    });
