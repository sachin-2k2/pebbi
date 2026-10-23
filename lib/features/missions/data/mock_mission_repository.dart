import '../domain/mission_brief.dart';
import '../domain/mission_category.dart';
import '../domain/mission_goal.dart';
import '../domain/mission_mode.dart';
import '../domain/mission_repository.dart';
import '../domain/mission_summary.dart';
import '../domain/mission_support.dart';
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

  /// User-scoped mode preference overrides: userId -> MissionMode.
  final Map<String, MissionMode> _userDefaultModes = {};

  /// User-scoped support preference overrides: userId -> MissionSupport.
  final Map<String, MissionSupport> _userDefaultSupports = {};

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

  static final Map<String, MissionBrief> _defaultBriefs = {
    'order_coffee': const MissionBrief(
      missionId: 'order_coffee',
      emoji: '☕',
      title: 'Order a coffee',
      characterName: 'Lucía',
      characterRole: 'barista',
      sceneLine: 'A busy café, morning rush',
      goals: [
        MissionGoal(id: 'goal_1', text: 'Order a drink'),
        MissionGoal(id: 'goal_2', text: 'Ask the price'),
        MissionGoal(id: 'goal_3', text: 'Pay and say thank you'),
      ],
      estimatedMinutes: 5,
      difficulty: 1,
      supportsVoice: true,
      supportsChat: true,
      languageCode: 'es',
      status: MissionStatus.newMission,
    ),
    'no_voice_mission': const MissionBrief(
      missionId: 'no_voice_mission',
      emoji: '🤫',
      title: 'Quiet Study Session',
      characterName: 'Marcus',
      characterRole: 'librarian',
      sceneLine: 'A silent university library',
      goals: [
        MissionGoal(id: 'goal_1', text: 'Ask for a desk'),
        MissionGoal(id: 'goal_2', text: 'Borrow a dictionary'),
      ],
      estimatedMinutes: 4,
      difficulty: 1,
      supportsVoice: false,
      supportsChat: true,
      languageCode: 'es',
    ),
    'premium_mission': const MissionBrief(
      missionId: 'premium_mission',
      emoji: '💼',
      title: 'Job interview',
      characterName: 'Elena',
      characterRole: 'hiring manager',
      sceneLine: 'A formal office meeting room',
      goals: [
        MissionGoal(id: 'goal_1', text: 'Introduce yourself'),
        MissionGoal(id: 'goal_2', text: 'Describe your experience'),
        MissionGoal(id: 'goal_3', text: 'Ask about the team'),
      ],
      estimatedMinutes: 8,
      difficulty: 3,
      supportsVoice: true,
      supportsChat: true,
      languageCode: 'es',
      isPremium: true,
    ),
    'completed_mission': const MissionBrief(
      missionId: 'completed_mission',
      emoji: '🥐',
      title: 'Bakery visit',
      characterName: 'Pierre',
      characterRole: 'baker',
      sceneLine: 'A warm neighborhood bakery',
      goals: [
        MissionGoal(id: 'goal_1', text: 'Ask what is fresh'),
        MissionGoal(id: 'goal_2', text: 'Order two pastries'),
      ],
      estimatedMinutes: 5,
      difficulty: 1,
      supportsVoice: true,
      supportsChat: true,
      languageCode: 'fr',
      status: MissionStatus.done,
    ),
    'five_goals_mission': const MissionBrief(
      missionId: 'five_goals_mission',
      emoji: '🛒',
      title: 'Supermarket run',
      characterName: 'Carmen',
      characterRole: 'cashier',
      sceneLine: 'A crowded evening supermarket checkout',
      goals: [
        MissionGoal(id: 'goal_1', text: 'Greet the cashier'),
        MissionGoal(id: 'goal_2', text: 'Ask where the dairy aisle is located'),
        MissionGoal(id: 'goal_3', text: 'Inquire about discount deals'),
        MissionGoal(id: 'goal_4', text: 'Request a reusable shopping bag'),
        MissionGoal(id: 'goal_5', text: 'Pay with card and say goodbye'),
      ],
      estimatedMinutes: 10,
      difficulty: 2,
      supportsVoice: true,
      supportsChat: true,
      languageCode: 'es',
    ),
    'rtl_mission': const MissionBrief(
      missionId: 'rtl_mission',
      emoji: '🍵',
      title: 'Traditional tea house',
      characterName: 'Zaid',
      characterRole: 'host',
      sceneLine: 'A tranquil courtyard in the old city',
      goals: [
        MissionGoal(id: 'goal_1', text: 'Order mint tea'),
        MissionGoal(id: 'goal_2', text: 'Ask for the bill'),
      ],
      estimatedMinutes: 5,
      difficulty: 1,
      supportsVoice: true,
      supportsChat: true,
      languageCode: 'ar',
    ),
    'no_scene_mission': const MissionBrief(
      missionId: 'no_scene_mission',
      emoji: '👋',
      title: 'Casual Greeting',
      characterName: 'Mateo',
      characterRole: 'neighbor',
      sceneLine: null,
      goals: [
        MissionGoal(id: 'goal_1', text: 'Say hello'),
        MissionGoal(id: 'goal_2', text: 'Wish them a good day'),
      ],
      estimatedMinutes: 3,
      difficulty: 1,
      supportsVoice: true,
      supportsChat: true,
      languageCode: 'es',
    ),
  };

  @override
  Future<MissionBrief?> loadBrief({
    required String missionId,
    required String userId,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) async {
    final base = _defaultBriefs[missionId];
    if (base == null) return null;

    final userOverrides = _userMissionStatuses[userId] ?? const {};
    final status = userOverrides[missionId] ?? base.status;

    return base.copyWith(status: status);
  }

  @override
  Future<MissionMode> getDefaultMode({required String userId}) async {
    return _userDefaultModes[userId] ?? MissionMode.chat;
  }

  @override
  Future<void> saveDefaultMode({
    required String userId,
    required MissionMode mode,
  }) async {
    _userDefaultModes[userId] = mode;
  }

  @override
  Future<MissionSupport> getDefaultSupport({required String userId}) async {
    return _userDefaultSupports[userId] ?? MissionSupport.guided;
  }

  @override
  Future<void> saveDefaultSupport({
    required String userId,
    required MissionSupport support,
  }) async {
    _userDefaultSupports[userId] = support;
  }

  /// Reset all stored state for testing.
  void reset() {
    _userMissionStatuses.clear();
    _userTodayMissionCompleted.clear();
    _userDefaultModes.clear();
    _userDefaultSupports.clear();
  }
}
