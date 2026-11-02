import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../domain/emergency_phrasebook.dart';
import '../domain/emergency_repository.dart';
import 'bundled_emergency_repository.dart';
import 'dtos/emergency_response_dto.dart';

/// Remote + Offline Cached implementation of [EmergencyRepository].
///
/// Follows AGENTS.md §2.1, §2.2 & §5.1 (<150 lines):
/// - Fetches `/api/missions/emergency` with Bearer auth when online.
/// - Persists payload to local cache for 100% offline availability.
/// - Falls back to [BundledEmergencyRepository] if network and cache fail.
class RemoteEmergencyRepository implements EmergencyRepository {
  RemoteEmergencyRepository({
    required ApiClient apiClient,
    EmergencyRepository? fallbackRepository,
    SharedPreferences? sharedPreferences,
    String explanationLanguageCode = 'en',
  }) : _apiClient = apiClient,
       _fallback = fallbackRepository ?? BundledEmergencyRepository(),
       _prefs = sharedPreferences,
       _explanationLang = explanationLanguageCode;

  final ApiClient _apiClient;
  final EmergencyRepository _fallback;
  SharedPreferences? _prefs;
  final String _explanationLang;

  static const String _endpoint = '/api/missions/emergency';

  String _cacheKey(String lang) => 'emergency_phrasebook_cache_$lang';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<EmergencyPhrasebook?> getPhrasebook({
    required String targetLanguageCode,
  }) async {
    // 1. Try fetching from remote API
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(_endpoint);
      final data = response.data;
      if (data != null) {
        final dto = EmergencyResponseDto.fromJson(data);
        if (dto.phrases.isNotEmpty) {
          await _saveToCache(targetLanguageCode, jsonEncode(data));
          return dto.toDomain(
            targetLanguageCode: targetLanguageCode,
            explanationLanguageCode: _explanationLang,
          );
        }
      }
    } catch (_) {
      // Network failed, server offline, or unauthenticated; fall through to cache
    }

    // 2. Try loading from local offline cache
    final cached = await _loadFromCache(targetLanguageCode);
    if (cached != null) {
      return cached;
    }

    // 3. Fallback to bundled offline emergency catalog
    return _fallback.getPhrasebook(targetLanguageCode: targetLanguageCode);
  }

  @override
  Future<List<String>> getSupportedLanguages() {
    return _fallback.getSupportedLanguages();
  }

  Future<void> _saveToCache(String lang, String jsonStr) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_cacheKey(lang), jsonStr);
    } catch (_) {
      // Non-fatal cache write failure
    }
  }

  Future<EmergencyPhrasebook?> _loadFromCache(String lang) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_cacheKey(lang));
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final raw = jsonDecode(jsonStr);
        if (raw is Map<String, dynamic>) {
          final dto = EmergencyResponseDto.fromJson(raw);
          if (dto.phrases.isNotEmpty) {
            return dto.toDomain(
              targetLanguageCode: lang,
              explanationLanguageCode: _explanationLang,
            );
          }
        }
      }
    } catch (_) {
      // Corrupt cache; fall through
    }
    return null;
  }
}

