import 'phrase.dart';
import 'review_summary.dart';

/// Repository interface for managing learned phrases per user and language.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class PhraseRepository {
  /// Fetches learned phrases for [userId] in [languageCode].
  Future<List<Phrase>> getPhrases({
    required String userId,
    required String languageCode,
  });

  /// Toggles the bookmark/saved status for [phraseId] of [userId].
  Future<void> toggleBookmark({
    required String userId,
    required String phraseId,
    required bool isSaved,
  });

  /// Adds a newly saved phrase to the user's collection.
  Future<void> addPhrase({required String userId, required Phrase phrase});

  /// Convenience helper to save or add a phrase.
  Future<void> savePhrase(Phrase phrase, {String userId = 'guest_default'}) =>
      addPhrase(userId: userId, phrase: phrase);

  /// Convenience helper to toggle bookmark status.
  Future<void> toggleSaved(
    String phraseId, {
    String userId = 'guest_default',
    bool? isSaved,
  }) => toggleBookmark(
    userId: userId,
    phraseId: phraseId,
    isSaved: isSaved ?? true,
  );

  /// Computes summary metrics for [userId] in [languageCode].
  Future<ReviewSummary> getSummary({
    required String userId,
    required String languageCode,
  });
}
