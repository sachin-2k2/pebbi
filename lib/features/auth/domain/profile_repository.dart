import 'user_profile.dart';

/// Repository interface managing the learner's profile persistence.
///
/// Follows AGENTS.md §2.2 & §6: Pure Dart interface with zero Flutter imports.
abstract interface class ProfileRepository {
  /// Loads the active user's profile, or null if no profile exists.
  Future<UserProfile?> getCurrentProfile();

  /// Persists the user profile to local storage.
  Future<void> saveProfile(UserProfile profile);

  /// Clears profile storage on logout / account reset.
  Future<void> clearProfile();
}
