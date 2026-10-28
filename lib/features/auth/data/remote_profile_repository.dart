import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';
import 'dtos/current_user_response_dto.dart';
import 'mock_profile_repository.dart';

/// Remote implementation of [ProfileRepository] fetching profile from `GET /api/me`.
///
/// Follows API-V2.md §9 & AGENTS.md §2 & §5:
/// - Fetches current user profile via authenticated endpoint `GET /api/me`.
/// - Fallback to in-memory/local cache on connection failure (offline-first).
class RemoteProfileRepository implements ProfileRepository {
  RemoteProfileRepository({
    required ApiClient apiClient,
    ProfileRepository? localFallback,
    this.onSessionExpired,
    this.onNetworkFailure,
  }) : _apiClient = apiClient,
       _localFallback = localFallback ?? MockProfileRepository();

  final ApiClient _apiClient;
  final ProfileRepository _localFallback;
  final void Function(String userId)? onSessionExpired;
  final VoidCallback? onNetworkFailure;

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final session = await _apiClient.tokenStorage.getActiveSession();
    // If not authenticated (guest user), load from local cache
    if (session == null || session.token.isEmpty) {
      return _localFallback.getCurrentProfile();
    }

    try {
      debugPrint('[RemoteProfileRepository] ════════════════════════════════════════');
      debugPrint('[RemoteProfileRepository] 🌐 GET ${_apiClient.config.baseUrl}/api/me');
      debugPrint('[RemoteProfileRepository] 🔑 Active User: ${session.userId}');

      final response = await _apiClient.get('/api/me');

      debugPrint('[RemoteProfileRepository] ✅ Response [${response.statusCode}]: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
        final dto = CurrentUserResponseDto.fromJson(data);
        final profile = dto.user.toDomain();
        await _localFallback.saveProfile(profile);
        return profile;
      }

      return await _localFallback.getCurrentProfile();
    } on DioException catch (e) {
      debugPrint('[RemoteProfileRepository] ❌ DioException [${e.response?.statusCode}]: ${e.response?.data}');
      debugPrint('[RemoteProfileRepository] ❌ Error details: ${e.message}');

      if (e.response?.statusCode == 401) {
        // Session rejected (Rule 5): keep local data, trigger session expiry flow
        onSessionExpired?.call(session.userId);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Network problem (Rule 4): report offline
        onNetworkFailure?.call();
      }

      // Offline-first fallback: keeps local data (Rule 5)
      return await _localFallback.getCurrentProfile();
    } catch (e, stack) {
      debugPrint('[RemoteProfileRepository] 💥 Unexpected exception: $e\n$stack');
      return await _localFallback.getCurrentProfile();
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _localFallback.saveProfile(profile);
  }

  @override
  Future<void> clearProfile() async {
    await _localFallback.clearProfile();
  }
}
