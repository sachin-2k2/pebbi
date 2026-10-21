/// Status tags for learned phrases.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum PhraseStatus {
  none('none'),
  tricky('tricky'),
  newPhrase('new'),
  mastered('mastered');

  const PhraseStatus(this.id);
  final String id;
}

/// Domain model representing a phrase met by the learner.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class Phrase {
  const Phrase({
    required this.id,
    required this.languageCode,
    required this.targetText,
    required this.meaning,
    this.helperLine,
    this.audioUrl,
    this.status = PhraseStatus.none,
    this.isSaved = false,
    this.seenCount = 0,
    this.wrongCount = 0,
    this.lastSeen,
    this.userId,
    this.createdAt,
  });

  final String id;
  final String languageCode;
  final String targetText;
  final String meaning;
  final String? helperLine;
  final String? audioUrl;
  final PhraseStatus status;
  final bool isSaved;
  final int seenCount;
  final int wrongCount;
  final DateTime? lastSeen;
  final String? userId;
  final DateTime? createdAt;

  int get timesSeen => seenCount;
  int get timesCorrect => (seenCount - wrongCount).clamp(0, seenCount);
  int get box => (seenCount >= 5 && wrongCount == 0)
      ? 3
      : (seenCount >= 3 && wrongCount <= 1 ? 2 : (seenCount >= 1 ? 1 : 0));

  Phrase copyWith({
    String? id,
    String? languageCode,
    String? targetText,
    String? meaning,
    String? helperLine,
    String? audioUrl,
    PhraseStatus? status,
    bool? isSaved,
    int? seenCount,
    int? wrongCount,
    DateTime? lastSeen,
  }) {
    return Phrase(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      targetText: targetText ?? this.targetText,
      meaning: meaning ?? this.meaning,
      helperLine: helperLine ?? this.helperLine,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      isSaved: isSaved ?? this.isSaved,
      seenCount: seenCount ?? this.seenCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phrase &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          languageCode == other.languageCode &&
          targetText == other.targetText &&
          meaning == other.meaning &&
          helperLine == other.helperLine &&
          audioUrl == other.audioUrl &&
          status == other.status &&
          isSaved == other.isSaved &&
          seenCount == other.seenCount &&
          wrongCount == other.wrongCount &&
          lastSeen == other.lastSeen;

  @override
  int get hashCode => Object.hash(
    id,
    languageCode,
    targetText,
    meaning,
    helperLine,
    audioUrl,
    status,
    isSaved,
    seenCount,
    wrongCount,
    lastSeen,
  );
}
