import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/device_onboarding_draft_storage.dart';
import '../../data/mock_language_repository.dart';
import '../../data/mock_learnable_language_repository.dart';
import '../../data/mock_learning_reason_repository.dart';
import '../../data/remote_language_repository.dart';
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

/// Provider for the central [LanguageRepository].
final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  return RemoteLanguageRepository(apiClient: ref.watch(apiClientProvider));
});

/// Notifier providing native languages with immediate cached/fallback display and background refresh.
class NativeLanguagesNotifier
    extends StateNotifier<AsyncValue<List<LanguageOption>>> {
  NativeLanguagesNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }

  final LanguageRepository _repository;

  Future<void> load() async {
    final repo = _repository;
    if (repo is RemoteLanguageRepository) {
      final cached = await repo.loadCachedNativeLanguages();
      if (cached != null && cached.isNotEmpty && mounted) {
        state = AsyncValue.data(cached);
      } else {
        final fallback = await repo.loadBundledFallbackNativeLanguages();
        if (mounted) state = AsyncValue.data(fallback);
      }
    } else {
      state = AsyncValue.data(_repository.getExplanationLanguages());
    }

    try {
      final fresh = await _repository.getNativeLanguages();
      if (mounted) {
        state = AsyncValue.data(fresh);
      }
    } catch (e, st) {
      if (!state.hasValue && mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// Provider for native/explanation languages.
final nativeLanguagesProvider = StateNotifierProvider<
  NativeLanguagesNotifier,
  AsyncValue<List<LanguageOption>>
>((ref) {
  return NativeLanguagesNotifier(ref.watch(languageRepositoryProvider));
});

/// Convenience provider returning list or bundled fallback directly.
final explanationLanguagesProvider = Provider<List<LanguageOption>>((ref) {
  final asyncVal = ref.watch(nativeLanguagesProvider);
  return asyncVal.value ?? MockLanguageRepository.defaultLanguages;
});

/// Notifier providing learnable languages for a native language code.
class LearnLanguagesNotifier
    extends StateNotifier<AsyncValue<List<LearnableLanguage>>> {
  LearnLanguagesNotifier(this._repository, this._nativeCode)
    : super(const AsyncValue.loading()) {
    load();
  }

  final LanguageRepository _repository;
  final String _nativeCode;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final repo = _repository;
    if (repo is RemoteLanguageRepository) {
      final cached = await repo.loadCachedLearnLanguages(_nativeCode);
      if (cached != null && cached.isNotEmpty && mounted) {
        state = AsyncValue.data(cached);
        _refreshBackground(repo);
        return;
      }
    }

    try {
      final list = await _repository.getLearnLanguages(_nativeCode);
      if (mounted) state = AsyncValue.data(list);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> _refreshBackground(RemoteLanguageRepository repo) async {
    try {
      final fresh = await repo.getLearnLanguages(_nativeCode);
      if (mounted) state = AsyncValue.data(fresh);
    } catch (_) {}
  }
}

/// Provider for learnable languages keyed by native explanation code.
final learnLanguagesProvider = StateNotifierProvider.family<
  LearnLanguagesNotifier,
  AsyncValue<List<LearnableLanguage>>,
  String
>((ref, nativeCode) {
  return LearnLanguagesNotifier(
    ref.watch(languageRepositoryProvider),
    nativeCode,
  );
});

/// Provider for the legacy [LearnableLanguageRepository].
final learnableLanguageRepositoryProvider =
    Provider<LearnableLanguageRepository>((ref) {
      final repo = ref.watch(languageRepositoryProvider);
      if (repo is LearnableLanguageRepository) {
        return repo as LearnableLanguageRepository;
      }
      return const MockLearnableLanguageRepository();
    });

/// Provider for catalog of learnable languages.
final learnableLanguagesProvider = Provider<List<LearnableLanguage>>((ref) {
  final currentNative = ref.watch(
    onboardingFlowProvider.select((s) => s.explanationLanguageCode),
  );
  final asyncVal = ref.watch(learnLanguagesProvider(currentNative));
  return asyncVal.value ?? const [];
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

/// Provider for device-level draft storage.
final onboardingDraftStorageProvider = Provider<DeviceOnboardingDraftStorage>((
  ref,
) {
  return DeviceOnboardingDraftStorage();
});

/// Notifier managing onboarding setup progression and answers.
///
/// Follows AGENTS.md §2.3 and §6:
/// - Derived/in-memory session state for onboarding
/// - Persists privacy-safe answers in [DeviceOnboardingDraftStorage] with 300ms debounce
///   and immediate flush on step/lifecycle transitions.
class OnboardingFlowNotifier extends StateNotifier<OnboardingState> {
  OnboardingFlowNotifier({
    DeviceOnboardingDraftStorage? draftStorage,
    OnboardingState? initialState,
  }) : _draftStorage = draftStorage,
       super(initialState ?? const OnboardingState()) {
    _initFromStorage();
  }

  final DeviceOnboardingDraftStorage? _draftStorage;

  Future<void> _initFromStorage() async {
    if (_draftStorage == null) return;
    final saved = await _draftStorage.load();
    if (saved != null && mounted) {
      state = saved;
    }
  }

  void setStep(int step) {
    if (step >= 1 && step <= state.totalSteps) {
      state = state.copyWith(currentStep: step);
      _draftStorage?.flush(state);
    }
  }

  void nextStep() {
    if (state.currentStep < state.totalSteps) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      _draftStorage?.flush(state);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      _draftStorage?.flush(state);
    }
  }

  /// Flushes current state immediately (e.g. on app lifecycle inactive/paused).
  void flushDraft() {
    _draftStorage?.flush(state);
  }

  /// Sets the privacy-safe age band.
  void setAgeBand(AgeBand band) {
    state = state.copyWith(ageBand: band);
    _draftStorage?.saveDebounced(state);
  }

  /// Sets the explanation / native language code (e.g. 'en', 'es', 'ml').
  ///
  /// Clears target language choice if the spoken language changes.
  void setExplanationLanguageCode(String code) {
    if (state.explanationLanguageCode != code) {
      state = state.copyWith(
        explanationLanguageCode: code,
        targetLanguageCode: '',
      );
    } else {
      state = state.copyWith(explanationLanguageCode: code);
    }
    _draftStorage?.saveDebounced(state);
  }

  /// Sets the language the user wants to learn (e.g. 'en', 'es', 'fr', 'de').
  void setTargetLanguageCode(String code, {bool hasPlacement = true}) {
    state = state.copyWith(
      targetLanguageCode: code,
      targetLanguageHasPlacement: hasPlacement,
    );
    _draftStorage?.saveDebounced(state);
  }

  /// Sets the selected learning reason IDs explicitly.
  void setReasonIds(Set<String> ids) {
    state = state.copyWith(selectedReasonIds: ids);
    _draftStorage?.saveDebounced(state);
  }

  /// Toggles selection of [id] adhering to [ReasonSelectionRules].
  void toggleReasonId(String id) {
    final updated = ReasonSelectionRules.toggle(state.selectedReasonIds, id);
    state = state.copyWith(selectedReasonIds: updated);
    _draftStorage?.saveDebounced(state);
  }

  /// Records skipped placement check with the given [level] (default: Little).
  void skipPlacementWithLevel(LanguageLevel level) {
    state = state.copyWith(
      selectedLevel: level,
      chosenLevel: level,
      isPlacementSkipped: true,
    );
    _draftStorage?.flush(state);
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
    _draftStorage?.flush(state);
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
    _draftStorage?.flush(state);
  }

  /// Sets the daily learning goal identifier adhering to [DailyGoalSelectionRules].
  void setDailyGoal(String goalId) {
    final updated = DailyGoalSelectionRules.select(
      currentGoalId: state.selectedGoalId,
      newGoalId: goalId,
    );
    state = state.copyWith(selectedGoalId: updated);
    _draftStorage?.saveDebounced(state);
  }

  /// Sets the daily reminder time.
  void setReminderTime(ReminderTime time) {
    state = state.copyWith(reminderTime: time);
    _draftStorage?.saveDebounced(state);
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
    _draftStorage?.saveDebounced(state);
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
    _draftStorage?.flush(state);
  }

  /// Sets the chosen accent colour ID.
  void setAccent(String accentId) {
    state = state.copyWith(accentId: accentId);
    _draftStorage?.saveDebounced(state);
  }

  /// Sets or clears the starter sticker ID.
  void setFirstSticker(String? stickerId) {
    if (stickerId == null) {
      state = state.copyWith(clearFirstSticker: true);
    } else {
      state = state.copyWith(firstStickerId: stickerId);
    }
    _draftStorage?.saveDebounced(state);
  }

  /// Toggles selection of a starter sticker ID.
  void toggleFirstSticker(String stickerId) {
    if (state.firstStickerId == stickerId) {
      state = state.copyWith(clearFirstSticker: true);
    } else {
      state = state.copyWith(firstStickerId: stickerId);
    }
    _draftStorage?.saveDebounced(state);
  }

  /// Sets the selected subscription plan tier ('free' or 'premium').
  void setPlan(String plan) {
    state = state.copyWith(selectedPlan: plan);
    _draftStorage?.saveDebounced(state);
  }

  /// Resets setup answers to initial state and clears persisted draft.
  void reset() {
    _draftStorage?.clear();
    state = const OnboardingState();
  }

  /// Explicitly clears stored draft without resetting in-memory state.
  Future<void> clearDraft() async {
    await _draftStorage?.clear();
  }
}

/// Global provider for the active onboarding setup flow.
final onboardingFlowProvider =
    StateNotifierProvider<OnboardingFlowNotifier, OnboardingState>((ref) {
      final storage = ref.watch(onboardingDraftStorageProvider);
      return OnboardingFlowNotifier(draftStorage: storage);
    });
