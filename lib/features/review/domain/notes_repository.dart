import 'grammar_note.dart';
import 'grammar_note_summary.dart';

/// Repository interface managing grammar and culture notes and offline caching.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
abstract class NotesRepository {
  /// Fetches notes for a given target language, user level, and explanation language.
  Future<List<GrammarNoteSummary>> getNotes({
    required String languageCode,
    required String levelId,
    String? explanationLanguage,
  });

  /// Opens a note. When online, caches the note body locally so it becomes readable offline.
  /// If offline and not cached, returns null.
  Future<GrammarNote?> openNote(String id, {bool isOnline = true});

  /// Reports a "note opened" event and updates user-isolated read state.
  Future<void> markNoteRead(String id);

  /// Checks if a note's body is cached in local device storage.
  bool isNoteCached(String id);
}
