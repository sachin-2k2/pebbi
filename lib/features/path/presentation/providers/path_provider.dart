import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_mode.dart';
import '../../../../core/network/network_status_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/session_expired_handler.dart';
import '../../../lesson/presentation/providers/lesson_providers.dart';
import '../../data/mock_path_repository.dart';
import '../../data/remote_path_repository.dart';
import '../../domain/path_repository.dart';
import '../../domain/path_node.dart';
import '../../domain/track.dart';
import '../../domain/unit.dart';
import 'track_stats_provider.dart';

/// Provider for [PathRepository].
///
/// Follows AGENTS.md §2: Injects [RemotePathRepository] when [ApiConfig.lessonApiMode]
/// is `ApiMode.real`, otherwise uses [MockPathRepository].
final pathRepositoryProvider = Provider<PathRepository>((ref) {
  final config = ApiConfig.instance;
  final progressRepo = ref.watch(progressRepositoryProvider);
  final local = MockPathRepository(progressRepository: progressRepo);

  if (config.lessonApiMode == ApiMode.real) {
    final client = ref.watch(apiClientProvider);
    return RemotePathRepository(
      apiClient: client,
      localFallback: local,
      onTrackStatsReceived: (streak, stars, xp) {
        ref
            .read(trackStatsProvider.notifier)
            .update(streak: streak, stars: stars, xp: xp);
      },
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

/// Currently selected track filter on the Path screen.
///
/// Automatically defaults to the recommended track from the backend (if flagged),
/// or selects 'job' if the user's goals include work or interview; otherwise 'daily'.
final selectedTrackProvider = StateProvider<String>((ref) {
  final tracksAsync = ref.watch(tracksProvider);
  final recommended = tracksAsync.value
      ?.where((t) => t.isRecommended)
      .firstOrNull;
  if (recommended != null) {
    return recommended.id;
  }

  final user = ref.watch(currentUserProvider);
  if (user != null &&
      (user.reasonIds.contains('work') ||
          user.reasonIds.contains('interview'))) {
    return 'job';
  }
  return 'daily';
});

/// Provider loading all active tracks with content.
final tracksProvider = FutureProvider<List<Track>>((ref) async {
  final repository = ref.watch(pathRepositoryProvider);
  final allTracks = await repository.getTracks();
  return allTracks.where((t) => t.hasContent).toList();
});

/// Track stop ID of the lesson just completed, used to animate Pebbi to the next node.
final completedLessonAnimProvider = StateProvider<String?>((ref) => null);

/// Provider loading the course units and path rail nodes for the selected track.
///
/// Follows AGENTS.md §6: Watches currentUserProvider for strict user isolation.
final unitsProvider =
    AsyncNotifierProvider<UnitsNotifier, List<Unit>>(UnitsNotifier.new);

class UnitsNotifier extends AsyncNotifier<List<Unit>> {
  @override
  Future<List<Unit>> build() async {
    final repository = ref.watch(pathRepositoryProvider);
    final trackId = ref.watch(selectedTrackProvider);
    final user = ref.watch(currentUserProvider);

    final userId = user?.userId ?? 'guest_default';
    final isPremium = user?.isPremium ?? false;

    return repository.getUnitsForTrack(
      trackId,
      userId: userId,
      isPremium: isPremium,
    );
  }

  Future<void> reloadSilently() async {
    state = const AsyncLoading<List<Unit>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repository = ref.read(pathRepositoryProvider);
      final trackId = ref.read(selectedTrackProvider);
      final user = ref.read(currentUserProvider);

      final userId = user?.userId ?? 'guest_default';
      final isPremium = user?.isPremium ?? false;

      return repository.getUnitsForTrack(
        trackId,
        userId: userId,
        isPremium: isPremium,
      );
    });
  }
}

/// Derived provider returning the currently active/current [PathNode] from [unitsProvider].
final activePathNodeProvider = Provider<PathNode?>((ref) {
  final units = ref.watch(unitsProvider).valueOrNull ?? const [];
  for (final unit in units) {
    for (final node in unit.nodes) {
      if (node.isCurrent) return node;
    }
  }
  return null;
});
