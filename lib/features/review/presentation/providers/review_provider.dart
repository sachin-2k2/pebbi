import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/fake_share_service.dart';
import '../../data/mock_invite_repository.dart';
import '../../data/mock_notes_repository.dart';
import '../../data/mock_phrase_repository.dart';
import '../../data/mock_practice_repository.dart';
import '../../data/mock_translation_repository.dart';
import '../../domain/grammar_note.dart';
import '../../domain/grammar_note_summary.dart';
import '../../domain/invite_link.dart';
import '../../domain/invite_repository.dart';
import '../../domain/notes_repository.dart';
import '../../domain/phrase.dart';
import '../../domain/phrase_filter.dart';
import '../../domain/phrase_repository.dart';
import '../../domain/practice_room.dart';
import '../../domain/practice_summary.dart';
import '../../domain/review_segment.dart';
import '../../domain/review_summary.dart';
import '../../domain/share_service.dart';
import '../../domain/translation_repository.dart';

/// Provider for [PhraseRepository].
final phraseRepositoryProvider = Provider<PhraseRepository>((ref) {
  return MockPhraseRepository();
});

/// Provider for [InviteRepository].
final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  return MockInviteRepository();
});

/// Provider for [TranslationRepository].
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return MockTranslationRepository();
});

/// Provider for [ShareService].
final shareServiceProvider = Provider<ShareService>((ref) {
  return FakeShareService();
});

/// Selected review tab segment (Phrases, Practice, Library).
final reviewSegmentProvider = StateProvider<ReviewSegment>((ref) {
  return ReviewSegment.phrases;
});

/// Active phrase filter selection (All, Tricky, New, Saved).
final phraseFilterProvider = StateProvider<PhraseFilter>((ref) {
  return PhraseFilter.all;
});

/// Simulated or device offline mode status.
final reviewOfflineProvider = StateProvider<bool>((ref) => false);

/// Whether to show the pronunciation helper line (romanization) under target phrases.
final showHelperLineProvider = StateProvider<bool>((ref) => true);

/// Target language code for learned phrases.
final reviewTargetLanguageCodeProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.targetLanguageCode ?? 'es';
});

/// Async provider for the active user's learned phrases in the current target language.
final phrasesListProvider = FutureProvider<List<Phrase>>((ref) async {
  final repo = ref.watch(phraseRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final lang = ref.watch(reviewTargetLanguageCodeProvider);
  final userId = user?.userId ?? 'guest_default';

  return repo.getPhrases(userId: userId, languageCode: lang);
});

/// Derived provider returning phrases filtered by [phraseFilterProvider].
final filteredPhrasesProvider = Provider<List<Phrase>>((ref) {
  final phrasesAsync = ref.watch(phrasesListProvider);
  final filter = ref.watch(phraseFilterProvider);

  return phrasesAsync.maybeWhen(
    data: (phrases) => filter.apply(phrases),
    orElse: () => const [],
  );
});

/// Derived provider computing summary metrics from [phrasesListProvider].
final reviewSummaryProvider = Provider<ReviewSummary>((ref) {
  final phrasesAsync = ref.watch(phrasesListProvider);

  return phrasesAsync.maybeWhen(
    data: (phrases) => ReviewSummary.fromPhrases(phrases),
    orElse: () => ReviewSummary.empty,
  );
});

/// Async provider for the user's invite link.
final inviteLinkProvider = FutureProvider<InviteLink>((ref) async {
  final repo = ref.watch(inviteRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final userId = user?.userId ?? 'guest_default';

  return repo.getInviteLink(userId: userId);
});

/// Provider for [MockPracticeRepository].
final practiceRepositoryProvider = Provider<MockPracticeRepository>((ref) {
  return MockPracticeRepository();
});

/// Async provider for practice summary counts.
final practiceSummaryProvider = FutureProvider<PracticeSummary>((ref) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getPracticeSummary();
});

/// Provider for practice room card definitions.
final practiceRoomsProvider = Provider<List<PracticeRoom>>((ref) {
  return PracticeRoom.defaultRooms;
});

/// Provider for [NotesRepository] isolated by active user ID.
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  final userId = user?.userId ?? 'guest_default';
  return MockNotesRepository(userId: userId);
});

/// Async provider for grammar and culture notes list in the target language.
final grammarNotesListProvider = FutureProvider<List<GrammarNoteSummary>>((
  ref,
) async {
  final repo = ref.watch(notesRepositoryProvider);
  final lang = ref.watch(reviewTargetLanguageCodeProvider);
  return repo.getNotes(languageCode: lang, levelId: 'A1');
});

/// Currently selected note ID for TwoPaneLayout preview or detail navigation.
final selectedNoteIdProvider = StateProvider<String?>((ref) => null);

/// Async provider for opening the selected note's detail body.
final activeNoteDetailProvider = FutureProvider<GrammarNote?>((ref) async {
  final noteId = ref.watch(selectedNoteIdProvider);
  if (noteId == null) return null;
  final repo = ref.watch(notesRepositoryProvider);
  final isOffline = ref.watch(reviewOfflineProvider);
  return repo.openNote(noteId, isOnline: !isOffline);
});

/// Derived provider returning only saved phrases for the Phrasebook section.
final savedPhrasesProvider = Provider<List<Phrase>>((ref) {
  final phrasesAsync = ref.watch(phrasesListProvider);
  return phrasesAsync.maybeWhen(
    data: (phrases) => phrases.where((p) => p.isSaved).toList(),
    orElse: () => const [],
  );
});
