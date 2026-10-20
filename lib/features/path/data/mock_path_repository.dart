import '../domain/path_node.dart';
import '../domain/path_repository.dart';
import '../domain/track.dart';
import '../domain/unit.dart';

/// Mock implementation of [PathRepository] with realistic 2-unit content.
///
/// Follows AGENTS.md §1 & §6: Supplies mock units and simulates user isolation.
class MockPathRepository implements PathRepository {
  MockPathRepository({
    this.completedStopIds = const {},
    this.simulatedDelay = Duration.zero,
  });

  final Set<String> completedStopIds;
  final Duration simulatedDelay;

  @override
  Future<List<Track>> getTracks() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    return const [
      Track(
        id: 'everyday',
        title: 'Everyday talk',
        emoji: '💬',
        hasContent: true,
      ),
      Track(id: 'travel', title: 'Travel', emoji: '✈️', hasContent: true),
      Track(
        id: 'work',
        title: 'Work & Interview',
        emoji: '💼',
        hasContent: false,
      ),
    ];
  }

  @override
  Future<List<Unit>> getUnitsForTrack(
    String trackId, {
    required String userId,
    bool isPremium = false,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (trackId == 'travel') {
      return [
        const Unit(
          id: 'unit_travel_1',
          unitNumber: 1,
          title: 'Airport & Hotel',
          trackId: 'travel',
          isFree: true,
          nodes: [
            LessonStopNode(
              id: 'stop_tr_1',
              title: 'At check-in',
              state: NodeState.current,
              stopNumber: 1,
              totalStopsInUnit: 3,
            ),
            LessonStopNode(
              id: 'stop_tr_2',
              title: 'Boarding pass',
              state: NodeState.locked,
              lockReason: LockReason.progress,
              isNext: true,
              stopNumber: 2,
              totalStopsInUnit: 3,
            ),
            LessonStopNode(
              id: 'stop_tr_3',
              title: 'Hotel lobby',
              state: NodeState.locked,
              lockReason: LockReason.progress,
              stopNumber: 3,
              totalStopsInUnit: 3,
            ),
          ],
        ),
      ];
    }

    // Default 'everyday' track matching screenshots exactly
    final isUnit1Done =
        completedStopIds.contains('stop_1_1') &&
        completedStopIds.contains('stop_1_2') &&
        completedStopIds.contains('stop_1_3');

    final unit1Nodes = <PathNode>[
      LessonStopNode(
        id: 'stop_1_1',
        title: 'Say hello',
        state: completedStopIds.contains('stop_1_1')
            ? NodeState.done
            : NodeState.current,
        starsEarned: completedStopIds.contains('stop_1_1') ? 3 : 0,
        stopNumber: 1,
        totalStopsInUnit: 3,
      ),
      LessonStopNode(
        id: 'stop_1_2',
        title: 'Nice to meet you',
        state: completedStopIds.contains('stop_1_2')
            ? NodeState.done
            : (completedStopIds.contains('stop_1_1')
                  ? NodeState.current
                  : NodeState.locked),
        lockReason: completedStopIds.contains('stop_1_1')
            ? LockReason.none
            : LockReason.progress,
        isNext: !completedStopIds.contains('stop_1_1'),
        starsEarned: completedStopIds.contains('stop_1_2') ? 3 : 0,
        stopNumber: 2,
        totalStopsInUnit: 3,
      ),
      LessonStopNode(
        id: 'stop_1_3',
        title: 'At a café',
        state: completedStopIds.contains('stop_1_3')
            ? NodeState.done
            : NodeState.locked,
        lockReason: completedStopIds.contains('stop_1_2')
            ? LockReason.none
            : LockReason.progress,
        starsEarned: completedStopIds.contains('stop_1_3') ? 3 : 0,
        stopNumber: 3,
        totalStopsInUnit: 3,
      ),
      ReviewNode(
        id: 'review_1',
        title: 'Review basics',
        state: isUnit1Done ? NodeState.current : NodeState.locked,
        lockReason: isUnit1Done ? LockReason.none : LockReason.progress,
      ),
      MissionNode(
        id: 'mission_1',
        title: 'Order coffee',
        state: NodeState.locked,
        lockReason: LockReason.progress,
      ),
      ChestNode(
        id: 'chest_1',
        title: 'Bonus Chest',
        state: NodeState.locked,
        lockReason: LockReason.progress,
        isOpened: false,
      ),
    ];

    return [
      Unit(
        id: 'unit_everyday_1',
        unitNumber: 1,
        title: 'First conversations',
        trackId: 'everyday',
        isFree: true,
        nodes: unit1Nodes,
      ),
    ];
  }
}
