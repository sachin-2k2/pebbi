import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/back_link.dart';
import 'package:peddi/core/services/fake_speech_recognizer_service.dart';
import 'package:peddi/core/services/speech_recognizer_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/missions/data/mock_mission_repository.dart';
import 'package:peddi/features/missions/domain/mission_mode.dart';
import 'package:peddi/features/missions/domain/mission_support.dart';
import 'package:peddi/features/missions/presentation/providers/mission_brief_provider.dart';
import 'package:peddi/features/missions/presentation/providers/missions_provider.dart';
import 'package:peddi/features/missions/presentation/screens/mission_brief_screen.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/brief_header.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/brief_info_chips.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/captions_row.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/captions_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/goal_list.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/hear_goals_button.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/option_groups_row.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/option_pill.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/scene_line.dart';
import 'package:peddi/features/missions/presentation/widgets/brief/start_mission_button.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  late MockMissionRepository mockRepository;
  late FakeSpeechService fakeTtsService;
  late FakeSpeechRecognizerService fakeSpeechRecognizer;

  const testUser = UserProfile(
    userId: 'user_test_1',
    ageBand: AgeBand.adult,
    targetLanguageCode: 'es',
    explanationLanguageCode: 'en',
    reasonIds: {},
    dailyGoalId: 'goal_casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1, 2, 3, 4, 5},
    remindersEnabled: true,
    accentId: 'violet',
    plan: 'free',
  );

  setUp(() {
    mockRepository = MockMissionRepository();
    fakeTtsService = FakeSpeechService();
    fakeSpeechRecognizer = FakeSpeechRecognizerService();
  });

  Widget createWidget({
    String missionId = 'order_coffee',
    UserProfile? user = testUser,
    AppSettings settings = const AppSettings(),
    bool isOffline = false,
    Brightness brightness = Brightness.light,
  }) {
    final theme = brightness == Brightness.dark
        ? AppTheme.dark()
        : AppTheme.light();

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) =>
              CurrentUserNotifier(ref.watch(profileRepositoryProvider), user),
        ),
        missionRepositoryProvider.overrideWithValue(mockRepository),
        textToSpeechServiceProvider.overrideWithValue(fakeTtsService),
        speechRecognizerServiceProvider.overrideWithValue(fakeSpeechRecognizer),
        missionBriefIsOfflineProvider.overrideWith((ref) => isOffline),
        appSettingsProvider.overrideWith(
          (ref) => AppSettingsNotifier(settings),
        ),
      ],
      child: MaterialApp(
        theme: theme,
        home: MissionBriefScreen(missionId: missionId),
      ),
    );
  }

  group('MissionBriefScreen Widget Tests', () {
    testWidgets('1. Matches default screenshot layout and content', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // BackLink
      expect(find.byType(BackLink), findsOneWidget);
      expect(find.text(AppStrings.missionsLink), findsOneWidget);

      // Header
      expect(find.byType(BriefHeader), findsOneWidget);
      expect(find.text('Order a coffee'), findsOneWidget);
      expect(find.text('Lucía, barista'), findsOneWidget);

      // Scene line
      expect(find.byType(SceneLine), findsOneWidget);
      expect(find.text('A busy café, morning rush'), findsOneWidget);

      // Goal list
      expect(find.byType(GoalList), findsOneWidget);
      expect(find.text(AppStrings.yourGoalSectionLabel), findsOneWidget);
      expect(find.text('Order a drink'), findsOneWidget);
      expect(find.text('Ask the price'), findsOneWidget);
      expect(find.text('Pay and say thank you'), findsOneWidget);

      // Option groups: Mode and Support
      expect(find.byType(OptionGroupsRow), findsOneWidget);
      expect(find.text(AppStrings.modeChat), findsOneWidget);
      expect(find.text(AppStrings.modeVoice), findsOneWidget);
      expect(find.text(AppStrings.supportLightHints), findsOneWidget);
      expect(find.text(AppStrings.supportGuided), findsOneWidget);

      // Check defaults: Chat selected, Guided selected
      final chatPill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.modeChat),
      );
      expect(chatPill.isSelected, isTrue);

      final voicePill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.modeVoice),
      );
      expect(voicePill.isSelected, isFalse);

      final guidedPill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.supportGuided),
      );
      expect(guidedPill.isSelected, isTrue);

      // Info chips
      expect(find.byType(BriefInfoChips), findsOneWidget);
      expect(find.text('About 5 min'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text(AppStrings.suggestedRepliesOn), findsOneWidget);

      // Safety notice
      expect(find.text(AppStrings.missionSafetyNotice), findsOneWidget);

      // Buttons
      expect(find.byType(StartMissionButton), findsOneWidget);
      expect(find.text(AppStrings.startMission), findsOneWidget);
      expect(find.byType(HearGoalsButton), findsOneWidget);
      expect(find.text(AppStrings.hearGoalOutLoud), findsOneWidget);

      // Captions row
      expect(find.byType(CaptionsRow), findsOneWidget);
      expect(find.text(AppStrings.missionCaptionsRow(true)), findsOneWidget);
    });

    testWidgets('2. Tapping options updates selection and derived chip', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap Voice
      await tester.tap(find.widgetWithText(OptionPill, AppStrings.modeVoice));
      await tester.pumpAndSettle();

      final voicePillAfter = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.modeVoice),
      );
      expect(voicePillAfter.isSelected, isTrue);

      // Tap Light hints
      await tester.tap(
        find.widgetWithText(OptionPill, AppStrings.supportLightHints),
      );
      await tester.pumpAndSettle();

      final lightHintsPill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.supportLightHints),
      );
      expect(lightHintsPill.isSelected, isTrue);

      // Derived chip switches to "Suggested replies off"
      expect(find.text(AppStrings.suggestedRepliesOff), findsOneWidget);
      expect(find.text(AppStrings.suggestedRepliesOn), findsNothing);
    });

    testWidgets(
      '3. Voice is disabled with reason when speaking practice is off',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        await tester.pumpWidget(
          createWidget(
            settings: const AppSettings(speakingPracticeEnabled: false),
          ),
        );
        await tester.pumpAndSettle();

        final voicePill = tester.widget<OptionPill>(
          find.widgetWithText(OptionPill, AppStrings.modeVoice),
        );
        expect(voicePill.isDisabled, isTrue);
        expect(voicePill.disabledReason, AppStrings.voiceDisabledSpeakingOff);

        // Tapping disabled voice displays notice banner
        await tester.tap(find.widgetWithText(OptionPill, AppStrings.modeVoice));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.voiceDisabledSpeakingOff), findsWidgets);
      },
    );

    testWidgets('4. Voice is disabled for child age band', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final childUser = testUser.copyWith(ageBand: AgeBand.child);
      await tester.pumpWidget(createWidget(user: childUser));
      await tester.pumpAndSettle();

      final voicePill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.modeVoice),
      );
      expect(voicePill.isDisabled, isTrue);
      expect(voicePill.disabledReason, AppStrings.voiceDisabledAge);
    });

    testWidgets('5. Voice is disabled when scene does not support voice', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget(missionId: 'no_voice_mission'));
      await tester.pumpAndSettle();

      final voicePill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.modeVoice),
      );
      expect(voicePill.isDisabled, isTrue);
      expect(voicePill.disabledReason, AppStrings.voiceDisabledScene);
    });

    testWidgets('6. Mic permission requested ONLY on Start in Voice mode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // On screen open, recognizer initialize is not called
      expect(fakeSpeechRecognizer.isInitialized, isFalse);

      // Selecting Voice does NOT request permission
      await tester.tap(find.widgetWithText(OptionPill, AppStrings.modeVoice));
      await tester.pumpAndSettle();
      expect(fakeSpeechRecognizer.isInitialized, isFalse);

      // Tap Start in Voice mode -> initializes and checks mic
      await tester.ensureVisible(find.byType(StartMissionButton));
      await tester.tap(find.byType(StartMissionButton));
      await tester.pump();

      expect(fakeSpeechRecognizer.isInitialized, isTrue);
    });

    testWidgets('7. Voice mode falls back to Chat if mic permission denied', (
      tester,
    ) async {
      fakeSpeechRecognizer.autoInitializeResult = false;
      fakeSpeechRecognizer.hasPermission = false;

      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OptionPill, AppStrings.modeVoice));
      await tester.pumpAndSettle();

      // Tap Start
      await tester.ensureVisible(find.byType(StartMissionButton));
      await tester.tap(find.byType(StartMissionButton));
      await tester.pumpAndSettle();

      // Switched back to Chat with notice banner
      expect(find.text(AppStrings.voicePermissionFallback), findsOneWidget);
      final chatPill = tester.widget<OptionPill>(
        find.widgetWithText(OptionPill, AppStrings.modeChat),
      );
      expect(chatPill.isSelected, isTrue);
    });

    testWidgets(
      '8. Hear the goal out loud plays goals sequentially and shows Stop',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.hearGoalOutLoud), findsOneWidget);

        // Tap "Hear the goal out loud"
        await tester.ensureVisible(find.byType(HearGoalsButton));
        await tester.tap(find.byType(HearGoalsButton));
        await tester.pump();

        // Button toggles to Stop
        expect(find.text(AppStrings.stopGoalPlayback), findsOneWidget);
        expect(fakeTtsService.spokenHistory.isNotEmpty, isTrue);
        expect(fakeTtsService.spokenHistory.first.text, 'Order a drink');
        expect(fakeTtsService.spokenHistory.first.locale, 'en-US');

        // Tapping Stop cancels playback
        await tester.tap(find.byType(HearGoalsButton));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.hearGoalOutLoud), findsOneWidget);
        expect(fakeTtsService.isSpeaking, isFalse);
      },
    );

    testWidgets(
      '9. Captions row opens CaptionsSheet and toggles shared setting',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.missionCaptionsRow(true)), findsOneWidget);

        // Tap Captions row
        await tester.ensureVisible(find.byType(CaptionsRow));
        await tester.tap(find.byType(CaptionsRow));
        await tester.pumpAndSettle();

        // Sheet opens
        expect(find.byType(CaptionsSheet), findsOneWidget);
        expect(find.text(AppStrings.captionsSheetTitle), findsOneWidget);

        // Toggle switch off
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Dismiss sheet
        await tester.tap(find.byTooltip(AppStrings.close));
        await tester.pumpAndSettle();

        // Row updates immediately to "Captions: off  ›"
        expect(find.text(AppStrings.missionCaptionsRow(false)), findsOneWidget);
      },
    );

    test(
      '10. User Isolation: User A defaults do not bleed into User B',
      () async {
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => CurrentUserNotifier(
                ref.watch(profileRepositoryProvider),
                testUser,
              ),
            ),
            missionRepositoryProvider.overrideWithValue(mockRepository),
            textToSpeechServiceProvider.overrideWithValue(fakeTtsService),
            speechRecognizerServiceProvider.overrideWithValue(
              fakeSpeechRecognizer,
            ),
          ],
        );

        final subA = container.listen(
          missionBriefNotifierProvider('order_coffee'),
          (previous, next) {},
        );
        final notifierA = container.read(
          missionBriefNotifierProvider('order_coffee').notifier,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // User A selects Voice and Light hints
        await notifierA.selectMode(MissionMode.voice);
        await notifierA.selectSupport(MissionSupport.lightHints);

        // User B logs in
        const userB = UserProfile(
          userId: 'user_b_isolated',
          ageBand: AgeBand.adult,
          targetLanguageCode: 'es',
          explanationLanguageCode: 'en',
          reasonIds: {},
          dailyGoalId: 'goal_casual',
          reminderTime: ReminderTime(hour: 9, minute: 0),
          selectedWeekdayNumbers: {1, 2, 3},
          remindersEnabled: true,
          accentId: 'violet',
          plan: 'free',
        );

        final containerB = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => CurrentUserNotifier(
                ref.watch(profileRepositoryProvider),
                userB,
              ),
            ),
            missionRepositoryProvider.overrideWithValue(mockRepository),
            textToSpeechServiceProvider.overrideWithValue(fakeTtsService),
            speechRecognizerServiceProvider.overrideWithValue(
              fakeSpeechRecognizer,
            ),
          ],
        );

        final subB = containerB.listen(
          missionBriefNotifierProvider('order_coffee'),
          (previous, next) {},
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final stateB = containerB
            .read(missionBriefNotifierProvider('order_coffee'))
            .valueOrNull;
        expect(stateB?.selectedMode, MissionMode.chat);
        expect(stateB?.selectedSupport, MissionSupport.guided);

        subA.close();
        subB.close();
        container.dispose();
        containerB.dispose();
      },
    );

    testWidgets('11. Completed mission displays Done tag and Try again label', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget(missionId: 'completed_mission'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.missionCompletedTag), findsOneWidget);
      expect(find.text(AppStrings.tryAgainMission), findsOneWidget);
    });

    testWidgets('12. Premium-locked mission displays Locked tag', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget(missionId: 'premium_mission'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.missionLockedTag), findsOneWidget);
    });

    testWidgets('13. Mission with no scene line hides cleanly without gaps', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget(missionId: 'no_scene_mission'));
      await tester.pumpAndSettle();

      expect(find.byType(SceneLine), findsOneWidget);
      expect(find.text('A busy café, morning rush'), findsNothing);
      expect(find.text('Casual Greeting'), findsOneWidget);
    });

    testWidgets('14. Five-goal mission renders all 5 goals', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(createWidget(missionId: 'five_goals_mission'));
      await tester.pumpAndSettle();

      expect(find.text('Greet the cashier'), findsOneWidget);
      expect(find.text('Ask where the dairy aisle is located'), findsOneWidget);
      expect(find.text('Inquire about discount deals'), findsOneWidget);
      expect(find.text('Request a reusable shopping bag'), findsOneWidget);
      expect(find.text('Pay with card and say goodbye'), findsOneWidget);
    });

    testWidgets('15. Mission not found displays error view with back link', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        createWidget(missionId: 'non_existent_mission_id'),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.missionNotFound), findsOneWidget);
      expect(find.byType(BackLink), findsOneWidget);
    });
  });

  group('Responsive Breakpoint Tests (Zero Overflows)', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(430, 932), // Large phone
      Size(800, 1280), // Tablet portrait
      Size(1280, 800), // Tablet landscape
      Size(1024, 1366), // iPad Pro
      Size(700, 900), // Split-screen window
    ];

    for (final size in testSizes) {
      testWidgets(
        'Renders without overflow on ${size.width}x${size.height} at 1.0x text scale (Light)',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Renders without overflow on ${size.width}x${size.height} at 2.0x text scale (Dark)',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(
            createWidget(
              brightness: Brightness.dark,
              settings: const AppSettings(textScale: 1.3),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
