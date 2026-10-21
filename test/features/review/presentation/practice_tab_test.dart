import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/review/data/mock_practice_repository.dart';
import 'package:peddi/features/review/domain/practice_summary.dart';
import 'package:peddi/features/review/domain/review_segment.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/review/presentation/screens/review_screen.dart';
import 'package:peddi/features/review/presentation/widgets/practice_coming_soon_note.dart';
import 'package:peddi/features/review/presentation/widgets/practice_room_tile.dart';
import 'package:peddi/features/review/presentation/widgets/practice_start_button.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildSubject({MockPracticeRepository? practiceRepo}) {
    return ProviderScope(
      overrides: [
        if (practiceRepo != null)
          practiceRepositoryProvider.overrideWithValue(practiceRepo),
        reviewSegmentProvider.overrideWith((ref) => ReviewSegment.practice),
        textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
      ],
      child: const MaterialApp(home: ReviewScreen()),
    );
  }

  group('PracticeTab Widget Tests (Matching Image 1)', () {
    testWidgets('Renders all elements of Practice segment faithfully', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 1. Shared Header
      expect(find.text(AppStrings.reviewPhrasesLearnedTitle), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // 2. Segmented Tabs with Practice selected
      expect(find.text(AppStrings.tabPractice), findsOneWidget);

      // 3. Invite Card
      expect(find.text(AppStrings.inviteCardTitle), findsOneWidget);

      // 4. Three Practice Tiles
      expect(find.byType(PracticeRoomTile), findsNWidgets(3));

      // 2-minute practice tile
      expect(find.text(AppStrings.practice2MinTitle(2)), findsOneWidget);
      expect(find.text(AppStrings.practice2MinSubtitle), findsOneWidget);
      expect(find.byType(PracticeStartButton), findsOneWidget);

      // Flashcards tile
      expect(find.text(AppStrings.practiceFlashcardsTitle), findsOneWidget);
      expect(
        find.text(AppStrings.practiceFlashcardsSubtitle(0)),
        findsOneWidget,
      );

      // Tricky phrases tile
      expect(find.text(AppStrings.practiceTrickyTitle), findsOneWidget);
      expect(find.text(AppStrings.practiceTrickySubtitle(0)), findsOneWidget);

      // 5. Coming soon note
      expect(find.byType(PracticeComingSoonNote), findsOneWidget);
      expect(find.text(AppStrings.practiceComingSoonNote), findsOneWidget);

      // 6. Count line
      expect(find.text(AppStrings.phrasesMetCount(0)), findsOneWidget);
    });

    testWidgets('Tapping 2-min practice with 0 count shows notice SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.practice2MinTitle(2)));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.practiceUnlockFirstLesson), findsOneWidget);
    });

    testWidgets('Tapping Flashcards with 0 count shows notice SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.practiceFlashcardsTitle));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.practiceNoFlashcards), findsOneWidget);
    });

    testWidgets('Tapping Tricky phrases with 0 count shows notice SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(AppStrings.practiceTrickyTitle));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.practiceTrickyTitle));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.practiceNoTricky), findsOneWidget);
    });

    testWidgets('Renders populated practice counts correctly', (tester) async {
      final repo = MockPracticeRepository(
        initialSummary: const PracticeSummary(
          reviewedPhraseCount: 15,
          flashcardCount: 8,
          trickyCount: 4,
          isMixAvailable: true,
        ),
      );

      await tester.pumpWidget(buildSubject(practiceRepo: repo));
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.practiceFlashcardsSubtitle(8)),
        findsOneWidget,
      );
      expect(find.text(AppStrings.practiceTrickySubtitle(4)), findsOneWidget);
      expect(find.text(AppStrings.phrasesMetCount(15)), findsOneWidget);
    });
  });
}
