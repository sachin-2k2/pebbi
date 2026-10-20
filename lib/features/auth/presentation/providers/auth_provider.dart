import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_profile_repository.dart';
import '../../domain/profile_repository.dart';
import '../../domain/user_profile.dart';

/// Provider for the [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

/// State notifier managing the active user profile (guest or authenticated).
///
/// Follows AGENTS.md §6: A single currentUserProvider drives all user-data providers.
class CurrentUserNotifier extends StateNotifier<UserProfile?> {
  CurrentUserNotifier(this._repository, [UserProfile? initialProfile])
    : super(initialProfile) {
    if (initialProfile == null) {
      _loadProfile();
    }
  }

  final ProfileRepository _repository;

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getCurrentProfile();
      state = profile;
    } catch (_) {
      // Ignored on initial boot
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = profile;
  }

  Future<void> logout() async {
    await _repository.clearProfile();
    state = null;
  }
}

/// Global provider for the active user session profile.
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserProfile?>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      final initial = repository is MockProfileRepository
          ? repository.profile
          : null;
      return CurrentUserNotifier(repository, initial);
    });
