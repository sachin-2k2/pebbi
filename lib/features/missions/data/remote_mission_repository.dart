import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../domain/mission_brief.dart';
import '../domain/mission_category.dart';
import '../domain/mission_mode.dart';
import '../domain/mission_repository.dart';
import '../domain/mission_summary.dart';
import '../domain/mission_support.dart';
import '../domain/today_mission.dart';
import 'dtos/mission_detail_dto.dart';
import 'dtos/missions_response_dto.dart';
import 'dtos/today_mission_dto.dart';
import 'mock_mission_repository.dart';

/// Remote implementation of [MissionRepository] communicating with `/api/missions/*`.
///
/// Follows AGENTS.md §2.1, §2.2 & §5 (<150 lines).
class RemoteMissionRepository implements MissionRepository {
  RemoteMissionRepository({
    required ApiClient apiClient,
    MissionRepository? fallbackRepository,
    this.onSessionExpired,
  }) : _apiClient = apiClient,
       _fallback = fallbackRepository ?? MockMissionRepository();

  final ApiClient _apiClient;
  final MissionRepository _fallback;
  final void Function(String)? onSessionExpired;
  List<MissionCategory>? _cachedCategories;

  @override
  Future<TodayMission?> getTodayMission({required String targetLanguageCode, required String userId}) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>('/api/missions/today');
      if (res.data != null) return TodayMissionDto.tryParse(res.data!)?.toTodayMission();
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    return null;
  }

  @override
  Future<List<MissionCategory>> getCategories({required String targetLanguageCode}) async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) return _cachedCategories!;
    try {
      final res = await _apiClient.get<Map<String, dynamic>>('/api/missions');
      if (res.data != null) {
        final dto = MissionsResponseDto.fromJson(res.data!);
        final cats = dto.toCategories();
        if (cats.isNotEmpty) return _cachedCategories = cats;
      }
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    return const [];
  }

  @override
  Future<List<MissionSummary>> getMissions({required String targetLanguageCode, required String userId, String? category}) async {
    try {
      final params = (category != null && category.isNotEmpty && category.toLowerCase() != 'all') ? {'category': category} : null;
      debugPrint('[RemoteMissionRepository] 🌐 GET /api/missions $params');
      final res = await _apiClient.get<Map<String, dynamic>>('/api/missions', queryParameters: params);
      if (res.data != null) {
        final dto = MissionsResponseDto.fromJson(res.data!);
        if (dto.categories.isNotEmpty) _cachedCategories = dto.toCategories();
        return dto.toMissionSummaries();
      }
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    return const [];
  }

  @override
  Future<void> startMission({required String missionId}) async {
    try {
      await _apiClient.post<Map<String, dynamic>>('/api/missions/$missionId/start');
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    await _fallback.startMission(missionId: missionId);
  }

  @override
  Future<void> completeMission({required String missionId}) async {
    try {
      await _apiClient.post<Map<String, dynamic>>('/api/missions/$missionId/complete');
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    await _fallback.completeMission(missionId: missionId);
  }

  @override
  Future<void> updateMissionStatus({required String userId, required String missionId, required MissionStatus status}) async {
    if (status == MissionStatus.inProgress) await startMission(missionId: missionId);
    if (status == MissionStatus.done) await completeMission(missionId: missionId);
    await _fallback.updateMissionStatus(userId: userId, missionId: missionId, status: status);
  }

  @override
  Future<void> completeTodayMission({required String userId}) async {
    final today = await getTodayMission(targetLanguageCode: 'es', userId: userId);
    if (today != null) await completeMission(missionId: today.mission.id);
    await _fallback.completeTodayMission(userId: userId);
  }

  @override
  Future<MissionBrief?> loadBrief({
    required String missionId,
    required String userId,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>('/api/missions/$missionId');
      if (res.data != null) {
        return MissionDetailDto.fromJson(res.data!).toMissionBrief(targetLanguageCode: targetLanguageCode);
      }
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    return _fallback.loadBrief(
      missionId: missionId,
      userId: userId,
      targetLanguageCode: targetLanguageCode,
      explanationLanguageCode: explanationLanguageCode,
    );
  }

  @override
  Future<MissionMode> getDefaultMode({required String userId}) => _fallback.getDefaultMode(userId: userId);
  @override
  Future<void> saveDefaultMode({required String userId, required MissionMode mode}) => _fallback.saveDefaultMode(userId: userId, mode: mode);
  @override
  Future<MissionSupport> getDefaultSupport({required String userId}) => _fallback.getDefaultSupport(userId: userId);
  @override
  Future<void> saveDefaultSupport({required String userId, required MissionSupport support}) => _fallback.saveDefaultSupport(userId: userId, support: support);

  Future<void> _handleAuth(DioException e) async {
    if (e.response?.statusCode == 401) {
      final s = await _apiClient.tokenStorage.getActiveSession();
      if (s != null) onSessionExpired?.call(s.userId);
    }
  }
}
