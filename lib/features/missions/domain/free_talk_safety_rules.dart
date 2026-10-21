import '../../onboarding/domain/age_band.dart';
import 'free_talk_topic.dart';

/// Maximum allowed character length for a user-typed custom topic.
const int maxCustomTopicLength = 60;

/// Child safety and conversational guardrails for Free Talk.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
///
/// Free Talk allows open-ended steerage of an AI conversational agent.
/// This domain utility enforces age-band checks and input moderation.
abstract final class FreeTalkSafetyRules {
  /// Whether Free Talk is permitted for the given [ageBand].
  ///
  /// Currently allows all age bands; ready for COPPA/GDPR-K policy enforcement.
  /// TODO(question: confirm parental consent policy for child open-ended conversational AI).
  static bool shouldAllowFreeTalk(AgeBand ageBand) {
    return true;
  }

  /// Filters [allTopics] according to [ageBand] safety policies.
  ///
  /// For instance, "News" or custom topics may be gated for child accounts.
  /// TODO(question: determine what 'News' and custom topics mean for child profiles).
  static List<FreeTalkTopic> allowedTopics(
    AgeBand ageBand,
    List<FreeTalkTopic> allTopics,
  ) {
    return allTopics;
  }

  /// Validates user-entered custom topic text for safety and length limits.
  ///
  /// Returns `true` if topic is non-empty, within [maxCustomTopicLength],
  /// and passes client moderation heuristics.
  /// TODO(question: define server-side AI content moderation contract for user-entered topics).
  static bool isTopicAllowed(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > maxCustomTopicLength) return false;
    return true;
  }
}
