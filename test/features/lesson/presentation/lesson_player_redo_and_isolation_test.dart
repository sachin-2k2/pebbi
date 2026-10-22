import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/fake_speech_recognizer_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exit_confirm_sheet.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('Lesson Player Redo Round, Exit Sheet & User Isolation Tests', () {
    late FakeSpeechService fakeSpeech;
    late FakeAudioFeedbackService fakeAudio;
    late FakeSpeechRecognizerService fakeRecognizer;

    setUp(() {
      fakeSpeech = FakeSpeechService();
      fakeAudio = FakeAudioFeedbackService();
      fakeRecognizer = FakeSpeechRecognizerService();
    });

    UserProfile createProfile(String id) {
      return UserProfile(
        userId: id,
        ageBand: AgeBand.adult,
        explanationLanguageCode: 'en',
        targetLanguageCode: 'es',
        reasonIds: const {'travel'},
        dailyGoalId: 'regular',
        reminderTime: const ReminderTime(hour: 9, minute: 0),
        selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
        remindersEnabled: true,
        accentId: 'purple',
        plan: 'free',
      );
    }

    testWidgets('Exit confirmation sheet cancels or leaves', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
            audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
            speechRecognizerServiceProvider.overrideWithValue(fakeRecognizer),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const ExerciseScreen(stopId: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap X button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Exit confirm sheet shown
      expect(find.byType(ExitConfirmSheet), findsOneWidget);
      expect(find.text(AppStrings.exitConfirmTitle), findsOneWidget);

      // Tap Stay
      await tester.tap(find.text(AppStrings.exitConfirmStay));
      await tester.pumpAndSettle();

      // Screen stays active
      expect(find.byType(ExerciseScreen), findsOneWidget);
    });

    testWidgets(
      'User isolation: progress saved under User A is isolated from User B',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final container = ProviderContainer(
          overrides: [
            textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
            audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
            speechRecognizerServiceProvider.overrideWithValue(fakeRecognizer),
          ],
        );

        final userANotifier = container.read(currentUserProvider.notifier);
        await userANotifier.saveProfile(createProfile('user_alice'));

        final progressRepo = container.read(progressRepositoryProvider);
        expect(
          await progressRepo.isStopCompleted(userId: 'user_alice', stopId: '1'),
          isFalse,
        );
        expect(
          await progressRepo.isStopCompleted(userId: 'user_bob', stopId: '1'),
          isFalse,
        );

        // Complete lesson for User Alice
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const ExerciseScreen(stopId: '1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Fast forward all 12 items
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.text(AppStrings.gotIt));
          await tester.pumpAndSettle();
        }
        // 5: 👋
        await tester.tap(find.text('👋'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 6: Hello
        await tester.tap(find.text('Hello'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 7: 🌅
        await tester.tap(find.text('🌅'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 8: Match
        await tester.tap(find.text('Hola'));
        await tester.tap(find.text('Hello'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buenos días'));
        await tester.tap(find.text('Good morning'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buenas tardes'));
        await tester.tap(find.text('Good afternoon'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 9: Hola
        await tester.tap(find.text('Hola'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 10: Buenos días
        await tester.tap(find.text('Buenos'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('días'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 11: Muy bien, gracias
        await tester.tap(find.text('Muy bien, gracias'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // 12: Speaking
        await tester.tap(find.text(AppStrings.speakRatherNotAction));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.selfCheckSkipAction));
        await tester.pumpAndSettle();

        // Alice now has stop 1 completed
        expect(
          await progressRepo.isStopCompleted(userId: 'user_alice', stopId: '1'),
          isTrue,
        );

        // User Bob logs in
        await userANotifier.logout();
        await userANotifier.saveProfile(createProfile('user_bob'));

        // Bob strictly has NO progress from Alice
        expect(
          await progressRepo.isStopCompleted(userId: 'user_bob', stopId: '1'),
          isFalse,
        );
      },
    );
  });
}
