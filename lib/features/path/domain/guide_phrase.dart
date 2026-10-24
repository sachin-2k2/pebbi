/// Represents a single vocabulary or key phrase inside a unit guidebook.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class GuidePhrase {
  const GuidePhrase({
    required this.id,
    required this.targetText,
    required this.meaning,
    this.helperLine,
    required this.audioLocale,
    this.audioAsset,
    this.slowAudioAsset,
    this.isRtl = false,
  });

  final String id;
  final String targetText;
  final String meaning;
  final String? helperLine;
  final String audioLocale;
  final String? audioAsset;
  final String? slowAudioAsset;
  final bool isRtl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuidePhrase &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          targetText == other.targetText &&
          meaning == other.meaning &&
          helperLine == other.helperLine &&
          audioLocale == other.audioLocale &&
          audioAsset == other.audioAsset &&
          slowAudioAsset == other.slowAudioAsset &&
          isRtl == other.isRtl;

  @override
  int get hashCode =>
      id.hashCode ^
      targetText.hashCode ^
      meaning.hashCode ^
      helperLine.hashCode ^
      audioLocale.hashCode ^
      audioAsset.hashCode ^
      slowAudioAsset.hashCode ^
      isRtl.hashCode;
}
