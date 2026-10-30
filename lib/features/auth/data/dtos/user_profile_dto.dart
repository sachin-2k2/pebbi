import '../../../onboarding/data/mapping/level_mapper.dart';
import '../../../onboarding/data/mapping/weekday_mapper.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../../onboarding/domain/reminder_time.dart';
import '../../domain/user_profile.dart';

/// DTO parsing user profile returned by the backend in auth & profile responses.
///
/// Follows API-V2.md §7, §8, §9 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.displayName,
    required this.email,
    required this.nativeLanguage,
    required this.learningLanguage,
    this.currentLevel,
    this.suggestedLevel,
    this.placementSkipped = false,
    this.placementScore,
    this.placementTotal,
    this.ageBand,
    this.learningGoals = const [],
    this.dailyGoal = 'regular',
    this.reminderTime = '19:00',
    this.reminderDays = const [],
    this.accentColor = 'violet',
    this.firstSticker,
    this.onboardingDone = true,
    this.currentStreak = 0,
    this.totalStars = 0,
    this.totalXp = 0,
  });

  final String id;
  final String displayName;
  final String email;
  final String nativeLanguage;
  final String learningLanguage;
  final String? currentLevel;
  final String? suggestedLevel;
  final bool placementSkipped;
  final int? placementScore;
  final int? placementTotal;
  final String? ageBand;
  final List<String> learningGoals;
  final String dailyGoal;
  final String reminderTime;
  final List<dynamic> reminderDays;
  final String accentColor;
  final String? firstSticker;
  final bool onboardingDone;
  final int currentStreak;
  final int totalStars;
  final int totalXp;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nativeLanguage: json['native_language']?.toString() ?? 'en',
      learningLanguage: json['learning_language']?.toString() ?? 'es',
      currentLevel: (json['current_level'] ?? json['level'])?.toString(),
      suggestedLevel: json['suggested_level']?.toString(),
      placementSkipped: json['placement_skipped'] == true,
      placementScore: json['placement_score'] as int?,
      placementTotal: json['placement_total'] as int?,
      ageBand: json['age_band']?.toString(),
      learningGoals: (json['learning_goals'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dailyGoal: json['daily_goal']?.toString() ?? 'regular',
      reminderTime: json['reminder_time']?.toString() ?? '19:00',
      reminderDays: (json['reminder_days'] as List?)?.cast<dynamic>() ?? const [],
      accentColor: json['accent_color']?.toString() ?? 'violet',
      firstSticker: json['first_sticker']?.toString(),
      onboardingDone: json['onboarding_done'] == true,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      totalStars: (json['total_stars'] as num?)?.toInt() ?? 0,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      userId: id,
      email: email.isNotEmpty ? email : null,
      firstName: displayName.isNotEmpty ? displayName : null,
      ageBand: AgeBand.fromApiValue(ageBand) ?? AgeBand.band18_24,
      explanationLanguageCode: nativeLanguage,
      targetLanguageCode: learningLanguage,
      reasonIds: Set<String>.from(learningGoals),
      selectedLevel: LevelMapper.fromApi(currentLevel),
      dailyGoalId: dailyGoal,
      reminderTime: ReminderTime.parse(reminderTime),
      selectedWeekdayNumbers: WeekdayMapper.fromApi(reminderDays),
      remindersEnabled: reminderDays.isNotEmpty,
      accentId: accentColor,
      firstStickerId: firstSticker,
      plan: 'free',
      isOnboarded: onboardingDone,
      currentStreak: currentStreak,
      totalStars: totalStars,
      totalXp: totalXp,
    );
  }
}
