import '../../../../core/network/api_client.dart';
import '../domain/chat_message.dart';
import '../domain/debrief_ref.dart';
import '../domain/session_config.dart';
import '../domain/session_goal.dart';
import '../domain/session_start.dart';
import '../domain/session_turn_result.dart';
import '../domain/suggestion.dart';
import 'dtos/free_talk_dtos.dart';

/// Network handler for Free Talk endpoints (Start, Turn, Debrief).
///
/// Follows AGENTS.md §2.1 & §5 (<150 lines).
class RemoteFreeTalkHandler {
  RemoteFreeTalkHandler({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static String normalizeTopic(String raw) {
    final trimmed = raw.trim();
    const presets = {
      'today': 'Today', 'food': 'Food', 'work': 'Work',
      'hobbies': 'Hobbies', 'family': 'Family', 'news': 'News', 'dreams': 'Dreams',
    };
    return presets[trimmed.toLowerCase()] ?? trimmed;
  }

  Future<SessionStart> startSession(
    SessionConfig config, {
    required void Function(String sid, List<SessionGoal> goals, String topic) onSessionRegistered,
  }) async {
    final rawTopic = config.freeTalkTopic ??
        (config.missionId.startsWith('freetalk_') ? config.missionId.substring(9) : config.missionId);
    final topic = normalizeTopic(rawTopic.isEmpty ? 'Food' : rawTopic);

    final res = await _apiClient.post<Map<String, dynamic>>('/api/missions/freetalk/start', data: {
      'topic': topic,
      'correction_style': config.correctionStyle.id,
      'learning_language': config.targetLanguageCode,
    });

    final dto = FreeTalkStartResponseDto.fromJson(res.data ?? const {});
    final sid = dto.sessionId.isNotEmpty ? dto.sessionId : 'freetalk_${DateTime.now().millisecondsSinceEpoch}';

    final goals = dto.goals.map((g) => SessionGoal(id: g.id.isNotEmpty ? g.id : g.goal, text: g.goal)).toList();
    onSessionRegistered(sid, goals, topic);

    final initialMsg = ChatMessage(
      id: 'msg_freetalk_init',
      author: MessageAuthor.character,
      targetText: dto.initialMessage.characterText,
      translationText: dto.initialMessage.translation,
      timestamp: DateTime.now(),
    );

    final suggestions = dto.options
        .map((o) => Suggestion(id: 'opt_${o.text.hashCode}', text: o.text, translation: o.translation))
        .toList();

    return SessionStart(
      sessionId: sid,
      initialMessage: initialMsg,
      suggestions: suggestions,
      goals: goals,
      characterName: dto.characterName.isNotEmpty ? dto.characterName : 'Tutotoco',
      characterRole: dto.characterRole.isNotEmpty ? dto.characterRole : 'a friendly conversation partner',
      emoji: '🦉',
    );
  }

  Future<TurnResult> sendTurn({
    required String userText,
    required String clientTurnId,
    required List<SessionGoal> goals,
    required Set<String> completedGoalSet,
    String? learningLanguage,
  }) async {
    final payload = <String, dynamic>{'message': userText};
    if (learningLanguage != null && learningLanguage.isNotEmpty) {
      payload['learning_language'] = learningLanguage;
    }
    final res = await _apiClient.post<Map<String, dynamic>>(
      '/api/missions/freetalk/message',
      data: payload,
    );

    final dto = FreeTalkMessageResponseDto.fromJson(res.data ?? const {});
    for (final cg in dto.completedGoals) {
      for (final g in goals) {
        if (g.text.toLowerCase().trim() == cg.toLowerCase().trim() || g.id == cg) {
          completedGoalSet.add(g.id);
        }
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

    final suggestions = dto.options
        .map((o) => Suggestion(id: 'opt_${o.text.hashCode}', text: o.text, translation: o.translation))
        .toList();

    return TurnResult(
      characterMessage: charMsg,
      suggestions: suggestions,
      completedGoalIds: completedGoalSet.toList(),
      correction: dto.liveCorrection,
      isFinished: dto.isFinished,
    );
  }

  Future<DebriefRef> finishSession({
    required String sessionId,
    required int turnCount,
    required List<SessionGoal> goals,
    required List<String> completedGoalIds,
    required String topic,
  }) async {
    final res = await _apiClient.post<Map<String, dynamic>>('/api/missions/freetalk/debrief', data: const {});
    final dto = FreeTalkDebriefResponseDto.fromJson(res.data ?? const {});
    final corrections = dto.debrief?.corrections
            .map((c) => DebriefCorrection(userSaid: c.userSaid, betterWay: c.betterWay, explanation: c.explanation))
            .toList() ??
        const [];

    return DebriefRef(
      sessionId: sessionId,
      missionId: 'freetalk',
      turnsCount: dto.totalMessages > 0 ? dto.totalMessages : turnCount,
      completedGoalIds: completedGoalIds,
      totalGoals: goals.isNotEmpty ? goals.length : 3,
      characterName: 'Tutotoco',
      characterRole: 'conversation partner',
      completedGoalTexts: dto.completedGoals.isNotEmpty ? dto.completedGoals : goals.map((g) => g.text).toList(),
      starsEarned: 25,
      xpEarned: 20,
      praise: dto.debrief?.praise,
      corrections: corrections,
      vocabularyRecap: dto.debrief?.vocabularyRecap ?? const [],
    );
  }
}
