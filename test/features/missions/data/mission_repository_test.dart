import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/missions/data/mock_mission_repository.dart';
import 'package:peddi/features/missions/domain/mission_summary.dart';

void main() {
  late MockMissionRepository repository;

  setUp(() {
    repository = MockMissionRepository();
  });

  group('MockMissionRepository User Isolation', () {
    test(
      'user A finishes a mission; user B sees all missions as new',
      () async {
        const userA = 'user_alice';
        const userB = 'user_bob';

        // 1. Initial state: both users see 'order_coffee' as new
        final missionsBeforeA = await repository.getMissions(
          targetLanguageCode: 'es',
          userId: userA,
        );
        final missionsBeforeB = await repository.getMissions(
          targetLanguageCode: 'es',
          userId: userB,
        );

        expect(missionsBeforeA.first.status, MissionStatus.newMission);
        expect(missionsBeforeB.first.status, MissionStatus.newMission);

        // 2. User A completes 'order_coffee'
        await repository.updateMissionStatus(
          userId: userA,
          missionId: 'order_coffee',
          status: MissionStatus.done,
        );

        // 3. User A now sees status 'done'
        final missionsAfterA = await repository.getMissions(
          targetLanguageCode: 'es',
          userId: userA,
        );
        expect(missionsAfterA.first.status, MissionStatus.done);

        // 4. User B STILL sees status 'newMission'
        final missionsAfterB = await repository.getMissions(
          targetLanguageCode: 'es',
          userId: userB,
        );
        expect(missionsAfterB.first.status, MissionStatus.newMission);
      },
    );

    test('today mission completion is strictly user-isolated', () async {
      const userA = 'user_alice';
      const userB = 'user_bob';

      // User A completes today's mission
      await repository.completeTodayMission(userId: userA);

      final todayA = await repository.getTodayMission(
        targetLanguageCode: 'es',
        userId: userA,
      );
      final todayB = await repository.getTodayMission(
        targetLanguageCode: 'es',
        userId: userB,
      );

      expect(todayA?.isCompleted, isTrue);
      expect(todayB?.isCompleted, isFalse);
    });
  });
}
