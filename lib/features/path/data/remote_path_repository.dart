import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../domain/path_repository.dart';
import '../domain/track.dart';
import '../domain/unit.dart';
import 'dtos/track_dto.dart';
import 'dtos/track_response_dto.dart';
import 'mock_path_repository.dart';

/// Remote implementation of [PathRepository] fetching track curriculum from `GET /api/lessons/track/{track_id}`.
///
/// Follows AGENTS.md §2 & §5:
/// - Fetches track lessons with lock state and progress from backend.
/// - Offline-first fallback to local path repository on network disconnection.
class RemotePathRepository implements PathRepository {
  RemotePathRepository({
    required ApiClient apiClient,
    PathRepository? localFallback,
    this.onSessionExpired,
    this.onNetworkFailure,
  }) : _apiClient = apiClient,
       _localFallback = localFallback ?? MockPathRepository();

  final ApiClient _apiClient;
  final PathRepository _localFallback;
  final void Function(String userId)? onSessionExpired;
  final VoidCallback? onNetworkFailure;

  /// Default language-neutral fallback tracks matching backend curriculum.
  static const List<Track> defaultTracks = [
    Track(
      id: 'daily',
      title: 'Daily Conversations',
      emoji: '🌍',
      hasContent: true,
      description: 'Everyday conversations for real life',
    ),
    Track(
      id: 'job',
      title: 'Career & Workplace',
      emoji: '💼',
      hasContent: true,
      description: 'Professional communication for interviews and career success',
    ),
  ];

  @override
  Future<List<Track>> getTracks() async {
    final session = await _apiClient.tokenStorage.getActiveSession();
    if (session == null || session.token.isEmpty || session.userId.startsWith('guest_')) {
      return defaultTracks;
    }

    try {
      debugPrint('[RemotePathRepository] 🌐 GET ${_apiClient.config.baseUrl}/api/tracks');
      final response = await _apiClient.get('/api/tracks');
      final data = response.data;
      if (data is List) {
        final tracks = data
            .whereType<Map>()
            .map((item) => TrackDto.fromJson(Map<String, dynamic>.from(item)).toDomain())
            .toList(growable: false);
        if (tracks.isNotEmpty) {
          return tracks;
        }
      }
      return defaultTracks;
    } catch (e) {
      debugPrint('[RemotePathRepository] ⚠️ Failed to fetch tracks: $e. Using default tracks.');
      return defaultTracks;
    }
  }

  @override
  Future<List<Unit>> getUnitsForTrack(
    String trackId, {
    required String userId,
    bool isPremium = false,
  }) async {
    final session = await _apiClient.tokenStorage.getActiveSession();
    // If not authenticated (guest user), load from local cache/fallback
    if (session == null || session.token.isEmpty || session.userId.startsWith('guest_')) {
      return _localFallback.getUnitsForTrack(
        trackId,
        userId: userId,
        isPremium: isPremium,
      );
    }

    try {
      debugPrint('[RemotePathRepository] ════════════════════════════════════════');
      debugPrint('[RemotePathRepository] 🌐 GET ${_apiClient.config.baseUrl}/api/lessons/track/$trackId');
      debugPrint('[RemotePathRepository] 🔑 Active User: ${session.userId}');

      final response = await _apiClient.get('/api/lessons/track/$trackId');

      debugPrint('[RemotePathRepository] ✅ Response [${response.statusCode}]: ${response.data}');

      final data = response.data;
      if (data != null) {
        final dto = TrackResponseDto.fromJson(data, defaultTrackId: trackId);
        final units = dto.toUnits(isPremium: isPremium);
        if (units.isNotEmpty) {
          return units;
        }
      }

      return await _localFallback.getUnitsForTrack(
        trackId,
        userId: userId,
        isPremium: isPremium,
      );
    } on DioException catch (e) {
      debugPrint('[RemotePathRepository] ❌ DioException [${e.response?.statusCode}]: ${e.response?.data}');
      debugPrint('[RemotePathRepository] ❌ Error details: ${e.message}');

      if (e.response?.statusCode == 401) {
        onSessionExpired?.call(session.userId);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        onNetworkFailure?.call();
      }

      return await _localFallback.getUnitsForTrack(
        trackId,
        userId: userId,
        isPremium: isPremium,
      );
    } catch (e, stack) {
      debugPrint('[RemotePathRepository] 💥 Unexpected exception: $e\n$stack');
      return await _localFallback.getUnitsForTrack(
        trackId,
        userId: userId,
        isPremium: isPremium,
      );
    }
  }
}
