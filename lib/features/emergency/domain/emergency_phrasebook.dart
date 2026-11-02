import 'emergency_phrase.dart';

/// Domain model representing a language-specific emergency phrasebook.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports (<150 lines).
class EmergencyPhrasebook {
  const EmergencyPhrasebook({
    required this.languageCode,
    required this.languageName,
    required this.phrases,
    required this.isReviewed,
    this.title,
    this.subtitle,
    this.disclaimer,
  });

  /// Target language code (e.g. 'es', 'fr', 'de', 'ja', 'ar').
  final String languageCode;

  /// Display name of the target language (e.g. 'Spanish', 'French').
  final String languageName;

  /// Curated emergency phrases.
  final List<EmergencyPhrase> phrases;

  /// Whether the phrases for this language have been verified by native reviewers.
  final bool isReviewed;

  /// Optional custom title from the backend.
  final String? title;

  /// Optional custom subtitle from the backend.
  final String? subtitle;

  /// Optional disclaimer text from the backend.
  final String? disclaimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyPhrasebook &&
          runtimeType == other.runtimeType &&
          languageCode == other.languageCode &&
          languageName == other.languageName &&
          isReviewed == other.isReviewed &&
          title == other.title &&
          subtitle == other.subtitle &&
          disclaimer == other.disclaimer;

  @override
  int get hashCode => Object.hash(
    languageCode,
    languageName,
    isReviewed,
    title,
    subtitle,
    disclaimer,
  );
}
