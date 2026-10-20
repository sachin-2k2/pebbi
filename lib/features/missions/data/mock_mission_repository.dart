import '../domain/mission_category.dart';
import '../domain/mission_repository.dart';
import '../domain/mission_summary.dart';
import '../domain/today_mission.dart';

/// In-memory mock implementation of [MissionRepository].
///
/// Follows AGENTS.md §1 & §6:
/// - Isolates mission completion states by [userId].
/// - Preloaded with 7 mission scenes across 5 categories.
/// - Includes 1 premium-locked mission to test gating.
class MockMissionRepository implements MissionRepository {
  MockMissionRepository({
    List<MissionSummary>? seedMissions,
    List<MissionCategory>? seedCategories,
  }) : _baseMissions = seedMissions ?? _defaultMissions,
       _categories = seedCategories ?? _defaultCategories;

  final List<MissionSummary> _baseMissions;
  final List<MissionCategory> _categories;

  /// User-scoped mission status overrides: userId -> missionId -> status.
  final Map<String, Map<String, MissionStatus>> _userMissionStatuses = {};

  /// User-scoped today's mission completion: userId -> isCompleted.
  final Map<String, bool> _userTodayMissionCompleted = {};

  static const List<MissionCategory> _defaultCategories = [
    MissionCategory(id: 'all', title: 'All'),
    MissionCategory(id: 'everyday', title: 'Everyday'),
    MissionCategory(id: 'travel', title: 'Travel'),
    MissionCategory(id: 'health', title: 'Health'),
    MissionCategory(id: 'money', title: 'Money'),
    MissionCategory(id: 'social', title: 'Social'),
  ];

  static const List<MissionSummary> _defaultMissions = [
    MissionSummary(
      id: 'order_coffee',
      categoryIds: ['everyday'],
      title: 'Order a coffee',
      characterName: 'Lucía',
      characterRole: 'barista',
      durationMinutes: 5,
      difficulty: 1,
      emoji: '☕',
      status: MissionStatus.newMission,
    ),
    MissionSummary(
      id: 'ask_directions',
      categoryIds: ['travel'],
      title: 'Ask for directions',
      characterName: 'Karim',
      characterRole: 'a passer-by',
      durationMinutes: 5,
      difficulty: 1,
      emoji: '🧭',
      status: MissionStatus.newMission,
    ),
    MissionSummary(
      id: 'hotel_checkin',
      categoryIds: ['travel'],
      title: 'Check into a hotel',
      characterName: 'Sofía',
      characterRole: 'receptionist',
      durationMinutes: 6,
      difficulty: 2,
      emoji: '🏨',
      status: MissionStatus.newMission,
    ),
    MissionSummary(
      id: 'pharmacy',
      categoryIds: ['health'],
      title: 'At the pharmacy',
      characterName: 'Nadia',
      characterRole: 'pharmacist',
      durationMinutes: 6,
      difficulty: 2,
      emoji: '💊',
      status: MissionStatus.newMission,
    ),
    MissionSummary(
      id: 'market_shopping',
      categoryIds: ['everyday', 'money'],
      title: 'Shop at the market',
      characterName: 'Aisha',
      characterRole: 'stall holder',
      durationMinutes: 5,
      difficulty: 2,
      emoji: '🧺',
      status: MissionStatus.newMission,
    ),
    // TODO(question: get the real data and icons for meet_neighbour)
    MissionSummary(
      id: 'meet_neighbour',
      categoryIds: ['social'],
      title: 'Meet your neighbour',
      characterName: 'Mateo',
      characterRole: 'neighbour',
      durationMinutes: 5,
      difficulty: 1,
      emoji: '👋',
      status: MissionStatus.newMission,
    ),
    // TODO(question: get the real data and icons for job_interview)
    MissionSummary(
      id: 'job_interview',
      categoryIds: ['social'],
      title: 'Job interview',
      characterName: 'Elena',
      characterRole: 'hiring manager',
      durationMinutes: 8,
      difficulty: 3,
      emoji: '💼',
      status: MissionStatus.newMission,
      isPremium: true,
    ),
  ];

  @override
  Future<List<MissionCategory>> getCategories({
    required String targetLanguageCode,
  }) async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<List<MissionSummary>> getMissions({
    required String targetLanguageCode,
    required String userId,
  }) async {
    final userOverrides = _userMissionStatuses[userId] ?? const {};

    return _baseMissions.map((mission) {
      final overrideStatus = userOverrides[mission.id];
      if (overrideStatus != null) {
        return mission.copyWith(status: overrideStatus);
      }
      return mission;
    }).toList();
  }

  @override
  Future<TodayMission?> getTodayMission({
    required String targetLanguageCode,
    required String userId,
  }) async {
    if (_baseMissions.isEmpty) return null;

    final first = _baseMissions.first;
    final userOverrides = _userMissionStatuses[userId] ?? const {};
    final status = userOverrides[first.id] ?? first.status;
    final isCompleted =
        _userTodayMissionCompleted[userId] ?? (status == MissionStatus.done);

    return TodayMission(
      mission: first.copyWith(status: status),
      isCompleted: isCompleted,
      reason: 'Daily highlight',
      date: DateTime.now(),
    );
  }

  @override
  Future<void> updateMissionStatus({
    required String userId,
    required String missionId,
    required MissionStatus status,
  }) async {
    final userMap = _userMissionStatuses.putIfAbsent(userId, () => {});
    userMap[missionId] = status;
  }

  @override
  Future<void> completeTodayMission({required String userId}) async {
    _userTodayMissionCompleted[userId] = true;
    if (_baseMissions.isNotEmpty) {
      await updateMissionStatus(
        userId: userId,
        missionId: _baseMissions.first.id,
        status: MissionStatus.done,
      );
    }
  }

  /// Reset all stored state for testing.
  void reset() {
    _userMissionStatuses.clear;
    _userTodayMissionCompleted.clear();
  }
}
