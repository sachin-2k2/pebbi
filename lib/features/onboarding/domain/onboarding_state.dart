import 'age_band.dart';
import 'language_level.dart';
import 'onboarding_config.dart';
import 'placement_result.dart';
import 'reminder_time.dart';
import 'weekday.dart';

/// Immutable onboarding setup state.
///
/// Follows AGENTS.md §2 and §6:
/// - Pure Dart (zero Flutter imports)
/// - Stores ONLY privacy-safe user data ([ageBand], [explanationLanguageCode]).
/// - Raw birth year is NEVER stored here.
class OnboardingState {
  const OnboardingState({
    this.currentStep = 1,
    this.totalSteps = OnboardingConfig.totalSteps,
    this.ageBand,
    this.explanationLanguageCode = 'en',
    this.targetLanguageCode = 'es',
    this.selectedReasonIds = const {},
    this.selectedLevel,
    this.suggestedLevel,
    this.chosenLevel,
    this.placementResult,
    this.isPlacementSkipped = false,
    this.selectedGoalId = 'regular',
    this.reminderTime = ReminderTime.defaultTime,
    this.selectedWeekdayNumbers = Weekday.allDayNumbers,
    this.remindersEnabled = true,
    this.notificationPermissionGranted,
    this.accentId = 'violet',
    this.firstStickerId,
    this.selectedPlan = 'free',
  });

  final int currentStep;
  final int totalSteps;

  /// Privacy-safe age band. Raw birth year is strictly discarded.
  final AgeBand? ageBand;

  /// Language selected for explanations and hints (default: 'en').
  final String explanationLanguageCode;

  /// Language the user wants to learn (default: 'es').
  final String targetLanguageCode;

  /// Set of learning reason IDs selected in Step 5 (up to 3).
  final Set<String> selectedReasonIds;

  /// Proficiency level determined by placement check or manual choice.
  final LanguageLevel? selectedLevel;

  /// Level originally recommended by the placement evaluator.
  final LanguageLevel? suggestedLevel;

  /// Level explicitly chosen/confirmed by the learner (overrides [suggestedLevel]).
  final LanguageLevel? chosenLevel;

  /// Full placement evaluation results summary if completed.
  final PlacementResult? placementResult;

  /// Whether the user skipped the placement check (e.g. "I'm brand new").
  final bool isPlacementSkipped;

  /// Selected daily goal identifier ('casual', 'regular', 'serious', 'intense'). Default is 'regular'.
  final String selectedGoalId;

  /// Daily reminder wall-clock time (default: 19:00 / 7:00 PM).
  final ReminderTime reminderTime;

  /// Set of ISO-8601 weekday numbers (1..7) for repeating reminders.
  final Set<int> selectedWeekdayNumbers;

  /// Whether reminders are actively enabled (false if 0 days selected).
  final bool remindersEnabled;

  /// Result of system notification permission request (null if not yet asked).
  final bool? notificationPermissionGranted;

  /// Selected accent colour identifier ('violet', 'green', 'orange', 'blue', 'pink', 'slate'). Default: 'violet'.
  final String accentId;

  /// Selected first starter sticker identifier ('wave', 'sparkle', 'wellsaid'). Null if none chosen.
  final String? firstStickerId;

  /// Selected tier/plan ('free' or 'premium'). Defaults to 'free'.
  final String selectedPlan;

  OnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    AgeBand? ageBand,
    String? explanationLanguageCode,
    String? targetLanguageCode,
    Set<String>? selectedReasonIds,
    LanguageLevel? selectedLevel,
    LanguageLevel? suggestedLevel,
    LanguageLevel? chosenLevel,
    PlacementResult? placementResult,
    bool? isPlacementSkipped,
    String? selectedGoalId,
    ReminderTime? reminderTime,
    Set<int>? selectedWeekdayNumbers,
    bool? remindersEnabled,
    bool? notificationPermissionGranted,
    String? accentId,
    String? firstStickerId,
    String? selectedPlan,
    bool clearFirstSticker = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      ageBand: ageBand ?? this.ageBand,
      explanationLanguageCode:
          explanationLanguageCode ?? this.explanationLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      selectedReasonIds: selectedReasonIds ?? this.selectedReasonIds,
      selectedLevel: selectedLevel ?? chosenLevel ?? this.selectedLevel,
      suggestedLevel: suggestedLevel ?? this.suggestedLevel,
      chosenLevel: chosenLevel ?? this.chosenLevel,
      placementResult: placementResult ?? this.placementResult,
      isPlacementSkipped: isPlacementSkipped ?? this.isPlacementSkipped,
      selectedGoalId: selectedGoalId ?? this.selectedGoalId,
      reminderTime: reminderTime ?? this.reminderTime,
      selectedWeekdayNumbers:
          selectedWeekdayNumbers ?? this.selectedWeekdayNumbers,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
      accentId: accentId ?? this.accentId,
      firstStickerId: clearFirstSticker
          ? null
          : (firstStickerId ?? this.firstStickerId),
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          currentStep == other.currentStep &&
          totalSteps == other.totalSteps &&
          ageBand == other.ageBand &&
          explanationLanguageCode == other.explanationLanguageCode &&
          targetLanguageCode == other.targetLanguageCode &&
          selectedLevel == other.selectedLevel &&
          suggestedLevel == other.suggestedLevel &&
          chosenLevel == other.chosenLevel &&
          placementResult == other.placementResult &&
          isPlacementSkipped == other.isPlacementSkipped &&
          selectedGoalId == other.selectedGoalId &&
          reminderTime == other.reminderTime &&
          remindersEnabled == other.remindersEnabled &&
          notificationPermissionGranted ==
              other.notificationPermissionGranted &&
          accentId == other.accentId &&
          firstStickerId == other.firstStickerId &&
          selectedPlan == other.selectedPlan &&
          _intSetEquals(selectedWeekdayNumbers, other.selectedWeekdayNumbers) &&
          _setEquals(selectedReasonIds, other.selectedReasonIds);

  @override
  int get hashCode => Object.hash(
    currentStep,
    totalSteps,
    ageBand,
    explanationLanguageCode,
    targetLanguageCode,
    selectedLevel,
    suggestedLevel,
    chosenLevel,
    placementResult,
    isPlacementSkipped,
    selectedGoalId,
    reminderTime,
    remindersEnabled,
    notificationPermissionGranted,
    accentId,
    firstStickerId,
    selectedPlan,
    Object.hashAll(selectedWeekdayNumbers),
    Object.hashAll(selectedReasonIds),
  );

  static bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  static bool _intSetEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
