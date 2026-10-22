/// Token representing an individual word or segment within a phrase.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// Data-driven tokenization supports non-spaced languages (e.g. Japanese, Chinese).
class PhraseToken {
  const PhraseToken({
    required this.id,
    required this.text,
    this.meaning,
    this.isSaved = false,
  });

  /// Unique identifier of the token within the curriculum/dictionary.
  final String id;

  /// Display text of the token in target language.
  final String text;

  /// Optional contextual meaning or translation of the single token.
  final String? meaning;

  /// Whether this token is currently saved in the user's phrasebook.
  final bool isSaved;

  PhraseToken copyWith({
    String? id,
    String? text,
    String? meaning,
    bool? isSaved,
  }) {
    return PhraseToken(
      id: id ?? this.id,
      text: text ?? this.text,
      meaning: meaning ?? this.meaning,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhraseToken &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          meaning == other.meaning &&
          isSaved == other.isSaved;

  @override
  int get hashCode => Object.hash(id, text, meaning, isSaved);
}
