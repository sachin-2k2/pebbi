import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_language_repository.dart';
import '../../data/mock_learnable_language_repository.dart';
import '../../data/mock_learning_reason_repository.dart';
import '../../domain/age_band.dart';
import '../../domain/daily_goal_selection_rules.dart';
import '../../domain/language_level.dart';
import '../../domain/language_option.dart';
import '../../domain/language_repository.dart';
import '../../domain/learnable_language.dart';
import '../../domain/learnable_language_repository.dart';
import '../../domain/learning_reason.dart';
import '../../domain/learning_reason_repository.dart';
import '../../domain/onboarding_state.dart';
import '../../domain/placement_result.dart';
import '../../domain/reason_selection_rules.dart';
import '../../domain/reminder_selection_rules.dart';
import '../../domain/reminder_time.dart';

/// Provider for the [LanguageRepository].
final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  return const MockLanguageRepository();
});

/// Provider for available explanation languages.
final explanationLanguagesProvider = Provider<List<LanguageOption>>((ref) {
  final repository = ref.watch(languageRepositoryProvider);
  return repository.getExplanationLanguages();
});

/// Provider for the [LearnableLanguageRepository].
final learnableLanguageRepositoryProvider =
    Provider<LearnableLanguageRepository>((ref) {
      return const MockLearnableLanguageRepository();
    });

/// Provider for catalog of learnable languages.
final learnableLanguagesProvider = Provider<List<LearnableLanguage>>((ref) {
  final repository = ref.watch(learnableLanguageRepositoryProvider);
  return repository.getLearnableLanguages();
});

/// Provider for the [LearningReasonRepository].
final learningReasonRepositoryProvider = Provider<LearningReasonRepository>((
  ref,
) {
  return const MockLearningReasonRepository();
});

/// Provider for catalog of learning reasons.
final learningReasonsProvider = Provider<List<LearningReason>>((ref) {
  final repository = ref.watch(learningReasonRepositoryProvider);
  return repository.getReasons();
});

/// Notifier managing onboarding setup progression and answers.
///
/// Follows AGENTS.md §2.3 and §6:
/// - Derived/in-memory session state for onboarding
/// - Stores privacy-safe answers ([ageBand], [explanationLanguageCode], [targetLanguageCode], [selectedReasonIds]).
class OnboardingFlowNotifier extends StateNotifier<OnboardingState> {
  OnboardingFlowNotifier() : super(const OnboardingState());

  void setStep(int step) {
    if (step >= 1 && step <= state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < state.totalSteps) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Sets the privacy-safe age band.
  void setAgeBand(AgeBand band) {
    state = state.copyWith(ageBand: band);
  }

  /// Sets the explanation / native language code (e.g. 'en', 'es').
  void setExplanationLanguageCode(String code) {
    state = state.copyWith(explanationLanguageCode: code);
  }

  /// Sets the language the user wants to learn (e.g. 'es', 'fr', 'de').
  void setTargetLanguageCode(String code) {
    state = state.copyWith(targetLanguageCode: code);
  }

  /// Sets the selected learning reason IDs explicitly.
  void setReasonIds(Set<String> ids) {
    state = state.copyWith(selectedReasonIds: ids);
  }

  /// Toggles selection of [id] adhering to [ReasonSelectionRules].
  void toggleReasonId(String id) {
    final updated = ReasonSelectionRules.toggle(state.selectedReasonIds, id);
    state = state.copyWith(selectedReasonIds: updated);
  }

  /// Records skipped placement check with the given [level] (default: Little).
  void skipPlacementWithLevel(LanguageLevel level) {
    state = state.copyWith(selectedLevel: level, isPlacementSkipped: true);
  }

  /// Records full placement evaluation results including suggested and chosen levels.
  void recordPlacementEvaluation(PlacementResult result) {
    state = state.copyWith(
      placementResult: result,
      suggestedLevel: result.suggestedLevel,
      chosenLevel: result.chosenLevel,
      selectedLevel: result.chosenLevel,
      isPlacementSkipped: false,
    );
  }

  /// Sets the placement quiz outcome.
  void setPlacementResult({
    required LanguageLevel level,
    required bool skipped,
  }) {
    state = state.copyWith(
      selectedLevel: level,
      chosenLevel: level,
      isPlacementSkipped: skipped,
    );
  }

  /// Sets the daily learning goal identifier adhering to [DailyGoalSelectionRules].
  void setDailyGoal(String goalId) {
    final updated = DailyGoalSelectionRules.select(
      currentGoalId: state.selectedGoalId,
      newGoalId: goalId,
    );
    state = state.copyWith(selectedGoalId: updated);
  }

  /// Sets the daily reminder time.
  void setReminderTime(ReminderTime time) {
    state = state.copyWith(reminderTime: time);
  }

  /// Toggles selection of a weekday number (1..7).
  void toggleWeekday(int dayNumber) {
    final updated = ReminderSelectionRules.toggleWeekday(
      state.selectedWeekdayNumbers,
      dayNumber,
    );
    final isEnabled = ReminderSelectionRules.areRemindersEnabled(updated);
    state = state.copyWith(
      selectedWeekdayNumbers: updated,
      remindersEnabled: isEnabled,
    );
  }

  /// Saves the complete reminder configuration and permission result.
  void setReminderPreferences({
    required ReminderTime time,
    required Set<int> weekdays,
    required bool enabled,
    bool? permissionGranted,
  }) {
    state = state.copyWith(
      reminderTime: time,
      selectedWeekdayNumbers: weekdays,
      remindersEnabled: enabled,
      notificationPermissionGranted: permissionGranted,
    );
  }

  /// Sets the chosen accent colour ID.
  void setAccent(String accentId) {
    state = state.copyWith(accentId: accentId);
  }

  /// Sets or clears the starter sticker ID.
  void setFirstSticker(String? stickerId) {
    if (stickerId == null) {
      state = state.copyWith(clearFirstSticker: true);
    } else {
      state = state.copyWith(firstStickerId: stickerId);
    }
  }

  /// Toggles selection of a starter sticker ID.
  void toggleFirstSticker(String stickerId) {
    if (state.firstStickerId == stickerId) {
      state = state.copyWith(clearFirstSticker: true);
    } else {
      state = state.copyWith(firstStickerId: stickerId);
    }
  }

  /// Sets the selected subscription plan tier ('free' or 'premium').
  void setPlan(String plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  /// Resets setup answers to initial state.
  void reset() {
    state = const OnboardingState();
  }
}

/// Global provider for the active onboarding setup flow.
final onboardingFlowProvider =
    StateNotifierProvider<OnboardingFlowNotifier, OnboardingState>((ref) {
      return OnboardingFlowNotifier();
    });
