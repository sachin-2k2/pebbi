import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/review/data/mock_notes_repository.dart';
import 'package:peddi/features/review/domain/practice_availability.dart';
import 'package:peddi/features/review/domain/practice_mode.dart';
import 'package:peddi/features/review/domain/practice_summary.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('Practice & Library Domain Tests (Pure Dart, 0 Flutter Imports)', () {
    test('PracticeAvailability evaluation correctly gates empty counts', () {
      const emptySummary = PracticeSummary();

      // mix2min with 0 count
      final mixResult = evaluatePracticeAvailability(
        PracticeMode.mix2min,
        emptySummary,
      );
      expect(mixResult.isAvailable, isFalse);
      expect(mixResult.status, PracticeAvailabilityStatus.unlockFirstLesson);

      // flashcards with 0 count
      final flashResult = evaluatePracticeAvailability(
        PracticeMode.flashcards,
        emptySummary,
      );
      expect(flashResult.isAvailable, isFalse);
      expect(flashResult.status, PracticeAvailabilityStatus.noFlashcardsYet);

      // tricky with 0 count
      final trickyResult = evaluatePracticeAvailability(
        PracticeMode.tricky,
        emptySummary,
      );
      expect(trickyResult.isAvailable, isFalse);
      expect(trickyResult.status, PracticeAvailabilityStatus.noTrickyPhrases);

      // Populated readiness
      const activeSummary = PracticeSummary(
        reviewedPhraseCount: 5,
        flashcardCount: 12,
        trickyCount: 3,
        isMixAvailable: true,
      );

      expect(
        evaluatePracticeAvailability(
          PracticeMode.mix2min,
          activeSummary,
        ).isAvailable,
        isTrue,
      );
      expect(
        evaluatePracticeAvailability(
          PracticeMode.flashcards,
          activeSummary,
        ).isAvailable,
        isTrue,
      );
      expect(
        evaluatePracticeAvailability(
          PracticeMode.tricky,
          activeSummary,
        ).isAvailable,
        isTrue,
      );
    });

    test('ICU plural copy formats correctly for cards and phrases', () {
      expect(
        AppStrings.practiceFlashcardsSubtitle(0),
        '0 cards · flipped both ways',
      );
      expect(
        AppStrings.practiceFlashcardsSubtitle(1),
        '1 card · flipped both ways',
      );
      expect(
        AppStrings.practiceFlashcardsSubtitle(12),
        '12 cards · flipped both ways',
      );

      expect(
        AppStrings.practiceTrickySubtitle(0),
        '0 phrases want another look',
      );
      expect(
        AppStrings.practiceTrickySubtitle(1),
        '1 phrase wants another look',
      );
      expect(
        AppStrings.practiceTrickySubtitle(5),
        '5 phrases want another look',
      );

      expect(AppStrings.phrasebookSavedCount(0), '0 saved');
      expect(AppStrings.phrasebookSavedCount(1), '1 saved');
      expect(AppStrings.phrasebookSavedCount(8), '8 saved');
    });

    test(
      'MockNotesRepository caches note body upon open and reports event',
      () async {
        MockNotesRepository.resetSharedCache();
        final repo = MockNotesRepository(userId: 'user_123');

        // Notes are uncached initially
        expect(repo.isNoteCached('ser_vs_estar'), isFalse);

        // Online open caches note body
        final note = await repo.openNote('ser_vs_estar', isOnline: true);
        expect(note, isNotNull);
        expect(note!.id, 'ser_vs_estar');
        expect(repo.isNoteCached('ser_vs_estar'), isTrue);
        expect(repo.reportedOpenedEvents, contains('ser_vs_estar'));

        // Re-opening when offline succeeds because it was cached
        final offlineNote = await repo.openNote(
          'ser_vs_estar',
          isOnline: false,
        );
        expect(offlineNote, isNotNull);

        // Opening uncached note when offline returns null
        final uncachedOffline = await repo.openNote(
          'greetings_culture',
          isOnline: false,
        );
        expect(uncachedOffline, isNull);
      },
    );
  });
}
