import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/review/data/mock_notes_repository.dart';
import 'package:peddi/features/review/data/mock_phrase_repository.dart';
import 'package:peddi/features/review/domain/phrase.dart';

void main() {
  group('Review & Library User Isolation Tests (AGENTS.md §6)', () {
    setUp(() {
      MockNotesRepository.resetSharedCache();
    });

    test(
      'User A saves phrases and reads notes, User B sees clean state',
      () async {
        // User A session
        final phraseRepoA = MockPhraseRepository();
        final notesRepoA = MockNotesRepository(userId: 'user_A');

        // User A stars a phrase
        await phraseRepoA.savePhrase(
          const Phrase(
            id: 'phrase_custom_1',
            targetText: '¡Buen viaje!',
            meaning: 'Have a good trip!',
            languageCode: 'es',
            isSaved: true,
          ),
          userId: 'user_A',
        );

        // User A reads and caches a note
        final noteA = await notesRepoA.openNote('ser_vs_estar', isOnline: true);
        expect(noteA, isNotNull);
        expect(notesRepoA.isNoteCached('ser_vs_estar'), isTrue);

        final phrasesA = await phraseRepoA.getPhrases(
          userId: 'user_A',
          languageCode: 'es',
        );
        final notesA = await notesRepoA.getNotes(
          languageCode: 'es',
          levelId: 'A1',
        );

        expect(phrasesA.where((p) => p.isSaved).length, 1);
        expect(notesA.firstWhere((n) => n.id == 'ser_vs_estar').isRead, isTrue);

        // User A logs out, User B logs in
        final phraseRepoB = MockPhraseRepository();
        final notesRepoB = MockNotesRepository(userId: 'user_B');

        final phrasesB = await phraseRepoB.getPhrases(
          userId: 'user_B',
          languageCode: 'es',
        );
        final notesB = await notesRepoB.getNotes(
          languageCode: 'es',
          levelId: 'A1',
        );

        // User B sees ZERO saved phrases of User A
        expect(phrasesB.where((p) => p.isSaved).isEmpty, isTrue);

        // User B sees the note as UNREAD
        expect(
          notesB.firstWhere((n) => n.id == 'ser_vs_estar').isRead,
          isFalse,
        );

        // But the cached note body is STILL available offline for User B
        final noteOfflineB = await notesRepoB.openNote(
          'ser_vs_estar',
          isOnline: false,
        );
        expect(noteOfflineB, isNotNull);
        expect(noteOfflineB!.id, 'ser_vs_estar');
      },
    );
  });
}
