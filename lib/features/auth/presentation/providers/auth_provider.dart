import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_mode.dart';
import '../../../../core/network/network_status_provider.dart';
import '../../data/mock_profile_repository.dart';
import '../../data/remote_profile_repository.dart';
import '../../domain/profile_repository.dart';
import '../../domain/user_profile.dart';
import 'session_expired_handler.dart';

/// Provider for local/in-memory profile persistence fallback.
final localProfileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

/// Provider for the [ProfileRepository].
///
/// Follows AGENTS.md §2: Injects [RemoteProfileRepository] when
/// [ApiConfig.authApiMode] is `ApiMode.real`, otherwise [MockProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final config = ApiConfig.instance;
  final local = ref.watch(localProfileRepositoryProvider);

  if (config.authApiMode == ApiMode.real) {
    final client = ref.watch(apiClientProvider);
    return RemoteProfileRepository(
      apiClient: client,
      localFallback: local,
      onNetworkFailure: () {
        ref.read(isOfflineProvider.notifier).reportNetworkFailure();
      },
      onSessionExpired: (userId) {
        ref.read(sessionExpiredHandlerProvider).handleExpiredSession(userId);
      },
    );
  }

  return local;
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
      if (profile != null) {
        state = profile;
      }
    } catch (_) {
      // Ignored on initial boot
    }
  }

  /// Explicitly refreshes the user profile from remote/local repository.
  Future<void> refreshProfile() => _loadProfile();

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
