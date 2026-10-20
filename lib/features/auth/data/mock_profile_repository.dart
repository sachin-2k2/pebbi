import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

/// Mock implementation of [ProfileRepository] storing the active profile in memory.
///
/// Follows AGENTS.md §1 & §6: Implements guest user persistence until drift database is wired.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({UserProfile? initialProfile, this.shouldFail = false})
    : _profile = initialProfile;

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  final bool shouldFail;

  @override
  Future<UserProfile?> getCurrentProfile() async {
    if (shouldFail) {
      throw StateError('Storage error: unable to read user profile.');
    }
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    if (shouldFail) {
      throw StateError('Storage error: unable to persist user profile.');
    }
    _profile = profile;
  }

  @override
  Future<void> clearProfile() async {
    _profile = null;
  }
}
