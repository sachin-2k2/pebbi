import '../domain/onboarding_state.dart';
import 'mapping/accent_mapper.dart';
import 'mapping/daily_goal_mapper.dart';
import 'mapping/goals_mapper.dart';
import 'mapping/language_code_mapper.dart';
import 'mapping/level_mapper.dart';
import 'mapping/reminder_time_mapper.dart';
import 'mapping/sticker_mapper.dart';
import 'mapping/weekday_mapper.dart';

/// Pure data-layer builder creating the registration payload dictionary from [OnboardingState].
///
/// Follows AGENTS.md §2 & API-UPDATES.md §1:
/// - Outputs the full set of onboarding answers.
/// - Uses the user's explicitly CHOSEN level as `current_level`.
/// - Includes `suggested_level` from the placement check.
/// - Omits `placement_score` and `placement_total` when `placement_skipped == true`.
/// - Security Rule: The raw year of birth is NEVER present in the output.
/// - Note: `display_name`, `email`, and `password` are collected later on the sign-up form.
abstract final class RegistrationPayloadBuilder {
  static Map<String, dynamic> build(OnboardingState state) {
    final payload = <String, dynamic>{
      'native_language': LanguageCodeMapper.toApi(
        state.explanationLanguageCode,
        defaultCode: LanguageCodeMapper.defaultNative,
      ),
      'learning_language': LanguageCodeMapper.toApi(
        state.targetLanguageCode,
        defaultCode: LanguageCodeMapper.defaultTarget,
      ),
    };

    if (state.ageBand != null) {
      payload['age_band'] = state.ageBand!.apiValue;
    }

    final goals = GoalsMapper.toApi(state.selectedReasonIds);
    if (goals.isNotEmpty) {
      payload['learning_goals'] = goals;
    }

    payload['daily_goal'] = DailyGoalMapper.toApi(state.selectedGoalId);
    payload['reminder_time'] = ReminderTimeMapper.toApi(state.reminderTime);

    final days = WeekdayMapper.toApi(state.selectedWeekdayNumbers);
    if (days.isNotEmpty) {
      payload['reminder_days'] = days;
    }

    payload['accent_color'] = AccentMapper.toApi(state.accentId);

    final sticker = StickerMapper.toApi(state.firstStickerId);
    if (sticker != null) {
      payload['first_sticker'] = sticker;
    }

    // current_level is the user's confirmed/chosen level
    final chosenLevel = state.chosenLevel ?? state.selectedLevel;
    payload['current_level'] = LevelMapper.toApi(chosenLevel);

    if (state.suggestedLevel != null) {
      payload['suggested_level'] = LevelMapper.toApi(state.suggestedLevel);
    }

    payload['placement_skipped'] = state.isPlacementSkipped;

    if (!state.isPlacementSkipped && state.placementResult != null) {
      payload['placement_score'] = state.placementResult!.firstTryCorrect;
      payload['placement_total'] = state.placementResult!.totalQuestions;
    }

    return Map<String, dynamic>.unmodifiable(payload);
  }
}
