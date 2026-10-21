import 'correction_style.dart';
import 'free_talk_topic.dart';

/// Repository interface for fetching Free Talk curriculum topics and user preferences.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class FreeTalkRepository {
  /// Fetches the conversational topics catalog for [targetLanguageCode] explained in [explanationLanguageCode].
  Future<List<FreeTalkTopic>> getTopics({
    required String targetLanguageCode,
    required String explanationLanguageCode,
  });

  /// Retrieves the persisted default correction style for [userId].
  Future<CorrectionStyle> getDefaultCorrectionStyle({required String userId});

  /// Persists [style] as the default correction style for [userId].
  Future<void> saveDefaultCorrectionStyle({
    required String userId,
    required CorrectionStyle style,
  });
}
