import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/review/data/mock_phrase_repository.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/review/presentation/screens/review_screen.dart';
import 'package:peddi/features/review/presentation/widgets/phrase_detail_sheet.dart';
import 'package:peddi/features/review/presentation/widgets/phrase_filter_chips.dart';
import 'package:peddi/features/review/presentation/widgets/phrase_tile.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildSubject({
    required MockPhraseRepository phraseRepo,
    required FakeSpeechService fakeTts,
  }) {
    return ProviderScope(
      overrides: [
        phraseRepositoryProvider.overrideWithValue(phraseRepo),
        textToSpeechServiceProvider.overrideWithValue(fakeTts),
      ],
      child: const MaterialApp(home: ReviewScreen()),
    );
  }

  group('ReviewScreen Filled State Tests', () {
    late MockPhraseRepository repo;
    late FakeSpeechService fakeTts;

    setUp(() {
      repo = MockPhraseRepository(
        samplePhrases: MockPhraseRepository.defaultSamplePhrases,
      );
      fakeTts = FakeSpeechService();
    });

    testWidgets('Renders phrase list and filters correctly', (tester) async {
      await tester.pumpWidget(buildSubject(phraseRepo: repo, fakeTts: fakeTts));
      await tester.pumpAndSettle();

      // Verify phrases are rendered
      expect(find.byType(PhraseTile), findsNWidgets(5));
      expect(find.text('¿Dónde está el baño?'), findsOneWidget);
      expect(find.text(AppStrings.phrasesMetCount(5)), findsOneWidget);

      // Filter by Tricky
      await tester.tap(
        find.descendant(
          of: find.byType(PhraseFilterChips),
          matching: find.text(AppStrings.filterTricky),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PhraseTile), findsNWidgets(2));
      expect(find.text('¿Dónde está el baño?'), findsOneWidget);
      expect(find.text(AppStrings.phrasesMetCount(2)), findsOneWidget);

      // Filter by Saved
      await tester.tap(
        find.descendant(
          of: find.byType(PhraseFilterChips),
          matching: find.text(AppStrings.filterSaved),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PhraseTile), findsNWidgets(2));
      expect(find.text('¿Dónde está el baño?'), findsOneWidget);

      // Reset to All
      await tester.tap(
        find.descendant(
          of: find.byType(PhraseFilterChips),
          matching: find.text(AppStrings.filterAll),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PhraseTile), findsNWidgets(5));
    });

    testWidgets('Tapping TTS audio button speaks phrase text', (tester) async {
      await tester.pumpWidget(buildSubject(phraseRepo: repo, fakeTts: fakeTts));
      await tester.pumpAndSettle();

      // Find first audio icon button
      final audioButtons = find.byIcon(Icons.volume_up_outlined);
      expect(audioButtons, findsWidgets);

      await tester.tap(audioButtons.first);
      await tester.pump();

      expect(fakeTts.lastSpokenText, '¿Dónde está el baño?');
      expect(fakeTts.lastLocale, 'es-ES');
    });

    testWidgets('Tapping phrase tile opens PhraseDetailSheet', (tester) async {
      await tester.pumpWidget(buildSubject(phraseRepo: repo, fakeTts: fakeTts));
      await tester.pumpAndSettle();

      await tester.tap(find.text('¿Dónde está el baño?'));
      await tester.pumpAndSettle();

      expect(find.byType(PhraseDetailSheet), findsOneWidget);
      expect(find.text('Box'), findsOneWidget);
      expect(find.text('Seen'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
    });
  });
}
