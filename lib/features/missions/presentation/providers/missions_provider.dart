import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_mission_repository.dart';
import '../../domain/mission_category.dart';
import '../../domain/mission_repository.dart';
import '../../domain/mission_summary.dart';
import '../../domain/today_mission.dart';

/// Provider for the [MissionRepository] instance.
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MockMissionRepository();
});

/// Currently selected category ID (defaults to 'all').
///
/// Follows requirement: Kept when switching tabs and coming back.
final selectedMissionCategoryProvider = StateProvider<String>((ref) => 'all');

/// Selected mission ID for the expanded two-pane preview panel.
final selectedMissionForPreviewProvider = StateProvider<String?>((ref) => null);

/// Loaded state snapshot for the Missions screen.
class MissionsState {
  const MissionsState({
    required this.categories,
    required this.missions,
    this.todayMission,
    this.isOffline = false,
  });

  final List<MissionCategory> categories;
  final List<MissionSummary> missions;
  final TodayMission? todayMission;
  final bool isOffline;
}

/// Main async provider for missions, categories, and today's featured mission.
///
/// Follows AGENTS.md §6: Strictly watches [currentUserProvider] so that
/// logging in, logging out, or switching users triggers a clean re-fetch.
final missionsStateProvider = FutureProvider<MissionsState>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(missionRepositoryProvider);

  final userId = user?.userId ?? 'guest_default';
  final targetLanguage = user?.targetLanguageCode ?? 'es';

  final categories = await repository.getCategories(
    targetLanguageCode: targetLanguage,
  );
  final missions = await repository.getMissions(
    targetLanguageCode: targetLanguage,
    userId: userId,
  );
  final todayMission = await repository.getTodayMission(
    targetLanguageCode: targetLanguage,
    userId: userId,
  );

  return MissionsState(
    categories: categories,
    missions: missions,
    todayMission: todayMission,
  );
});

/// Filtered list of missions based on the currently selected category chip.
final filteredMissionsProvider = Provider<List<MissionSummary>>((ref) {
  final state = ref.watch(missionsStateProvider).valueOrNull;
  if (state == null) return const [];

  final selectedCategoryId = ref.watch(selectedMissionCategoryProvider);
  if (selectedCategoryId == 'all') {
    return state.missions;
  }

  return state.missions
      .where((mission) => mission.categoryIds.contains(selectedCategoryId))
      .toList();
});

/// Visible categories: hides categories with zero matching missions.
final visibleCategoriesProvider = Provider<List<MissionCategory>>((ref) {
  final state = ref.watch(missionsStateProvider).valueOrNull;
  if (state == null) return const [];

  return state.categories.where((cat) {
    if (cat.id == 'all') return true;
    return state.missions.any((m) => m.categoryIds.contains(cat.id));
  }).toList();
});
