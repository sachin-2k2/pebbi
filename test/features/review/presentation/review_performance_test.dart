import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/review/data/mock_phrase_repository.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/review/presentation/screens/review_screen.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('ReviewScreen Performance Test (300 Phrases)', () {
    testWidgets('Smoothly handles 300 phrases with virtualization', (
      tester,
    ) async {
      final largePhrases = MockPhraseRepository.generateLargePhraseList(300);
      final repo = MockPhraseRepository(samplePhrases: largePhrases);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            phraseRepositoryProvider.overrideWithValue(repo),
            textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
          ],
          child: const MaterialApp(home: ReviewScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.phrasesMetCount(300)), findsOneWidget);

      // Fast fling scroll to verify virtualization and zero render jank/errors
      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -600),
        2000,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
