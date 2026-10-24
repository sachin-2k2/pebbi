import '../../domain/guide_note.dart';
import '../../domain/guide_phrase.dart';
import '../../domain/unit_guide.dart';

/// Provisional Data Transfer Object for key phrases in unit guidebooks.
class GuidePhraseDto {
  const GuidePhraseDto({
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

  GuidePhrase toDomain() => GuidePhrase(
    id: id,
    targetText: targetText,
    meaning: meaning,
    helperLine: helperLine,
    audioLocale: audioLocale,
    audioAsset: audioAsset,
    slowAudioAsset: slowAudioAsset,
    isRtl: isRtl,
  );
}

/// Provisional Data Transfer Object for guide notes.
class GuideNoteDto {
  const GuideNoteDto({
    required this.id,
    this.emoji,
    required this.title,
    required this.body,
    required this.tag,
    this.isRtl = false,
  });

  final String id;
  final String? emoji;
  final String title;
  final String body;
  final String tag;
  final bool isRtl;

  GuideNote toDomain() => GuideNote(
    id: id,
    emoji: emoji,
    title: title,
    body: body,
    tag: tag,
    isRtl: isRtl,
  );
}

/// Provisional Data Transfer Object for complete unit guidebooks.
class UnitGuideDto {
  const UnitGuideDto({
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
  final List<GuidePhraseDto> keyPhrases;
  final List<GuideNoteDto> notes;
  final String languageCode;
  final String explanationLanguageCode;
  final bool isCached;

  UnitGuide toDomain() => UnitGuide(
    unitId: unitId,
    title: title,
    subtitleKey: subtitleKey,
    keyPhrases: keyPhrases.map((p) => p.toDomain()).toList(),
    notes: notes.map((n) => n.toDomain()).toList(),
    languageCode: languageCode,
    explanationLanguageCode: explanationLanguageCode,
    isCached: isCached,
  );
}
