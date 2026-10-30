import 'dart:convert';
import '../../domain/path_node.dart';
import '../../domain/unit.dart';
import 'track_lesson_dto.dart';

/// Response payload DTO for `GET /api/lessons/track/{track_id}`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class TrackResponseDto {
  const TrackResponseDto({
    required this.trackId,
    required this.lessons,
    this.userStreak = 0,
    this.totalStars = 0,
    this.totalXp = 0,
  });

  final String trackId;
  final List<TrackLessonDto> lessons;
  final int userStreak;
  final int totalStars;
  final int totalXp;

  factory TrackResponseDto.fromJson(
    dynamic json, {
    String defaultTrackId = 'daily',
  }) {
    var raw = json;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return TrackResponseDto(trackId: defaultTrackId, lessons: const []);
      }
    }

    if (raw is List) {
      final lessons = raw
          .whereType<Map>()
          .map((i) => TrackLessonDto.fromJson(Map<String, dynamic>.from(i)))
          .toList(growable: false);
      return TrackResponseDto(trackId: defaultTrackId, lessons: lessons);
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final listRaw = map['lessons'] as List? ?? const [];
      final parsed = listRaw
          .whereType<Map>()
          .map((i) => TrackLessonDto.fromJson(Map<String, dynamic>.from(i)))
          .toList(growable: false);

      return TrackResponseDto(
        trackId: map['track_id']?.toString() ?? defaultTrackId,
        lessons: parsed,
        userStreak: (map['user_streak'] as num?)?.toInt() ?? 0,
        totalStars: (map['total_stars'] as num?)?.toInt() ?? 0,
        totalXp: (map['total_xp'] as num?)?.toInt() ?? 0,
      );
    }

    return TrackResponseDto(trackId: defaultTrackId, lessons: const []);
  }

  /// Transforms the flat lesson list into structured course [Unit]s grouped by level.
  List<Unit> toUnits({bool isPremium = false}) {
    if (lessons.isEmpty) return const [];

    final starter = lessons.where((l) => l.level == 'starter').toList();
    final knowABit = lessons.where((l) => l.level == 'know_a_bit').toList();
    final expert = lessons.where((l) => l.level == 'expert').toList();

    if (starter.isEmpty && knowABit.isEmpty && expert.isEmpty) {
      return _chunkIntoUnits(lessons, isPremium: isPremium);
    }

    final units = <Unit>[];
    if (starter.isNotEmpty) {
      units.add(
        _buildUnit(
          unitNumber: 1,
          title: trackId == 'job' ? 'Job Starter' : 'Daily Starter',
          lessons: starter,
          isFree: true,
        ),
      );
    }
    if (knowABit.isNotEmpty) {
      units.add(
        _buildUnit(
          unitNumber: 2,
          title: trackId == 'job'
              ? 'Office & Communication'
              : 'Everyday Conversations',
          lessons: knowABit,
          isFree: isPremium,
        ),
      );
    }
    if (expert.isNotEmpty) {
      units.add(
        _buildUnit(
          unitNumber: 3,
          title: trackId == 'job'
              ? 'Executive & Interviews'
              : 'Advanced Nuance',
          lessons: expert,
          isFree: isPremium,
        ),
      );
    }

    return List.unmodifiable(units);
  }

  Unit _buildUnit({
    required int unitNumber,
    required String title,
    required List<TrackLessonDto> lessons,
    required bool isFree,
  }) {
    final nodes = <PathNode>[];
    for (var i = 0; i < lessons.length; i++) {
      nodes.add(lessons[i].toDomainNode(totalInUnit: lessons.length));
    }

    // Add rewarding chest node at the end of the unit
    final allComplete = lessons.every((l) => l.status == 'complete');
    nodes.add(
      ChestNode(
        id: 'chest_${trackId}_$unitNumber',
        title: 'Bonus Chest',
        state: allComplete ? NodeState.current : NodeState.locked,
        lockReason: allComplete ? LockReason.none : LockReason.progress,
        isOpened: allComplete,
      ),
    );

    return Unit(
      id: 'unit_${trackId}_$unitNumber',
      unitNumber: unitNumber,
      title: title,
      trackId: trackId,
      isFree: isFree,
      nodes: List.unmodifiable(nodes),
    );
  }

  List<Unit> _chunkIntoUnits(
    List<TrackLessonDto> all, {
    required bool isPremium,
  }) {
    final units = <Unit>[];
    const chunkSize = 6;
    for (var i = 0; i < all.length; i += chunkSize) {
      final end = (i + chunkSize < all.length) ? i + chunkSize : all.length;
      final chunk = all.sublist(i, end);
      final unitNum = (i ~/ chunkSize) + 1;
      units.add(
        _buildUnit(
          unitNumber: unitNum,
          title: 'Unit $unitNum',
          lessons: chunk,
          isFree: unitNum == 1 || isPremium,
        ),
      );
    }
    return List.unmodifiable(units);
  }
}
