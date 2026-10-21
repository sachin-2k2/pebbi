import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/review/data/fake_share_service.dart';
import 'package:peddi/features/review/data/mock_phrase_repository.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/review/presentation/screens/review_screen.dart';
import 'package:peddi/features/review/presentation/widgets/add_phrase_sheet.dart';
import 'package:peddi/features/review/presentation/widgets/library_tab.dart';
import 'package:peddi/features/review/presentation/widgets/practice_tab.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildSubject({
    FakeShareService? shareService,
    MockPhraseRepository? phraseRepo,
  }) {
    return ProviderScope(
      overrides: [
        if (shareService != null)
          shareServiceProvider.overrideWithValue(shareService),
        if (phraseRepo != null)
          phraseRepositoryProvider.overrideWithValue(phraseRepo),
        textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
      ],
      child: const MaterialApp(home: ReviewScreen()),
    );
  }

  group('ReviewScreen Empty State Tests (Matching Design)', () {
    testWidgets('Renders all elements of empty state faithfully', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text(AppStrings.reviewPhrasesLearnedTitle), findsOneWidget);
      expect(
        find.text(AppStrings.reviewPhrasesLearnedSubtitle),
        findsOneWidget,
      );

      // Compact + button
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // 2. Segmented Tabs
      expect(find.text(AppStrings.tabPhrases), findsOneWidget);
      expect(find.text(AppStrings.tabPractice), findsOneWidget);
      expect(find.text(AppStrings.tabLibrary), findsOneWidget);

      // 3. Invite Card
      expect(find.text(AppStrings.inviteCardTitle), findsOneWidget);
      expect(find.text(AppStrings.inviteCopy), findsOneWidget);
      expect(find.text(AppStrings.inviteShareButton), findsOneWidget);

      // 4. Practise Tricky Phrases Button
      expect(find.text(AppStrings.practiseTrickyPhrasesButton), findsOneWidget);

      // 5. Filter Chips
      expect(find.text(AppStrings.filterAll), findsOneWidget);
      expect(find.text(AppStrings.filterTricky), findsOneWidget);
      expect(find.text(AppStrings.filterNew), findsOneWidget);
      expect(find.text(AppStrings.filterSaved), findsOneWidget);

      // 6. Search Count Line (0 phrases met)
      expect(find.text(AppStrings.phrasesMetCount(0)), findsOneWidget);

      // 7. Centered Empty State with Winking Mascot
      expect(find.text(AppStrings.reviewEmptyTitle), findsOneWidget);
      expect(find.text(AppStrings.reviewEmptySubtitle), findsOneWidget);
      final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
      expect(mascot.expression, PebbiExpression.winking);
    });

    testWidgets('Tapping + button opens AddPhraseSheet', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AddPhraseSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AddPhraseSheet),
          matching: find.text(AppStrings.addPhraseSheetTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Copy on Invite Card shows Copied feedback', (
      tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (message) async {
          if (message.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.inviteCopy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppStrings.inviteCopied), findsOneWidget);
    });

    testWidgets('Tapping Share calls ShareService', (tester) async {
      final fakeShare = FakeShareService();
      await tester.pumpWidget(buildSubject(shareService: fakeShare));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.inviteShareButton));
      await tester.pumpAndSettle();

      expect(fakeShare.shareCount, 1);
      expect(fakeShare.lastSharedLink, contains('base44.app'));
    });

    testWidgets(
      'Tapping Practise Tricky Phrases with 0 tricky phrases shows notice',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.practiseTrickyPhrasesButton));
        await tester.pumpAndSettle();

        expect(
          find.text(AppStrings.practiseTrickyNoPhrasesMessage),
          findsOneWidget,
        );
      },
    );

    testWidgets('Switching segmented tabs switches body view', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap "Practice" tab
      await tester.tap(find.text(AppStrings.tabPractice));
      await tester.pumpAndSettle();

      expect(find.byType(PracticeTab), findsOneWidget);
      expect(find.text(AppStrings.practiceFlashcardsTitle), findsOneWidget);

      // Tap "Library" tab
      await tester.tap(find.text(AppStrings.tabLibrary));
      await tester.pumpAndSettle();

      expect(find.byType(LibraryTab), findsOneWidget);
      expect(find.text(AppStrings.phrasebookTitle), findsOneWidget);
    });
  });
}
