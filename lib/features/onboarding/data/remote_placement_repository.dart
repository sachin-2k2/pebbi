import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../domain/language_level.dart';
import '../domain/placement_answer.dart';
import '../domain/placement_intro.dart';
import '../domain/placement_question.dart';
import '../domain/placement_repository.dart';
import '../domain/placement_submission_result.dart';
import 'dtos/placement_intro_dto.dart';
import 'dtos/placement_questions_response_dto.dart';
import 'dtos/placement_submit_request_dto.dart';
import 'dtos/placement_submit_response_dto.dart';
import 'mapping/language_code_mapper.dart';

/// Real remote implementation of [PlacementRepository] backed by [ApiClient].
///
/// Follows AGENTS.md §2 & API-UPDATES.md §3:
/// - Explicitly sends query parameters `target_language` and `native_language`.
/// - Checks [LanguageCodeMapper.hasPlacementQuiz] defensively.
/// - Errors mapped to domain failures via [ApiErrorMapper].
class RemotePlacementRepository implements PlacementRepository {
  RemotePlacementRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<PlacementIntro> getIntro({
    required String nativeLanguage,
    required String targetLanguage,
  }) async {
    try {
      final nativeApi = LanguageCodeMapper.toApi(nativeLanguage);
      final targetApi = LanguageCodeMapper.toApi(targetLanguage);
      debugPrint(
        '[RemotePlacementRepository] 🌐 GET ${_apiClient.config.baseUrl}/api/placement/intro?native_language=$nativeApi&target_language=$targetApi',
      );
      final response = await _apiClient.get(
        '/api/placement/intro',
        queryParameters: {
          'native_language': nativeApi,
          'target_language': targetApi,
        },
      );
      debugPrint(
        '[RemotePlacementRepository] ✅ Intro Response [${response.statusCode}]: ${response.data}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PlacementIntroDto.fromJson(data).toDomain();
      }
      return const PlacementIntro(pebbiSays: '', subtitle: '');
    } on DioException catch (e) {
      debugPrint(
        '[RemotePlacementRepository] ❌ Intro DioException [${e.response?.statusCode}]: ${e.response?.data}',
      );
      throw ApiErrorMapper.map(e);
    } catch (e) {
      debugPrint('[RemotePlacementRepository] 💥 Intro error: $e');
      rethrow;
    }
  }

  @override
  Future<PlacementQuestionSet> getQuestions({
    required String nativeLanguage,
    required String targetLanguage,
  }) async {
    final targetApi = LanguageCodeMapper.toApi(targetLanguage);
    final nativeApi = LanguageCodeMapper.toApi(nativeLanguage);
    debugPrint(
      '[RemotePlacementRepository] ════════════════════════════════════════',
    );
    debugPrint(
      '[RemotePlacementRepository] 🌐 GET ${_apiClient.config.baseUrl}/api/placement/questions?target_language=$targetApi&native_language=$nativeApi',
    );

    // If target language is unsupported by backend, return unavailable gracefully
    if (!LanguageCodeMapper.hasPlacementQuiz(targetLanguage)) {
      debugPrint(
        '[RemotePlacementRepository] ℹ️ $targetLanguage not in availablePlacementTargets',
      );
      return const PlacementQuestionSet(
        isAvailable: false,
        total: 0,
        questions: [],
        unavailableMessage:
            'Placement quiz unavailable for this language. Starting at Little.',
        defaultLevel: LanguageLevel.little,
      );
    }

    try {
      final response = await _apiClient.get(
        '/api/placement/questions',
        queryParameters: {
          'target_language': targetApi,
          'native_language': nativeApi,
        },
      );
      debugPrint(
        '[RemotePlacementRepository] ✅ Questions Response [${response.statusCode}]: ${response.data}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final dto = PlacementQuestionsResponseDto.fromJson(data);
        debugPrint(
          '[RemotePlacementRepository] 📦 Parsed ${dto.questions.length} questions, available=${dto.available}',
        );
        return dto.toDomain();
      }
      return const PlacementQuestionSet(
        isAvailable: false,
        total: 0,
        questions: [],
        defaultLevel: LanguageLevel.little,
      );
    } on DioException catch (e) {
      debugPrint(
        '[RemotePlacementRepository] ❌ Questions DioException [${e.response?.statusCode}]: ${e.response?.data}',
      );
      debugPrint('[RemotePlacementRepository] ❌ Error details: ${e.message}');
      throw ApiErrorMapper.map(e);
    } catch (e, stack) {
      debugPrint('[RemotePlacementRepository] 💥 Questions error: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<PlacementSubmissionResult> submitAnswers({
    required String nativeLanguage,
    required List<PlacementAnswer> answers,
  }) async {
    try {
      final requestDto = PlacementSubmitRequestDto(
        nativeLanguage: LanguageCodeMapper.toApi(nativeLanguage),
        answers: answers,
      );
      final payload = requestDto.toJson();
      debugPrint(
        '[RemotePlacementRepository] ════════════════════════════════════════',
      );
      debugPrint(
        '[RemotePlacementRepository] 🌐 POST ${_apiClient.config.baseUrl}/api/placement/submit',
      );
      debugPrint('[RemotePlacementRepository] 📤 Payload: $payload');

      final response = await _apiClient.post(
        '/api/placement/submit',
        data: payload,
      );
      debugPrint(
        '[RemotePlacementRepository] ✅ Submit Response [${response.statusCode}]: ${response.data}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final res = PlacementSubmitResponseDto.fromJson(data);
        debugPrint(
          '[RemotePlacementRepository] 🎯 Score: ${res.score}/${res.total}, Level: ${res.level}',
        );
        return res.toDomain();
      }
      throw StateError(
        'Invalid response format received from placement submit.',
      );
    } on DioException catch (e) {
      debugPrint(
        '[RemotePlacementRepository] ❌ Submit DioException [${e.response?.statusCode}]: ${e.response?.data}',
      );
      throw ApiErrorMapper.map(e);
    } catch (e, stack) {
      debugPrint('[RemotePlacementRepository] 💥 Submit error: $e\n$stack');
      rethrow;
    }
  }
}
