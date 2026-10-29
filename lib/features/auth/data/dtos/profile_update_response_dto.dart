import 'user_profile_dto.dart';

/// Response payload DTO for `PATCH /api/me`.
///
/// Follows API-V2.md §10 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class ProfileUpdateResponseDto {
  const ProfileUpdateResponseDto({
    required this.message,
    required this.user,
  });

  final String message;
  final UserProfileDto user;

  factory ProfileUpdateResponseDto.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponseDto(
      message: json['message']?.toString() ?? '',
      user: UserProfileDto.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': {
      'id': user.id,
      'display_name': user.displayName,
      'email': user.email,
      'native_language': user.nativeLanguage,
      'learning_language': user.learningLanguage,
      'current_level': user.currentLevel,
      'level': user.currentLevel,
      'suggested_level': user.suggestedLevel,
      'placement_skipped': user.placementSkipped,
      'placement_score': user.placementScore,
      'placement_total': user.placementTotal,
      'age_band': user.ageBand,
      'learning_goals': user.learningGoals,
      'daily_goal': user.dailyGoal,
      'reminder_time': user.reminderTime,
      'reminder_days': user.reminderDays,
      'accent_color': user.accentColor,
      'first_sticker': user.firstSticker,
      'onboarding_done': user.onboardingDone,
    },
  };
}
