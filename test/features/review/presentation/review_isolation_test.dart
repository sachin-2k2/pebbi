import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/review/domain/phrase.dart';
import 'package:peddi/features/review/domain/phrase_repository.dart';
import 'package:peddi/features/review/domain/review_summary.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/review/presentation/screens/review_screen.dart';

class FakeMultiUserPhraseRepo implements PhraseRepository {
  final Map<String, List<Phrase>> _userPhrases = {};

  void setPhrases(String userId, List<Phrase> phrases) {
    _userPhrases[userId] = phrases;
  }

  @override
  Future<List<Phrase>> getPhrases({
    required String userId,
    required String languageCode,
  }) async {
    return _userPhrases[userId] ?? const [];
  }

  @override
  Future<void> toggleBookmark({
    required String userId,
    required String phraseId,
    required bool isSaved,
  }) async {}

  @override
  Future<void> addPhrase({
    required String userId,
    required Phrase phrase,
  }) async {}

  @override
  Future<void> savePhrase(
    Phrase phrase, {
    String userId = 'guest_default',
  }) async {}

  @override
  Future<void> toggleSaved(
    String phraseId, {
    String userId = 'guest_default',
    bool? isSaved,
  }) async {}

  @override
  Future<ReviewSummary> getSummary({
    required String userId,
    required String languageCode,
  }) async {
    final list = _userPhrases[userId] ?? const [];
    return ReviewSummary.fromPhrases(list);
  }
}

UserProfile _buildProfile(String userId) {
  return UserProfile(
    userId: userId,
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: const {},
    dailyGoalId: 'regular',
    reminderTime: const ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
    remindersEnabled: true,
    accentId: 'violet',
    plan: 'free',
  );
}

void main() {
  group('Review User Isolation Tests', () {
    testWidgets('Switching user switches phrase list without leakage', (
      tester,
    ) async {
      final repo = FakeMultiUserPhraseRepo();
      repo.setPhrases('user_a', [
        Phrase(
          id: 'phrase_a',
          userId: 'user_a',
          targetText: 'Phrase of User A',
          meaning: 'Meaning A',
          languageCode: 'es',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]);
      repo.setPhrases('user_b', [
        Phrase(
          id: 'phrase_b',
          userId: 'user_b',
          targetText: 'Phrase of User B',
          meaning: 'Meaning B',
          languageCode: 'es',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]);

      final fakeProfileRepo = MockProfileRepository(
        initialProfile: _buildProfile('user_a'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
            phraseRepositoryProvider.overrideWithValue(repo),
            textToSpeechServiceProvider.overrideWithValue(FakeSpeechService()),
          ],
          child: const MaterialApp(home: ReviewScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // User A's phrase is shown
      expect(find.text('Phrase of User A'), findsOneWidget);
      expect(find.text('Phrase of User B'), findsNothing);

      // Now switch user to User B
      final element = tester.element(find.byType(ReviewScreen));
      final container = ProviderScope.containerOf(element);
      await container
          .read(currentUserProvider.notifier)
          .saveProfile(_buildProfile('user_b'));

      await tester.pumpAndSettle();

      // User A's phrase is gone, User B's phrase is shown
      expect(find.text('Phrase of User A'), findsNothing);
      expect(find.text('Phrase of User B'), findsOneWidget);
    });
  });
}
