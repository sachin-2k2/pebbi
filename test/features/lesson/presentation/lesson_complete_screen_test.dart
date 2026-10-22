import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/design_system/star_row.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/lesson/data/mock_progress_repository.dart';
import 'package:peddi/features/lesson/domain/lesson_completion.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_completion_provider.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:peddi/features/lesson/presentation/screens/lesson_complete_screen.dart';
import 'package:peddi/features/lesson/presentation/widgets/finish/completion_stat_row.dart';
import 'package:peddi/features/lesson/presentation/widgets/finish/completion_stat_tile.dart';
import 'package:peddi/features/lesson/presentation/widgets/finish/learned_phrase_row.dart';
import 'package:peddi/features/lesson/presentation/widgets/finish/learned_phrases_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/finish/more_learned_line.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/l10n/app_strings.dart';

class _FakeTtsService implements TextToSpeechService {
  String? lastSpokenText;
  String? lastLocale;
  int speakCount = 0;

  @override
  Future<bool> speak(String text, {required String locale, double? speechRate}) async {
    lastSpokenText = text;
    lastLocale = locale;
    speakCount++;
    return true;
  }

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

class _FakeCurrentUserNotifier extends CurrentUserNotifier {
  _FakeCurrentUserNotifier(UserProfile? initial)
      : super(MockProfileRepository(), initial);
}

UserProfile _createTestProfile(String id, {AgeBand ageBand = AgeBand.adult}) {
  return UserProfile(
    userId: id,
    ageBand: ageBand,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: const {'travel'},
    dailyGoalId: 'regular',
    reminderTime: const ReminderTime(hour: 18, minute: 0),
    selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
    remindersEnabled: true,
    accentId: 'purple',
    plan: 'free',
  );
}

void main() {
  late FakeAudioFeedbackService fakeAudio;
  late _FakeTtsService fakeTts;
  late MockProgressRepository mockProgress;

  setUp(() {
    fakeAudio = FakeAudioFeedbackService();
    fakeTts = _FakeTtsService();
    mockProgress = MockProgressRepository();
  });

  Widget createSubject({
    String stopId = 'stop_test',
    UserProfile? profile,
    LessonCompletion? overrideCompletion,
  }) {
    return ProviderScope(
      overrides: [
        audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
        textToSpeechServiceProvider.overrideWithValue(fakeTts),
        progressRepositoryProvider.overrideWithValue(mockProgress),
        currentUserProvider.overrideWith(
          (ref) => _FakeCurrentUserNotifier(profile ?? _createTestProfile('test_user')),
        ),
        if (overrideCompletion != null)
          lessonCompletionProvider(stopId).overrideWith(
            (ref) => overrideCompletion,
          ),
      ],
      child: MaterialApp(
        home: LessonCompleteScreen(stopId: stopId),
      ),
    );
  }

  group('LessonCompleteScreen Presentation Tests', () {
    testWidgets('Renders all visual components for 3-star completion', (tester) async {
      final completion = LessonCompletion(
        stopId: 'stop_test',
        starsEarned: 3,
        scoredCount: 9,
        firstTryCorrectCount: 9,
        learnedPhrases: const [
          LearnedPhrase(
            id: 'p1',
            emoji: '👋',
            text: 'Hola',
            meaning: 'Hello',
            audioText: 'Hola',
            audioLocale: 'es-ES',
          ),
          LearnedPhrase(
            id: 'p2',
            emoji: '🌅',
            text: 'Buenos días',
            meaning: 'Good morning',
            audioText: 'Buenos días',
            audioLocale: 'es-ES',
          ),
          LearnedPhrase(
            id: 'p3',
            emoji: '🙏',
            text: 'Por favor',
            meaning: 'Please',
            audioText: 'Por favor',
            audioLocale: 'es-ES',
          ),
        ],
        streakDays: 3,
        dailyGoal: const DailyGoalCompletion(status: DailyGoalStatus.done),
      );

      await tester.pumpWidget(createSubject(overrideCompletion: completion));
      await tester.pumpAndSettle();

      // Mascot
      expect(find.byType(PebbiMascot), findsOneWidget);

      // Header title & subtitle
      expect(find.text(AppStrings.lessonCompleteTitle), findsOneWidget);
      expect(find.text(AppStrings.lessonCompleteSubtitleForStars(3)), findsOneWidget);

      // Star row
      expect(find.byType(StarRow), findsOneWidget);

      // First-try line
      expect(find.text('9 of 9 right on the first try'), findsOneWidget);

      // Phrases card and individual rows
      expect(find.byType(LearnedPhrasesCard), findsOneWidget);
      expect(find.text(AppStrings.youCanNowSayTitle), findsOneWidget);
      expect(find.byType(LearnedPhraseRow), findsNWidgets(3));
      expect(find.text('Hola'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Buenos días'), findsOneWidget);

      // Stat tiles
      expect(find.byType(CompletionStatRow), findsOneWidget);
      expect(find.byType(CompletionStatTile), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('day streak'), findsOneWidget);
      expect(find.text(AppStrings.goalDoneTitle), findsOneWidget);

      // Pinned Continue button
      expect(find.widgetWithText(Button3D, AppStrings.continueButton), findsOneWidget);

      // Audio feedback triggered once
      expect(fakeAudio.successCount, 1);
    });

    testWidgets('Tapping phrase row triggers TTS playback', (tester) async {
      final completion = LessonCompletion(
        stopId: 'stop_test',
        starsEarned: 3,
        scoredCount: 9,
        firstTryCorrectCount: 9,
        learnedPhrases: const [
          LearnedPhrase(
            id: 'p1',
            emoji: '👋',
            text: 'Hola',
            meaning: 'Hello',
            audioText: 'Hola',
            audioLocale: 'es-ES',
          ),
        ],
        streakDays: 3,
        dailyGoal: const DailyGoalCompletion(status: DailyGoalStatus.done),
      );

      await tester.pumpWidget(createSubject(overrideCompletion: completion));
      await tester.pumpAndSettle();

      expect(fakeTts.speakCount, 0);

      // Tap the phrase row
      await tester.tap(find.text('Hola'));
      await tester.pump();

      expect(fakeTts.speakCount, 1);
      expect(fakeTts.lastSpokenText, 'Hola');
      expect(fakeTts.lastLocale, 'es-ES');
    });

    testWidgets('Displays +N more line when phrases exceed max 3 preview', (tester) async {
      final completion = LessonCompletion(
        stopId: 'stop_test',
        starsEarned: 2,
        scoredCount: 9,
        firstTryCorrectCount: 7,
        learnedPhrases: const [
          LearnedPhrase(id: '1', emoji: '1', text: 'T1', meaning: 'M1', audioText: 'T1', audioLocale: 'es'),
          LearnedPhrase(id: '2', emoji: '2', text: 'T2', meaning: 'M2', audioText: 'T2', audioLocale: 'es'),
          LearnedPhrase(id: '3', emoji: '3', text: 'T3', meaning: 'M3', audioText: 'T3', audioLocale: 'es'),
          LearnedPhrase(id: '4', emoji: '4', text: 'T4', meaning: 'M4', audioText: 'T4', audioLocale: 'es'),
          LearnedPhrase(id: '5', emoji: '5', text: 'T5', meaning: 'M5', audioText: 'T5', audioLocale: 'es'),
        ],
        streakDays: 4,
        dailyGoal: const DailyGoalCompletion(status: DailyGoalStatus.done),
      );

      await tester.pumpWidget(createSubject(overrideCompletion: completion));
      await tester.pumpAndSettle();

      expect(find.byType(LearnedPhraseRow), findsNWidgets(3));
      expect(find.byType(MoreLearnedLine), findsOneWidget);
      expect(find.text('+2 more'), findsOneWidget);
    });

    testWidgets('Hides streak flame stat tile when streakDays is null (single goal tile layout)', (tester) async {
      final completion = LessonCompletion(
        stopId: 'stop_test',
        starsEarned: 3,
        scoredCount: 9,
        firstTryCorrectCount: 9,
        learnedPhrases: const [],
        streakDays: null,
        dailyGoal: const DailyGoalCompletion(status: DailyGoalStatus.done),
      );

      await tester.pumpWidget(createSubject(
        overrideCompletion: completion,
      ));
      await tester.pumpAndSettle();

      // Only daily goal tile is shown, streak flame tile is omitted
      expect(find.text('day streak'), findsNothing);
      expect(find.text(AppStrings.goalDoneTitle), findsOneWidget);
      expect(find.byType(CompletionStatTile), findsOneWidget);
    });
  });
}
