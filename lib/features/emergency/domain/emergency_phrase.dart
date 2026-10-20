/// Domain model representing a single emergency survival phrase.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class EmergencyPhrase {
  const EmergencyPhrase({
    required this.id,
    required this.labels,
    required this.targetText,
    required this.ttsLocale,
    this.helperLine,
    this.genderNote,
    this.audioAsset,
  });

  /// Distinct phrase identifier across all language sets (e.g. 'need_doctor').
  final String id;

  /// Translated meaning labels keyed by explanation language code (e.g. {'en': 'I need a doctor'}).
  final Map<String, String> labels;

  /// The phrase in the target learning language (e.g. 'Necesito un médico').
  final String targetText;

  /// BCP-47 locale code for speech synthesis (e.g. 'es-ES', 'ja-JP').
  final String ttsLocale;

  /// Optional phonetic transliteration/romanization for non-Latin scripts (Japanese, Arabic).
  final String? helperLine;

  /// Internal note regarding grammatical gender or pointing context for the content team.
  final String? genderNote;

  /// Optional bundled native-speaker recorded audio clip asset path.
  final String? audioAsset;

  /// Resolves the phrase meaning in the learner's [explanationLanguageCode],
  /// falling back safely to English ('en') if translation is unreviewed.
  String getLabel(String explanationLanguageCode) {
    return labels[explanationLanguageCode] ??
        labels['en'] ??
        (labels.isNotEmpty ? labels.values.first : targetText);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyPhrase &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          targetText == other.targetText &&
          ttsLocale == other.ttsLocale &&
          helperLine == other.helperLine;

  @override
  int get hashCode => Object.hash(id, targetText, ttsLocale, helperLine);
}
