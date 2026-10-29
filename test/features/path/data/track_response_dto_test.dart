import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/data/dtos/track_response_dto.dart';
import 'package:peddi/features/path/domain/path_node.dart';

void main() {
  group('TrackLessonDto & TrackResponseDto Tests', () {
    const sampleTrackJson = {
      'track_id': 'daily',
      'lessons': [
        {
          'lesson_id': 'daily-starter-1',
          'lesson_number': 1,
          'level': 'starter',
          'level_order': 1,
          'title': 'Say Hello',
          'icon': '👋',
          'xp_reward': 10,
          'status': 'complete',
          'locked': false,
        },
        {
          'lesson_id': 'daily-starter-2',
          'lesson_number': 2,
          'level': 'starter',
          'level_order': 2,
          'title': 'At the Café',
          'icon': '☕',
          'xp_reward': 10,
          'status': 'not_started',
          'locked': false,
        },
        {
          'lesson_id': 'daily-starter-3',
          'lesson_number': 3,
          'level': 'starter',
          'level_order': 3,
          'title': 'Asking for Directions',
          'icon': '🗺️',
          'xp_reward': 10,
          'status': 'not_started',
          'locked': true,
        },
        {
          'lesson_id': 'daily-know_a_bit-7',
          'lesson_number': 7,
          'level': 'know_a_bit',
          'level_order': 1,
          'title': 'Making Weekend Plans',
          'icon': '📅',
          'xp_reward': 10,
          'status': 'not_started',
          'locked': true,
        },
      ],
    };

    test('TrackResponseDto parses JSON and correctly maps lesson states', () {
      final dto = TrackResponseDto.fromJson(sampleTrackJson);

      expect(dto.trackId, equals('daily'));
      expect(dto.lessons.length, equals(4));

      final lesson1 = dto.lessons[0];
      expect(lesson1.lessonId, equals('daily-starter-1'));
      expect(lesson1.status, equals('complete'));
      expect(lesson1.locked, isFalse);

      final node1 = lesson1.toDomainNode(totalInUnit: 3);
      expect(node1.id, equals('daily-starter-1'));
      expect(node1.state, equals(NodeState.done));
      expect(node1.starsEarned, equals(3));

      final lesson2 = dto.lessons[1];
      final node2 = lesson2.toDomainNode(totalInUnit: 3);
      expect(node2.id, equals('daily-starter-2'));
      expect(node2.state, equals(NodeState.current));
      expect(node2.isLocked, isFalse);

      final lesson3 = dto.lessons[2];
      final node3 = lesson3.toDomainNode(totalInUnit: 3);
      expect(node3.id, equals('daily-starter-3'));
      expect(node3.state, equals(NodeState.locked));
      expect(node3.isLocked, isTrue);
    });

    test('toUnits groups lessons into units by level and appends chest node', () {
      final dto = TrackResponseDto.fromJson(sampleTrackJson);
      final units = dto.toUnits(isPremium: false);

      expect(units.length, equals(2));

      // Unit 1: Starter
      expect(units[0].unitNumber, equals(1));
      expect(units[0].title, equals('Daily Starter'));
      expect(units[0].trackId, equals('daily'));
      expect(units[0].nodes.length, equals(4)); // 3 lessons + 1 chest node
      expect(units[0].nodes.last, isA<ChestNode>());

      // Unit 2: Know a bit
      expect(units[1].unitNumber, equals(2));
      expect(units[1].title, equals('Everyday Conversations'));
      expect(units[1].trackId, equals('daily'));
      expect(units[1].nodes.length, equals(2)); // 1 lesson + 1 chest node
    });

    test('TrackResponseDto parses direct list of lessons tolerantly', () {
      final listJson = sampleTrackJson['lessons'] as List;
      final dto = TrackResponseDto.fromJson(listJson, defaultTrackId: 'job');

      expect(dto.trackId, equals('job'));
      expect(dto.lessons.length, equals(4));
    });
  });
}
