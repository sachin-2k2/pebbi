import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/data/dtos/track_dto.dart';

void main() {
  group('TrackDto Tests', () {
    test('parses JSON payload from GET /api/tracks correctly', () {
      final json = {
        'track_id': 'daily',
        'title': 'Daily Conversations',
        'description': 'Everyday conversations for real life',
        'icon': '🌍',
        'total_lessons': 18,
        'is_recommended': true,
      };

      final dto = TrackDto.fromJson(json);
      expect(dto.trackId, equals('daily'));
      expect(dto.title, equals('Daily Conversations'));
      expect(dto.description, equals('Everyday conversations for real life'));
      expect(dto.icon, equals('🌍'));
      expect(dto.totalLessons, equals(18));
      expect(dto.isRecommended, isTrue);

      final domain = dto.toDomain();
      expect(domain.id, equals('daily'));
      expect(domain.title, equals('Daily Conversations'));
      expect(domain.emoji, equals('🌍'));
      expect(domain.hasContent, isTrue);
      expect(domain.isRecommended, isTrue);
      expect(domain.description, equals('Everyday conversations for real life'));
    });

    test('handles missing or null fields gracefully', () {
      final dto = TrackDto.fromJson(const {});
      expect(dto.trackId, isEmpty);
      expect(dto.title, isEmpty);
      expect(dto.icon, equals('🌍'));
      expect(dto.totalLessons, equals(0));
      expect(dto.isRecommended, isFalse);

      final domain = dto.toDomain();
      expect(domain.hasContent, isFalse);
    });
  });
}
