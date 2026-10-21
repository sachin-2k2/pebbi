import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/review/domain/invite_safety_rules.dart';
import 'package:peddi/features/review/domain/phrase.dart';
import 'package:peddi/features/review/domain/phrase_filter.dart';
import 'package:peddi/features/review/domain/phrase_status_rules.dart';
import 'package:peddi/features/review/domain/review_summary.dart';

void main() {
  group('Review Domain Layer Tests (Pure Dart, 0 Flutter imports)', () {
    final phrase1 = Phrase(
      id: 'p1',
      userId: 'user_1',
      targetText: 'Hola',
      meaning: 'Hello',
      languageCode: 'es',
      status: PhraseStatus.mastered,
      seenCount: 5,
      wrongCount: 0,
      isSaved: true,
      createdAt: DateTime(2026, 1, 1),
    );

    final phrase2 = Phrase(
      id: 'p2',
      userId: 'user_1',
      targetText: 'Por favor',
      meaning: 'Please',
      languageCode: 'es',
      status: PhraseStatus.tricky,
      seenCount: 4,
      wrongCount: 3,
      isSaved: false,
      createdAt: DateTime(2026, 1, 2),
    );

    final phrase3 = Phrase(
      id: 'p3',
      userId: 'user_1',
      targetText: 'Gracias',
      meaning: 'Thank you',
      languageCode: 'es',
      status: PhraseStatus.newPhrase,
      seenCount: 0,
      wrongCount: 0,
      isSaved: false,
      createdAt: DateTime(2026, 1, 3),
    );

    final testPhrases = [phrase1, phrase2, phrase3];

    test('PhraseFilter.apply correctly filters phrases', () {
      expect(PhraseFilter.all.apply(testPhrases).length, 3);

      final trickyList = PhraseFilter.tricky.apply(testPhrases);
      expect(trickyList.length, 1);
      expect(trickyList.first.id, 'p2');

      final newList = PhraseFilter.newPhrases.apply(testPhrases);
      expect(newList.length, 1);
      expect(newList.first.id, 'p3');

      final savedList = PhraseFilter.saved.apply(testPhrases);
      expect(savedList.length, 1);
      expect(savedList.first.id, 'p1');
    });

    test('ReviewSummary calculates metrics accurately', () {
      final summary = ReviewSummary.fromPhrases(testPhrases);

      expect(summary.totalCount, 3);
      expect(summary.trickyCount, 1);
      expect(summary.newCount, 1);
      expect(summary.masteredCount, 1);
      expect(summary.savedCount, 1);
    });

    test('DefaultPhraseStatusRules classifies tricky, new, and mastered', () {
      const rules = DefaultPhraseStatusRules();

      expect(
        rules.determineStatus(box: 3, timesSeen: 4, timesCorrect: 4),
        PhraseStatus.mastered,
      );
      expect(
        rules.determineStatus(box: 0, timesSeen: 3, timesCorrect: 1),
        PhraseStatus.tricky,
      );
      expect(
        rules.determineStatus(box: 0, timesSeen: 0, timesCorrect: 0),
        PhraseStatus.newPhrase,
      );
    });

    test('InviteSafetyRules protects children under COPPA/GDPR-K', () {
      expect(InviteSafetyRules.canShareInvite(AgeBand.child), isFalse);
      expect(InviteSafetyRules.canShareInvite(AgeBand.teen), isTrue);
      expect(InviteSafetyRules.canShareInvite(AgeBand.adult), isTrue);
      expect(InviteSafetyRules.canShareInvite(null), isTrue);
    });
  });
}
