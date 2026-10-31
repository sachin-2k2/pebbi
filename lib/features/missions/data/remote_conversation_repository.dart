import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../review/domain/translation_repository.dart';
import '../domain/chat_message.dart';
import '../domain/conversation_repository.dart';
import '../domain/debrief_ref.dart';
import '../domain/session_config.dart';
import '../domain/session_goal.dart';
import '../domain/session_start.dart';
import '../domain/session_turn_result.dart';
import 'dtos/mission_detail_dto.dart';
import 'dtos/mission_message_response_dto.dart';
import 'mock_conversation_repository.dart';

/// Remote implementation of [ConversationRepository] for live role-play missions.
///
/// Follows AGENTS.md §2.1, §2.2 & §5 (<150 lines).
class RemoteConversationRepository implements ConversationRepository {
  RemoteConversationRepository({
    required ApiClient apiClient,
    TranslationRepository? translationRepository,
    ConversationRepository? fallbackRepository,
    this.onSessionExpired,
  }) : _apiClient = apiClient,
       _translationRepo = translationRepository,
       _fallback = fallbackRepository ?? MockConversationRepository();

  final ApiClient _apiClient;
  final TranslationRepository? _translationRepo;
  final ConversationRepository _fallback;
  final void Function(String)? onSessionExpired;

  final Map<String, List<SessionGoal>> _sessionGoals = {};
  final Map<String, Set<String>> _completedGoals = {};
  final Map<String, int> _turnCounts = {};
  final Map<String, String> _sessionMissionIds = {};

  @override
  Future<SessionStart> startSession(SessionConfig config) async {
    final mId = config.missionId;
    try {
      final startRes = await _apiClient.post<Map<String, dynamic>>('/api/missions/$mId/start');
      final detailRes = await _apiClient.get<Map<String, dynamic>>('/api/missions/$mId');
      final detail = detailRes.data != null ? MissionDetailDto.fromJson(detailRes.data!) : null;
      final initMsg = ((startRes.data ?? const {})['initial_message'] ?? detailRes.data?['initial_message']) as Map<String, dynamic>?;
      final charText = initMsg?['character_text']?.toString() ?? '¡Hola! ¿En qué puedo ayudarte?';
      final transText = initMsg?['translation']?.toString() ?? 'Hello! How can I help you?';
      final goals = detail?.goals.map((g) => SessionGoal(id: g.id.isNotEmpty ? g.id : g.goal, text: g.goal)).toList() ??
          [const SessionGoal(id: '1', text: 'Complete conversation')];

      final sid = 'session_${DateTime.now().millisecondsSinceEpoch}';
      _sessionMissionIds[sid] = mId;
      _sessionGoals[sid] = goals;
      _completedGoals[sid] = <String>{};
      _turnCounts[sid] = 0;

      final initialMsg = ChatMessage(
        id: 'msg_init',
        author: MessageAuthor.character,
        targetText: charText,
        translationText: transText,
        timestamp: DateTime.now(),
      );

      return SessionStart(
        sessionId: sid,
        initialMessage: initialMsg,
        suggestions: const [],
        goals: goals,
        characterName: detail?.characterName.isNotEmpty == true ? detail!.characterName : 'Lucía',
        characterRole: detail?.characterRole.isNotEmpty == true ? detail!.characterRole : 'barista',
        emoji: detail?.icon.isNotEmpty == true ? detail!.icon : '☕',
      );
    } on DioException catch (e) {
      await _handleAuth(e);
      return _fallback.startSession(config);
    } catch (_) {
      return _fallback.startSession(config);
    }
  }

  @override
  Future<TurnResult> sendTurn({required String sessionId, required String clientTurnId, required String userText, required SessionConfig config}) async {
    final mId = _sessionMissionIds[sessionId] ?? config.missionId;
    _turnCounts[sessionId] = (_turnCounts[sessionId] ?? 0) + 1;
    try {
      final res = await _apiClient.post<Map<String, dynamic>>('/api/missions/$mId/message', data: {'message': userText});
      if (res.data != null) {
        final dto = MissionMessageResponseDto.fromJson(res.data!);
        final goals = _sessionGoals[sessionId] ?? const [];
        final completedSet = _completedGoals[sessionId] ??= <String>{};
        for (final cg in dto.completedGoals) {
          for (final g in goals) {
            if (g.text.toLowerCase().trim() == cg.toLowerCase().trim() || g.id == cg) completedSet.add(g.id);
          }
        }
        final charMsg = ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          clientTurnId: clientTurnId,
          author: MessageAuthor.character,
          targetText: dto.characterText,
          translationText: dto.translation,
          timestamp: DateTime.now(),
        );
        return TurnResult(characterMessage: charMsg, completedGoalIds: completedSet.toList(), isFinished: dto.isFinished);
      }
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    return _fallback.sendTurn(sessionId: sessionId, clientTurnId: clientTurnId, userText: userText, config: config);
  }

  @override
  Future<DebriefRef> finishSession(String sessionId) async {
    final mId = _sessionMissionIds[sessionId] ?? 'order-a-coffee';
    try {
      await _apiClient.post<Map<String, dynamic>>('/api/missions/$mId/complete');
    } on DioException catch (e) {
      await _handleAuth(e);
    } catch (_) {}
    return DebriefRef(
      sessionId: sessionId,
      missionId: mId,
      turnsCount: _turnCounts[sessionId] ?? 1,
      completedGoalIds: _completedGoals[sessionId]?.toList() ?? const [],
      totalGoals: _sessionGoals[sessionId]?.length ?? 3,
    );
  }

  @override
  Future<String> translateForUser({required String text, required String targetLanguageCode, required String explanationLanguageCode}) =>
      _translationRepo?.translate(query: text, targetLanguageCode: targetLanguageCode, explanationLanguageCode: explanationLanguageCode) ??
      _fallback.translateForUser(text: text, targetLanguageCode: targetLanguageCode, explanationLanguageCode: explanationLanguageCode);

  @override
  Future<void> reportMessage({required String sessionId, required String messageId, required String reason}) =>
      _fallback.reportMessage(sessionId: sessionId, messageId: messageId, reason: reason);

  Future<void> _handleAuth(DioException e) async {
    if (e.response?.statusCode == 401) {
      final s = await _apiClient.tokenStorage.getActiveSession();
      if (s != null) onSessionExpired?.call(s.userId);
    }
  }
}
