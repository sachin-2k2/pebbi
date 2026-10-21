import '../domain/correction_style.dart';
import '../domain/free_talk_repository.dart';
import '../domain/free_talk_topic.dart';

/// In-memory mock implementation of [FreeTalkRepository].
///
/// Follows AGENTS.md §1 & §6: Implements per-user persistence in memory
/// until real backend API integration.
class MockFreeTalkRepository implements FreeTalkRepository {
  MockFreeTalkRepository({
    this.shouldFail = false,
    this.supportedLanguages = const {'es', 'fr', 'de', 'ja', 'ar'},
  });

  final bool shouldFail;
  final Set<String> supportedLanguages;

  /// Per-user stored correction style settings for strict user isolation.
  final Map<String, CorrectionStyle> _userStyles = {};

  static const List<FreeTalkTopic> _defaultTopics = [
    FreeTalkTopic(id: 'today', label: 'Today'),
    FreeTalkTopic(id: 'food', label: 'Food'),
    FreeTalkTopic(id: 'work', label: 'Work'),
    FreeTalkTopic(id: 'hobbies', label: 'Hobbies'),
    FreeTalkTopic(id: 'family', label: 'Family'),
    FreeTalkTopic(id: 'news', label: 'News'),
    FreeTalkTopic(id: 'dreams', label: 'Dreams'),
    FreeTalkTopic(id: 'custom', label: 'My own', isCustom: true),
  ];

  @override
  Future<List<FreeTalkTopic>> getTopics({
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to load Free Talk topics.');
    }

    if (!supportedLanguages.contains(targetLanguageCode)) {
      return const [];
    }

    return _defaultTopics;
  }

  @override
  Future<CorrectionStyle> getDefaultCorrectionStyle({
    required String userId,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to load correction style preference.');
    }
    return _userStyles[userId] ?? CorrectionStyle.gentle;
  }

  @override
  Future<void> saveDefaultCorrectionStyle({
    required String userId,
    required CorrectionStyle style,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to persist correction style preference.');
    }
    _userStyles[userId] = style;
  }
}
