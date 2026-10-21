import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/review/data/mock_notes_repository.dart';
import 'package:peddi/features/review/data/mock_phrase_repository.dart';
import 'package:peddi/features/review/domain/review_segment.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/review/presentation/screens/review_screen.dart';
import 'package:peddi/features/review/presentation/widgets/note_tile.dart';
import 'package:peddi/features/review/presentation/widgets/note_trailing_dots.dart';
import 'package:peddi/features/review/presentation/widgets/phrase_tile.dart';
import 'package:peddi/features/review/presentation/widgets/phrasebook_section.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildSubject({
    MockPhraseRepository? phraseRepo,
    MockNotesRepository? notesRepo,
    bool isOffline = false,
  }) {
    return ProviderScope(
      overrides: [
        if (phraseRepo != null)
          phraseRepositoryProvider.overrideWithValue(phraseRepo),
        if (notesRepo != null)
          notesRepositoryProvider.overrideWithValue(notesRepo),
        reviewSegmentProvider.overrideWith((ref) => ReviewSegment.library),
        reviewOfflineProvider.overrideWith((ref) => isOffline),
        textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
      ],
      child: const MaterialApp(home: ReviewScreen()),
    );
  }

  group('LibraryTab Widget Tests (Matching Image 2)', () {
    testWidgets('Renders all elements of Library segment faithfully', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 1. Shared Header & Tabs
      expect(find.text(AppStrings.reviewPhrasesLearnedTitle), findsOneWidget);
      expect(find.text(AppStrings.tabLibrary), findsOneWidget);

      // 2. Invite Card
      expect(find.text(AppStrings.inviteCardTitle), findsOneWidget);

      // 3. Phrasebook Section
      expect(find.byType(PhrasebookSection), findsOneWidget);
      expect(find.text(AppStrings.phrasebookTitle), findsOneWidget);
      expect(find.text(AppStrings.phrasebookSavedCount(0)), findsOneWidget);
      expect(find.text(AppStrings.phrasebookEmptyNote), findsOneWidget);

      // 4. Grammar and Culture Notes Section
      expect(find.text(AppStrings.grammarCultureNotesTitle), findsOneWidget);
      expect(
        find.text(AppStrings.grammarCultureNotesSubtitle('Spanish', 'A1')),
        findsOneWidget,
      );

      // 5. Three Note Tiles
      expect(find.byType(NoteTile), findsNWidgets(3));
      expect(find.text('ser vs estar'), findsOneWidget);
      expect(find.text('el café, la cuenta'), findsOneWidget);
      expect(find.text('Greetings'), findsOneWidget);

      // Trailing dots
      expect(find.byType(NoteTrailingDots), findsNWidgets(3));
    });

    testWidgets('Populated Phrasebook displays saved phrase tiles with star', (
      tester,
    ) async {
      final phraseRepo = MockPhraseRepository(
        samplePhrases: MockPhraseRepository.defaultSamplePhrases,
      );

      await tester.pumpWidget(buildSubject(phraseRepo: phraseRepo));
      await tester.pumpAndSettle();

      // 2 phrases are saved in defaultSamplePhrases
      expect(find.text(AppStrings.phrasebookSavedCount(2)), findsOneWidget);
      expect(find.byType(PhraseTile), findsNWidgets(2));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    });

    testWidgets('Tapping star on saved phrase unsaves it', (tester) async {
      final phraseRepo = MockPhraseRepository(
        samplePhrases: MockPhraseRepository.defaultSamplePhrases,
      );

      await tester.pumpWidget(buildSubject(phraseRepo: phraseRepo));
      await tester.pumpAndSettle();

      // Tap first star button to unsave
      final starButtons = find.byIcon(Icons.star_rounded);
      expect(starButtons, findsNWidgets(2));

      await tester.tap(starButtons.first);
      await tester.pumpAndSettle();

      // Now 1 saved phrase remains
      expect(find.text(AppStrings.phrasebookSavedCount(1)), findsOneWidget);
    });

    testWidgets('Offline uncached note shows SnackBar notice', (tester) async {
      MockNotesRepository.resetSharedCache();
      final notesRepo = MockNotesRepository(userId: 'test_user');

      await tester.pumpWidget(
        buildSubject(notesRepo: notesRepo, isOffline: true),
      );
      await tester.pumpAndSettle();

      // Tap uncached note
      await tester.ensureVisible(find.text('ser vs estar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ser vs estar'));
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.noteOfflineUnavailableNotice),
        findsOneWidget,
      );
    });

    testWidgets('Tapping note marks note as read and reports event', (
      tester,
    ) async {
      final notesRepo = MockNotesRepository(userId: 'test_user');

      await tester.pumpWidget(
        buildSubject(notesRepo: notesRepo, isOffline: false),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('ser vs estar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ser vs estar'));
      await tester.pumpAndSettle();

      expect(notesRepo.reportedOpenedEvents, contains('ser_vs_estar'));
    });
  });
}
