import '../../onboarding/domain/age_band.dart';
import '../../onboarding/domain/language_level.dart';
import '../../onboarding/domain/reminder_time.dart';

/// Privacy-safe domain model representing a learner user profile.
///
/// Follows AGENTS.md §6 (User Isolation):
/// - Guest = `guest_<uuid>`; signed in = user ID from backend API.
/// - Stores ONLY privacy-safe user data ([ageBand], not raw birth year).
/// - Completely zero Flutter imports.
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.ageBand,
    required this.explanationLanguageCode,
    required this.targetLanguageCode,
    required this.reasonIds,
    this.selectedLevel,
    required this.dailyGoalId,
    required this.reminderTime,
    required this.selectedWeekdayNumbers,
    required this.remindersEnabled,
    required this.accentId,
    this.firstStickerId,
    required this.plan,
    this.firstName,
    this.isOnboarded = true,
    this.createdAt,
  });

  /// Distinct user identifier (e.g. `guest_local_user`).
  final String userId;

  /// Privacy-safe age band. Raw birth year is strictly discarded.
  final AgeBand ageBand;

  /// Interface and explanation language.
  final String explanationLanguageCode;

  /// Target learning language.
  final String targetLanguageCode;

  /// Selected learning reason identifiers.
  final Set<String> reasonIds;

  /// Placement level.
  final LanguageLevel? selectedLevel;

  /// Daily goal commitment tier ('casual', 'regular', 'serious', 'intense').
  final String dailyGoalId;

  /// Daily reminder wall-clock time.
  final ReminderTime reminderTime;

  /// Days of the week for reminder delivery (1..7).
  final Set<int> selectedWeekdayNumbers;

  /// Whether reminders are enabled.
  final bool remindersEnabled;

  /// Pebbi accent color ID.
  final String accentId;

  /// Starter sticker ID.
  final String? firstStickerId;

  /// Selected subscription tier ('free' or 'premium').
  final String plan;

  /// Optional first name for personal greetings.
  final String? firstName;

  /// Whether setup onboarding is complete.
  final bool isOnboarded;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Whether the user has an active premium entitlement.
  bool get isPremium => plan == 'premium';

  UserProfile copyWith({
    String? userId,
    AgeBand? ageBand,
    String? explanationLanguageCode,
    String? targetLanguageCode,
    Set<String>? reasonIds,
    LanguageLevel? selectedLevel,
    String? dailyGoalId,
    ReminderTime? reminderTime,
    Set<int>? selectedWeekdayNumbers,
    bool? remindersEnabled,
    String? accentId,
    String? firstStickerId,
    String? plan,
    String? firstName,
    bool clearFirstName = false,
    bool? isOnboarded,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      ageBand: ageBand ?? this.ageBand,
      explanationLanguageCode:
          explanationLanguageCode ?? this.explanationLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      reasonIds: reasonIds ?? this.reasonIds,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      dailyGoalId: dailyGoalId ?? this.dailyGoalId,
      reminderTime: reminderTime ?? this.reminderTime,
      selectedWeekdayNumbers:
          selectedWeekdayNumbers ?? this.selectedWeekdayNumbers,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      accentId: accentId ?? this.accentId,
      firstStickerId: firstStickerId ?? this.firstStickerId,
      plan: plan ?? this.plan,
      firstName: clearFirstName ? null : (firstName ?? this.firstName),
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          ageBand == other.ageBand &&
          explanationLanguageCode == other.explanationLanguageCode &&
          targetLanguageCode == other.targetLanguageCode &&
          selectedLevel == other.selectedLevel &&
          dailyGoalId == other.dailyGoalId &&
          reminderTime == other.reminderTime &&
          remindersEnabled == other.remindersEnabled &&
          accentId == other.accentId &&
          firstStickerId == other.firstStickerId &&
          plan == other.plan &&
          firstName == other.firstName &&
          isOnboarded == other.isOnboarded;

  @override
  int get hashCode => Object.hash(
    userId,
    ageBand,
    explanationLanguageCode,
    targetLanguageCode,
    selectedLevel,
    dailyGoalId,
    reminderTime,
    remindersEnabled,
    accentId,
    firstStickerId,
    plan,
    firstName,
    isOnboarded,
  );
}
