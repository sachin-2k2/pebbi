import 'guide_note.dart';
import 'guide_phrase.dart';

/// Complete guidebook data structure for an individual learning path unit.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class UnitGuide {
  const UnitGuide({
    required this.unitId,
    required this.title,
    required this.subtitleKey,
    this.keyPhrases = const [],
    this.notes = const [],
    required this.languageCode,
    required this.explanationLanguageCode,
    this.isCached = false,
  });

  final String unitId;
  final String title;
  final String subtitleKey;
  final List<GuidePhrase> keyPhrases;
  final List<GuideNote> notes;
  final String languageCode;
  final String explanationLanguageCode;
  final bool isCached;

  bool get hasKeyPhrases => keyPhrases.isNotEmpty;
  bool get hasNotes => notes.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitGuide &&
          runtimeType == other.runtimeType &&
          unitId == other.unitId &&
          title == other.title &&
          subtitleKey == other.subtitleKey &&
          languageCode == other.languageCode &&
          explanationLanguageCode == other.explanationLanguageCode &&
          isCached == other.isCached;

  @override
  int get hashCode =>
      unitId.hashCode ^
      title.hashCode ^
      subtitleKey.hashCode ^
      languageCode.hashCode ^
      explanationLanguageCode.hashCode ^
      isCached.hashCode;
}
