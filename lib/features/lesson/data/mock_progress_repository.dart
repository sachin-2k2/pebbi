import '../domain/completion_config.dart';
import '../domain/lesson_completion.dart';
import '../domain/lesson_result.dart';
import '../domain/progress_repository.dart';

/// In-memory mock implementation of [ProgressRepository].
///
/// Follows AGENTS.md §2.1, §5 & §6: user isolation, outbox queue, offline-first.
class MockProgressRepository implements ProgressRepository {
  MockProgressRepository({
    this.customLearnedPhrases,
    this.customStreakDays = 1,
    this.customDailyGoal,
    this.customUnitCompleted = false,
    this.customBadgeIds = const [],
    this.customStickerIds = const [],
    this.customLevelUp,
    this.failSave = false,
  });

  /// Optional overrides for specialized test scenarios.
  final List<LearnedPhrase>? customLearnedPhrases;
  final int? customStreakDays;
  final DailyGoalCompletion? customDailyGoal;
  final bool customUnitCompleted;
  final List<String> customBadgeIds;
  final List<String> customStickerIds;
  final String? customLevelUp;
  final bool failSave;

  /// Results stored per userId.
  final Map<String, List<LessonResult>> _userResults = {};

  /// Cached completions stored per userId and stopId.
  final Map<String, Map<String, LessonCompletion>> _userCompletions = {};

  /// Processed client event IDs for idempotency.
  final Set<String> _processedEventIds = {};

  /// Outbox sync queue for offline sync.
  final List<({String userId, String eventId, LessonResult result, DateTime queuedAt})>
  _outbox = [];

  List<({String userId, String eventId, LessonResult result, DateTime queuedAt})>
  get outbox => List.unmodifiable(_outbox);

  @override
  Future<void> saveLessonProgress({
    required String userId,
    required LessonResult result,
  }) async {
    if (failSave) {
      throw Exception('Simulated local database write failure');
    }
    final list = _userResults.putIfAbsent(userId, () => []);
    list.add(result);
  }

  @override
  Future<LessonCompletion> completeLesson({
    required String userId,
    required String stopId,
    required LessonResult result,
    String? clientEventId,
  }) async {
    final eventId = clientEventId ?? 'evt_${userId}_${stopId}_${result.completedAt.millisecondsSinceEpoch}';

    // Idempotency: return previously processed completion if event ID was already recorded
    final userMap = _userCompletions.putIfAbsent(userId, () => {});
    if (_processedEventIds.contains(eventId) && userMap.containsKey(stopId)) {
      return userMap[stopId]!;
    }

    await saveLessonProgress(userId: userId, result: result);

    final scored = result.scoredItemCount;
    final firstTry = result.firstTryCorrectCount;
    final allSkipped = result.itemRecords.isNotEmpty &&
        result.itemRecords.values.every((r) => r.skipped);

    // Mock placeholder star calculation
    // TODO(question: backend owns real star rules, item weights and thresholds).
    final int stars;
    if (allSkipped) {
      stars = 0;
    } else if (scored == 0) {
      stars = 3;
    } else {
      final ratio = firstTry / scored;
      if (ratio >= CompletionConfig.star3MinAccuracy) {
        stars = 3;
      } else if (ratio >= CompletionConfig.star2MinAccuracy) {
        stars = 2;
      } else {
        stars = 1;
      }
    }

    final phrases = customLearnedPhrases ?? _defaultPhrasesForStop(stopId);
    final goal = customDailyGoal ??
        const DailyGoalCompletion(status: DailyGoalStatus.done);

    final completion = LessonCompletion(
      stopId: stopId,
      starsEarned: stars,
      scoredCount: scored,
      firstTryCorrectCount: firstTry,
      learnedPhrases: phrases,
      streakDays: customStreakDays,
      dailyGoal: goal,
      nextStopId: 'stop_1_2',
      unitCompleted: customUnitCompleted,
      newBadgeIds: customBadgeIds,
      newStickerIds: customStickerIds,
      levelUp: customLevelUp,
    );

    userMap[stopId] = completion;
    _processedEventIds.add(eventId);

    _outbox.add((
      userId: userId,
      eventId: eventId,
      result: result,
      queuedAt: DateTime.now(),
    ));

    return completion;
  }

  @override
  Future<LessonCompletion?> getLessonCompletion({
    required String userId,
    required String stopId,
  }) async {
    final existing = _userCompletions[userId]?[stopId];
    if (existing != null) return existing;

    final defaultResult = LessonResult(
      stopId: stopId,
      userId: userId,
      totalItems: 9,
      itemRecords: {
        for (int i = 1; i <= 9; i++)
          'item_$i': ItemRecord(
            itemId: 'item_$i',
            seen: true,
            firstTryCorrect: true,
            attempts: 1,
            credit: 1.0,
          ),
      },
      completedAt: DateTime.now(),
    );
    return completeLesson(
      userId: userId,
      stopId: stopId,
      result: defaultResult,
      clientEventId: 'fallback_${userId}_$stopId',
    );
  }

  @override
  Future<List<LessonResult>> getLessonHistory({required String userId}) async {
    return List.unmodifiable(_userResults[userId] ?? const []);
  }

  @override
  Future<bool> isStopCompleted({
    required String userId,
    required String stopId,
  }) async {
    final results = _userResults[userId];
    if (results == null) return false;
    return results.any((r) => r.stopId == stopId);
  }

  @override
  void clearCache() {
    _userResults.clear();
    _userCompletions.clear();
    _processedEventIds.clear();
    _outbox.clear();
  }

  List<LearnedPhrase> _defaultPhrasesForStop(String stopId) {
    if (stopId == 'arabic_1') {
      return const [
        LearnedPhrase(
          id: 'ar_1',
          emoji: '👋',
          text: 'مرحبا',
          meaning: 'Hello',
          audioText: 'مرحبا',
          audioLocale: 'ar-SA',
          isRtl: true,
        ),
        LearnedPhrase(
          id: 'ar_2',
          emoji: '🌅',
          text: 'صباح الخير',
          meaning: 'Good morning',
          audioText: 'صباح الخير',
          audioLocale: 'ar-SA',
          isRtl: true,
        ),
      ];
    }

    return const [
      LearnedPhrase(
        id: 'es_1',
        emoji: '👋',
        text: 'Hola',
        meaning: 'Hello',
        audioText: 'Hola',
        audioLocale: 'es-ES',
        helperLine: 'Greeting for anyone, anytime of day',
      ),
      LearnedPhrase(
        id: 'es_2',
        emoji: '🌅',
        text: 'Buenos días',
        meaning: 'Good morning',
        audioText: 'Buenos días',
        audioLocale: 'es-ES',
      ),
      LearnedPhrase(
        id: 'es_3',
        emoji: '☀️',
        text: 'Buenas tardes',
        meaning: 'Good afternoon',
        audioText: 'Buenas tardes',
        audioLocale: 'es-ES',
      ),
    ];
  }
}
