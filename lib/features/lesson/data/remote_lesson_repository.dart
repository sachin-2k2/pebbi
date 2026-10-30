import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../domain/lesson_repository.dart';
import '../domain/lesson_set.dart';
import 'dtos/check_answer_dto.dart';
import 'dtos/lesson_detail_dto.dart';
import 'dtos/lesson_user_progress_dto.dart';
import 'dtos/submit_lesson_dto.dart';
import 'mock_lesson_repository.dart';

/// Remote implementation of [LessonRepository] communicating with `/api/lessons/*`.
///
/// Follows AGENTS.md §2.1, §2.2 & §5:
/// - Fetches dynamic lesson items, phrases, translations, and questions.
/// - Offline-first fallback to mock lessons when network fails.
/// - Handles token expiration (401) cleanly.
class RemoteLessonRepository implements LessonRepository {
  RemoteLessonRepository({
    required ApiClient apiClient,
    LessonRepository fallbackRepository = const MockLessonRepository(),
    this.onSessionExpired,
  }) : _apiClient = apiClient,
       _fallbackRepository = fallbackRepository;

  final ApiClient _apiClient;
  final LessonRepository _fallbackRepository;
  final void Function(String)? onSessionExpired;

  @override
  Future<LessonSet> loadLesson(
    String stopId, {
    String? nativeLanguage,
    String? learningLanguage,
  }) async {
    final native = nativeLanguage ?? 'en';
    final target = learningLanguage ?? 'en';

    try {
      debugPrint(
        '[RemoteLessonRepository] ════════════════════════════════════════',
      );
      debugPrint(
        '[RemoteLessonRepository] 🌐 GET ${_apiClient.config.baseUrl}/api/lessons/$stopId?native_language=$native&learning_language=$target',
      );

      final response = await _apiClient.get(
        '/api/lessons/$stopId',
        queryParameters: {
          'native_language': native,
          'learning_language': target,
        },
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );

      debugPrint(
        '[RemoteLessonRepository] ✅ Response [${response.statusCode}]',
      );

      final data = response.data;
      if (data is Map) {
        final dto = LessonDetailDto.fromJson(Map<String, dynamic>.from(data));
        return dto.toLessonSet(
          learningLanguage: target,
          nativeLanguage: native,
        );
      }

      return await _fallbackRepository.loadLesson(
        stopId,
        nativeLanguage: native,
        learningLanguage: target,
      );
    } on DioException catch (e) {
      debugPrint(
        '[RemoteLessonRepository] ❌ DioException [${e.response?.statusCode}]: ${e.response?.data}',
      );
      if (e.response?.statusCode == 401) {
        final session = await _apiClient.tokenStorage.getActiveSession();
        if (session != null) onSessionExpired?.call(session.userId);
      }

      return await _fallbackRepository.loadLesson(
        stopId,
        nativeLanguage: native,
        learningLanguage: target,
      );
    } catch (e, stack) {
      debugPrint(
        '[RemoteLessonRepository] 💥 Unexpected exception: $e\n$stack',
      );
      return await _fallbackRepository.loadLesson(
        stopId,
        nativeLanguage: native,
        learningLanguage: target,
      );
    }
  }

  /// Calls `POST /api/lessons/{lesson_id}/check` to evaluate a single answer.
  @override
  Future<CheckAnswerResponseDto?> checkAnswer({
    required String lessonId,
    required String questionId,
    required String chosenAnswer,
  }) async {
    try {
      final req = CheckAnswerRequestDto(
        questionId: questionId,
        chosenAnswer: chosenAnswer,
      );
      debugPrint(
        '[RemoteLessonRepository] 🌐 POST ${_apiClient.config.baseUrl}/api/lessons/$lessonId/check',
      );
      debugPrint('[RemoteLessonRepository] 📦 Request Body: ${req.toJson()}');
      final response = await _apiClient.post(
        '/api/lessons/$lessonId/check',
        data: req.toJson(),
      );
      debugPrint(
        '[RemoteLessonRepository] ✅ checkAnswer [${response.statusCode}]: ${response.data}',
      );
      if (response.data is Map) {
        return CheckAnswerResponseDto.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '[RemoteLessonRepository] ❌ checkAnswer DioException [${e.response?.statusCode}]: ${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[RemoteLessonRepository] ❌ checkAnswer error: $e');
    }
    return null;
  }

  /// Calls `POST /api/lessons/{lesson_id}/submit` to submit finished quiz answers.
  @override
  Future<SubmitLessonResponseDto?> submitLesson({
    required String lessonId,
    required List<SubmitLessonAnswerItemDto> answers,
  }) async {
    try {
      final req = SubmitLessonRequestDto(answers: answers);
      debugPrint(
        '[RemoteLessonRepository] 🌐 POST ${_apiClient.config.baseUrl}/api/lessons/$lessonId/submit (${answers.length} answers)',
      );
      debugPrint('[RemoteLessonRepository] 📦 Request Body: ${req.toJson()}');
      final response = await _apiClient.post(
        '/api/lessons/$lessonId/submit',
        data: req.toJson(),
      );
      debugPrint(
        '[RemoteLessonRepository] ✅ submitLesson [${response.statusCode}]: ${response.data}',
      );
      if (response.data is Map) {
        return SubmitLessonResponseDto.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '[RemoteLessonRepository] ❌ submitLesson DioException [${e.response?.statusCode}]: ${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[RemoteLessonRepository] ❌ submitLesson error: $e');
    }
    return null;
  }

  /// Calls `GET /api/lessons/{lesson_id}/progress` to fetch user's past progress.
  Future<LessonUserProgressDto?> getProgress(String lessonId) async {
    try {
      final response = await _apiClient.get('/api/lessons/$lessonId/progress');
      if (response.data is Map) {
        return LessonUserProgressDto.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (e) {
      debugPrint('[RemoteLessonRepository] ❌ getProgress error: $e');
    }
    return null;
  }
}
