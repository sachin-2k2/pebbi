import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/lesson/domain/lesson_completion.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_completion_provider.dart';
import 'package:peddi/features/lesson/presentation/screens/lesson_complete_screen.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

class _NoOpTtsService implements TextToSpeechService {
  @override
  Future<bool> speak(String text, {required String locale, double? speechRate}) async => true;

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

class _FakeCurrentUserNotifier extends CurrentUserNotifier {
  _FakeCurrentUserNotifier(UserProfile? initial)
      : super(MockProfileRepository(), initial);
}

UserProfile _createTestProfile(String id) {
  return UserProfile(
    userId: id,
    ageBand: AgeBand.adult,
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
  const targetSizes = [
    Size(360, 640), // Small Android phone
    Size(390, 844), // iPhone
    Size(430, 932), // Large phone
    Size(800, 1280), // Android tablet, portrait
    Size(1280, 800), // Android tablet, landscape
    Size(1024, 1366), // iPad Pro, portrait
    Size(700, 900), // Split-screen / foldable
  ];

  final sampleCompletion = LessonCompletion(
    stopId: 'stop_responsive',
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
      LearnedPhrase(
        id: 'p4',
        emoji: '✨',
        text: 'Gracias',
        meaning: 'Thank you',
        audioText: 'Gracias',
        audioLocale: 'es-ES',
      ),
    ],
    streakDays: 5,
    dailyGoal: const DailyGoalCompletion(status: DailyGoalStatus.done),
  );

  Widget buildTestWidget({
    required Size size,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    LessonCompletion? completion,
    Locale? locale,
  }) {
    final fakeAudio = FakeAudioFeedbackService();
    final fakeTts = _NoOpTtsService();

    return ProviderScope(
      overrides: [
        audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
        textToSpeechServiceProvider.overrideWithValue(fakeTts),
        currentUserProvider.overrideWith(
          (ref) => _FakeCurrentUserNotifier(_createTestProfile('user_resp')),
        ),
        lessonCompletionProvider('stop_responsive').overrideWith(
          (ref) => completion ?? sampleCompletion,
        ),
      ],
      child: MaterialApp(
        locale: locale,
        themeMode: themeMode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const LessonCompleteScreen(stopId: 'stop_responsive'),
        ),
      ),
    );
  }

  group('LessonCompleteScreen Responsive Layouts (AGENTS.md §4.8)', () {
    for (final size in targetSizes) {
      testWidgets('renders cleanly on ${size.width}x${size.height} at scale 1.0',
          (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildTestWidget(size: size, textScale: 1.0));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders cleanly on ${size.width}x${size.height} at scale 2.0 (large text)',
          (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildTestWidget(size: size, textScale: 2.0));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('renders cleanly in dark mode', (tester) async {
      const size = Size(390, 844);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(size: size, themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly with RTL Arabic phrases', (tester) async {
      const size = Size(390, 844);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final arabicCompletion = LessonCompletion(
        stopId: 'stop_responsive',
        starsEarned: 3,
        scoredCount: 8,
        firstTryCorrectCount: 8,
        learnedPhrases: const [
          LearnedPhrase(
            id: 'ar1',
            emoji: '👋',
            text: 'مرحبا',
            meaning: 'Hello',
            audioText: 'مرحبا',
            audioLocale: 'ar-SA',
            isRtl: true,
          ),
          LearnedPhrase(
            id: 'ar2',
            emoji: '🌅',
            text: 'صباح الخير',
            meaning: 'Good morning',
            audioText: 'صباح الخير',
            audioLocale: 'ar-SA',
            isRtl: true,
          ),
        ],
        streakDays: 2,
        dailyGoal: const DailyGoalCompletion(status: DailyGoalStatus.done),
      );

      await tester.pumpWidget(
        buildTestWidget(
          size: size,
          completion: arabicCompletion,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('مرحبا'), findsOneWidget);
    });
  });
}
