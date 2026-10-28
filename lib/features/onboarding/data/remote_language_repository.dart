import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../domain/language_option.dart';
import '../domain/language_repository.dart';
import '../domain/learnable_language.dart';
import '../domain/learnable_language_repository.dart';
import 'dtos/language_dto.dart';
import 'mock_language_repository.dart';

/// Remote and cached implementation of [LanguageRepository] and [LearnableLanguageRepository].
///
/// Follows AGENTS.md §2, API-V2.md §6 & §2:
/// - GET /api/languages/native (public, device-level cache, bundled fallback).
/// - GET /api/languages/learn?native_language=<code> (public, keyed cache, no bundled fallback).
class RemoteLanguageRepository
    implements LanguageRepository, LearnableLanguageRepository {
  RemoteLanguageRepository({
    required ApiClient apiClient,
    SharedPreferences? prefs,
    AssetBundle? bundle,
  }) : _apiClient = apiClient,
       _prefs = prefs,
       _bundle = bundle;

  final ApiClient _apiClient;
  SharedPreferences? _prefs;
  final AssetBundle? _bundle;

  static const String _nativeCacheKey = 'cached_native_languages_v1';
  static const String _learnCachePrefix = 'cached_learn_languages_';
  static const String fallbackAssetPath =
      'assets/data/native_languages_fallback.json';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  List<LanguageOption> getExplanationLanguages() =>
      MockLanguageRepository.defaultLanguages;

  @override
  List<LearnableLanguage> getLearnableLanguages() => const [];

  @override
  Future<List<LanguageOption>> getNativeLanguages() async {
    try {
      final response = await _apiClient.get('/api/languages/native');
      final list = _parseNativeList(response.data);
      if (list.isNotEmpty) {
        final prefs = await _getPrefs();
        await prefs.setString(_nativeCacheKey, jsonEncode(response.data));
        return list;
      }
    } catch (_) {
      // Fallback to cache or bundled asset on failure
    }

    final cached = await loadCachedNativeLanguages();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    return loadBundledFallbackNativeLanguages();
  }

  @override
  Future<List<LearnableLanguage>> getLearnLanguages(String nativeCode) async {
    try {
      final response = await _apiClient.get(
        '/api/languages/learn',
        queryParameters: {'native_language': nativeCode},
      );
      final list = _parseLearnList(response.data);
      final prefs = await _getPrefs();
      await prefs.setString(
        '$_learnCachePrefix$nativeCode',
        jsonEncode(response.data),
      );
      return list;
    } on DioException catch (e) {
      final cached = await loadCachedLearnLanguages(nativeCode);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      throw ApiErrorMapper.map(e);
    } catch (e) {
      final cached = await loadCachedLearnLanguages(nativeCode);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<LanguageOption>?> loadCachedNativeLanguages() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_nativeCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      final list = _parseNativeList(decoded);
      return list.isNotEmpty ? list : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<LearnableLanguage>?> loadCachedLearnLanguages(
    String nativeCode,
  ) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('$_learnCachePrefix$nativeCode');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      final list = _parseLearnList(decoded);
      return list.isNotEmpty ? list : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<LanguageOption>> loadBundledFallbackNativeLanguages() async {
    try {
      final jsonStr = _bundle != null
          ? await _bundle.loadString(fallbackAssetPath)
          : await rootBundle.loadString(fallbackAssetPath);
      final decoded = jsonDecode(jsonStr);
      final list = _parseNativeList(decoded);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _parseNativeList(jsonDecode(_defaultBundledJson));
  }

  static const String _defaultBundledJson = '''[
  {"code":"ml","name":"മലയാളം","english_name":"Malayalam","script_glyph":"മ","translations_reviewed":false},
  {"code":"hi","name":"हिन्दी","english_name":"Hindi","script_glyph":"अ","translations_reviewed":false},
  {"code":"ta","name":"தமிழ்","english_name":"Tamil","script_glyph":"த","translations_reviewed":false},
  {"code":"te","name":"తెలుగు","english_name":"Telugu","script_glyph":"తె","translations_reviewed":false},
  {"code":"kn","name":"ಕನ್ನಡ","english_name":"Kannada","script_glyph":"ಕ","translations_reviewed":false},
  {"code":"es","name":"Español","english_name":"Spanish","script_glyph":"Ñ","translations_reviewed":false},
  {"code":"ar","name":"العربية","english_name":"Arabic","script_glyph":"ع","translations_reviewed":false},
  {"code":"fr","name":"Français","english_name":"French","script_glyph":"Ç","translations_reviewed":false},
  {"code":"de","name":"Deutsch","english_name":"German","script_glyph":"Ä","translations_reviewed":false},
  {"code":"en","name":"English","english_name":"English","script_glyph":"A","translations_reviewed":true}
]''';

  List<LanguageOption> _parseNativeList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => NativeLanguageDto.fromJson(item).toDomain())
        .toList();
  }

  List<LearnableLanguage> _parseLearnList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => LearnLanguageDto.fromJson(item).toDomain())
        .toList();
  }
}
