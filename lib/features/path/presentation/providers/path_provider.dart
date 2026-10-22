import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_path_repository.dart';
import '../../domain/path_repository.dart';
import '../../domain/track.dart';
import '../../domain/unit.dart';

import '../../../lesson/presentation/providers/lesson_providers.dart';

/// Provider for [PathRepository].
final pathRepositoryProvider = Provider<PathRepository>((ref) {
  final progressRepo = ref.watch(progressRepositoryProvider);
  return MockPathRepository(progressRepository: progressRepo);
});

/// Currently selected track filter on the Path screen.
final selectedTrackProvider = StateProvider<String>((ref) => 'everyday');

/// Provider loading all active tracks with content.
final tracksProvider = FutureProvider<List<Track>>((ref) async {
  final repository = ref.watch(pathRepositoryProvider);
  final allTracks = await repository.getTracks();
  return allTracks.where((t) => t.hasContent).toList();
});

/// Provider loading the course units and path rail nodes for the selected track.
///
/// Follows AGENTS.md §6: Watches currentUserProvider for strict user isolation.
final unitsProvider = FutureProvider<List<Unit>>((ref) async {
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
});
