import '../../../onboarding/data/mapping/accent_mapper.dart';
import '../../../onboarding/data/mapping/daily_goal_mapper.dart';
import '../../../onboarding/data/mapping/goals_mapper.dart';
import '../../../onboarding/data/mapping/language_code_mapper.dart';
import '../../../onboarding/data/mapping/level_mapper.dart';
import '../../../onboarding/data/mapping/reminder_time_mapper.dart';
import '../../../onboarding/data/mapping/weekday_mapper.dart';
import '../../domain/user_profile.dart';

/// Request payload DTO for `PATCH /api/me`.
///
/// Follows API-V2.md §10 & AGENTS.md §2: Pure Dart, zero Flutter imports.
/// Sends only the fields that are specified or updated.
class ProfileUpdateRequestDto {
  const ProfileUpdateRequestDto({
    this.displayName,
    this.currentLevel,
    this.dailyGoal,
    this.reminderTime,
    this.reminderDays,
    this.accentColor,
    this.ageBand,
    this.learningGoals,
    this.nativeLanguage,
    this.learningLanguage,
  });

  final String? displayName;
  final String? currentLevel;
  final String? dailyGoal;
  final String? reminderTime;
  final List<String>? reminderDays;
  final String? accentColor;
  final String? ageBand;
  final List<String>? learningGoals;
  final String? nativeLanguage;
  final String? learningLanguage;

  /// Creates a payload DTO from a full [UserProfile].
  factory ProfileUpdateRequestDto.fromProfile(UserProfile profile) {
    return ProfileUpdateRequestDto(
      displayName: profile.firstName?.trim(),
      currentLevel: profile.selectedLevel != null
          ? LevelMapper.toApi(profile.selectedLevel)
          : null,
      dailyGoal: DailyGoalMapper.toApi(profile.dailyGoalId),
      reminderTime: ReminderTimeMapper.toApi(profile.reminderTime),
      reminderDays: WeekdayMapper.toApi(profile.selectedWeekdayNumbers),
      accentColor: AccentMapper.toApi(profile.accentId),
      ageBand: profile.ageBand.apiValue,
      learningGoals: profile.reasonIds.isNotEmpty
          ? GoalsMapper.toApi(profile.reasonIds)
          : null,
      nativeLanguage: LanguageCodeMapper.toApi(profile.explanationLanguageCode),
      learningLanguage: LanguageCodeMapper.toApi(profile.targetLanguageCode),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null && displayName!.isNotEmpty)
        'display_name': displayName,
      if (currentLevel != null && currentLevel!.isNotEmpty)
        'current_level': currentLevel,
      if (dailyGoal != null && dailyGoal!.isNotEmpty)
        'daily_goal': dailyGoal,
      if (reminderTime != null && reminderTime!.isNotEmpty)
        'reminder_time': reminderTime,
      if (reminderDays != null && reminderDays!.isNotEmpty)
        'reminder_days': reminderDays,
      if (accentColor != null && accentColor!.isNotEmpty)
        'accent_color': accentColor,
      if (ageBand != null && ageBand!.isNotEmpty)
        'age_band': ageBand,
      if (learningGoals != null && learningGoals!.isNotEmpty)
        'learning_goals': learningGoals,
      if (nativeLanguage != null && nativeLanguage!.isNotEmpty)
        'native_language': nativeLanguage,
      if (learningLanguage != null && learningLanguage!.isNotEmpty)
        'learning_language': learningLanguage,
    };
  }
}
