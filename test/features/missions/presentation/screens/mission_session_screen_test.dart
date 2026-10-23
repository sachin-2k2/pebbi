import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/icon_tile.dart';
import 'package:peddi/core/services/fake_speech_recognizer_service.dart';
import 'package:peddi/core/services/speech_recognizer_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/missions/data/mock_conversation_repository.dart';
import 'package:peddi/features/missions/domain/correction_style.dart';
import 'package:peddi/features/missions/domain/mission_mode.dart';
import 'package:peddi/features/missions/domain/mission_support.dart';
import 'package:peddi/features/missions/domain/session_config.dart';
import 'package:peddi/features/missions/presentation/providers/mission_session_provider.dart';
import 'package:peddi/features/missions/presentation/screens/mission_session_screen.dart';
import 'package:peddi/features/missions/presentation/widgets/session/ai_disclosure_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/session/character_bubble.dart';
import 'package:peddi/features/missions/presentation/widgets/session/finish_prompt_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/session/help_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/session/leave_session_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/session/say_in_my_language_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/session/session_footer_links.dart';
import 'package:peddi/features/missions/presentation/widgets/session/session_header.dart';
import 'package:peddi/features/missions/presentation/widgets/session/session_unavailable_view.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/speaking/level_dots.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/speaking/mic_button.dart';
import 'package:peddi/features/missions/presentation/widgets/session/suggestion_card.dart';
import 'package:peddi/features/missions/presentation/widgets/session/user_bubble.dart';
import 'package:peddi/features/missions/presentation/widgets/session/voice_input_bar.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/review/data/mock_translation_repository.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  late MockConversationRepository mockRepository;
  late MockTranslationRepository mockTranslationRepository;
  late FakeSpeechService fakeTtsService;
  late FakeSpeechRecognizerService fakeSpeechRecognizer;

  const testUser = UserProfile(
    userId: 'user_test_session',
    ageBand: AgeBand.adult,
    targetLanguageCode: 'fr',
    explanationLanguageCode: 'en',
    reasonIds: {},
    dailyGoalId: 'goal_casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1, 2, 3, 4, 5},
    remindersEnabled: true,
    accentId: 'violet',
    plan: 'free',
  );

  const defaultFrenchConfig = SessionConfig(
    missionId: 'order_coffee',
    mode: MissionMode.chat,
    support: MissionSupport.guided,
    correctionStyle: CorrectionStyle.gentle,
    captionsOn: true,
    targetLanguageCode: 'fr',
    explanationLanguageCode: 'en',
    level: 1,
  );

  setUp(() {
    mockTranslationRepository = MockTranslationRepository();
    mockRepository = MockConversationRepository(
      simulatedLatency: Duration.zero,
      translationRepository: mockTranslationRepository,
    );
    fakeTtsService = FakeSpeechService();
    fakeSpeechRecognizer = FakeSpeechRecognizerService();
  });

  Widget createWidget({
    SessionConfig config = defaultFrenchConfig,
    UserProfile? user = testUser,
    AppSettings settings = const AppSettings(autoplay: false),
    bool isOffline = false,
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Size? size,
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
        appSettingsProvider.overrideWith(
          (ref) => AppSettingsNotifier(settings),
        ),
        conversationRepositoryProvider.overrideWithValue(mockRepository),
        translationRepositoryProvider.overrideWithValue(
          mockTranslationRepository,
        ),
        textToSpeechServiceProvider.overrideWithValue(fakeTtsService),
        speechRecognizerServiceProvider.overrideWithValue(fakeSpeechRecognizer),
        missionSessionIsOfflineProvider.overrideWith((ref) => isOffline),
      ],
      child: MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(textScale),
                size: size ?? media.size,
              ),
              child: MissionSessionScreen(config: config),
            );
          },
        ),
      ),
    );
  }

  group('MissionSessionScreen - Design Screenshot Verification', () {
    testWidgets('matches screenshot default state with Lucía the barista', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // 1. Header elements
      expect(find.text('Lucía'), findsOneWidget);
      expect(
        find.text(AppStrings.sessionCharacterOnline('barista')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.sessionHelpButtonLabel), findsOneWidget);
      expect(find.byType(SessionHeader), findsOneWidget);

      // 2. Goal strip (all 3 goals initially visible with uncompleted circles)
      expect(find.text('Order a drink'), findsOneWidget);
      expect(find.text('Ask the price'), findsOneWidget);
      expect(find.text('Pay and say thank you'), findsOneWidget);

      // 3. Initial character message bubble
      expect(
        find.text('Bonjour ! Bienvenue. Que voulez-vous boire ?'),
        findsOneWidget,
      );
      expect(
        find.text('Hello! Welcome. What would you like to drink?'),
        findsOneWidget,
      );
      expect(find.byType(CharacterBubble), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);

      // 4. Three suggested replies
      expect(find.byType(SuggestionCard), findsNWidgets(3));
      expect(find.text("Un café, s'il vous plaît."), findsOneWidget);
      expect(find.text("Un chocolat chaud, s'il vous plaît."), findsOneWidget);
      expect(find.text("Un thé, s'il vous plaît."), findsOneWidget);

      // 5. Input bar
      expect(find.text('Reply in French...'), findsOneWidget);
      expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);

      // 6. Footer links
      expect(find.byType(SessionFooterLinks), findsOneWidget);
      expect(find.text(AppStrings.sessionSayInMyLanguage), findsOneWidget);
      expect(find.text(AppStrings.sessionFinishAndDebrief), findsOneWidget);
    });

    testWidgets('tapping suggested reply sends it and triggers character turn', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap suggestion "Un café, s'il vous plaît."
      await tester.tap(find.text("Un café, s'il vous plaît."));
      await tester.pumpAndSettle();

      // User bubble appears
      expect(find.byType(UserBubble), findsOneWidget);
      expect(find.text("Un café, s'il vous plaît."), findsWidgets);

      // Character replied with turn 1 response
      expect(
        find.text('Très bien, un café ! Avec du lait ou sans lait ?'),
        findsOneWidget,
      );
      expect(
        find.text('Great, a coffee! With milk or without milk?'),
        findsOneWidget,
      );

      // Goal 1 is now marked completed with checkmark icon
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Suggestions updated for turn 2
      expect(find.text("Avec du lait, s'il vous plaît."), findsOneWidget);
      expect(find.text('Combien ça coûte ?'), findsOneWidget);
    });

    testWidgets('typing custom text enables send button and sends user message', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Un café noir, merci');
      await tester.pumpAndSettle();

      // Tap send button
      final sendButton = find.byIcon(Icons.near_me_rounded);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify user bubble
      expect(find.text('Un café noir, merci'), findsOneWidget);
    });

    testWidgets('all goals reached shows completion banner and debrief button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Turn 1
      await tester.tap(find.text("Un café, s'il vous plaît."));
      await tester.pumpAndSettle();

      // Turn 2
      await tester.tap(find.text("Avec du lait, s'il vous plaît."));
      await tester.pumpAndSettle();

      // Turn 3 (Final)
      await tester.tap(find.text('Voici trois euros, merci !'));
      await tester.pumpAndSettle();

      // Character finished dialogue
      expect(
        find.text('Merci beaucoup ! Bonne journée et à bientôt !'),
        findsOneWidget,
      );

      // All goals completed note visible
      expect(find.text(AppStrings.sessionAllGoalsDone), findsOneWidget);

      // Input replaced with debrief button
      expect(find.text(AppStrings.sessionSeeDebrief), findsOneWidget);
    });
  });

  group('MissionSessionScreen - Audio and Media', () {
    testWidgets('tapping replay audio button speaks message via TTS', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final replayButton = find.byIcon(Icons.volume_up_outlined);
      expect(replayButton, findsOneWidget);

      await tester.tap(replayButton);
      await tester.pump();

      expect(fakeTtsService.lastSpokenText, contains('Bonjour ! Bienvenue'));
      expect(fakeTtsService.lastLocale, 'fr-FR');
    });

    testWidgets('autoplay audio plays initial message when enabled in settings', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(settings: const AppSettings(autoplay: true)),
      );
      await tester.pumpAndSettle();

      expect(fakeTtsService.lastSpokenText, contains('Bonjour ! Bienvenue'));
      expect(fakeTtsService.lastLocale, 'fr-FR');
    });
  });

  group('MissionSessionScreen - Sheets and Modals', () {
    testWidgets('tapping Say it in my language opens sheet and populates draft', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.sessionSayInMyLanguage));
      await tester.pumpAndSettle();

      // Modal sheet is open
      expect(find.byType(SayInMyLanguageSheet), findsOneWidget);

      // Enter English phrase
      final sheetField = find.descendant(
        of: find.byType(SayInMyLanguageSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(sheetField, 'Where is the restroom?');
      await tester.pumpAndSettle();

      // Tap translate
      await tester.tap(find.text(AppStrings.sayInMyLanguageTranslateButton));
      await tester.pumpAndSettle();

      // Result shown
      expect(find.text('Où sont les toilettes ?'), findsOneWidget);

      // Tap "Use this"
      await tester.tap(find.text(AppStrings.sayInMyLanguageUseThis));
      await tester.pumpAndSettle();

      // Sheet closed and text copied into input bar
      expect(find.byType(SayInMyLanguageSheet), findsNothing);
      expect(find.text('Où sont les toilettes ?'), findsOneWidget);
    });

    testWidgets('tapping Help pill opens HelpSheet with 3 options', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.sessionHelpButtonLabel));
      await tester.pumpAndSettle();

      expect(find.byType(HelpSheet), findsOneWidget);
      expect(find.text(AppStrings.helpOptionShowHint), findsOneWidget);
      expect(find.text(AppStrings.helpOptionTranslateLast), findsOneWidget);
      expect(find.text(AppStrings.helpOptionLeave), findsOneWidget);
    });

    testWidgets('tapping character avatar opens AiDisclosureSheet', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconTile));
      await tester.pumpAndSettle();

      expect(find.byType(AiDisclosureSheet), findsOneWidget);
      expect(find.text(AppStrings.aiDisclosureTitle), findsOneWidget);
      expect(find.text(AppStrings.aiDisclosureBody('Lucía')), findsOneWidget);
    });

    testWidgets('system back button prompts LeaveSessionSheet', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Simulate back invocation
      final dynamic popScope = tester.widget(
        find.byWidgetPredicate((w) => w is PopScope),
      );
      popScope.onPopInvokedWithResult(false, null);
      await tester.pumpAndSettle();

      expect(find.byType(LeaveSessionSheet), findsOneWidget);
      expect(find.text(AppStrings.leaveSessionTitle), findsOneWidget);
      expect(find.text(AppStrings.leaveSessionKeepGoing), findsOneWidget);
      expect(find.text(AppStrings.leaveSessionLeave), findsOneWidget);
    });

    testWidgets(
      'tapping Finish before speaking prompts FinishPromptSheet warning',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.sessionFinishAndDebrief));
        await tester.pumpAndSettle();

        expect(find.byType(FinishPromptSheet), findsOneWidget);
        expect(find.text(AppStrings.finishWithoutSpeakingTitle), findsOneWidget);
        expect(find.text(AppStrings.leaveSessionKeepGoing), findsOneWidget);
        expect(find.text(AppStrings.leaveSessionLeave), findsOneWidget);
      },
    );
  });

  group('MissionSessionScreen - Edge Cases and Offline', () {
    testWidgets('unsupported language shows SessionUnavailableView', (
      tester,
    ) async {
      const unsupportedConfig = SessionConfig(
        missionId: 'order_coffee',
        mode: MissionMode.chat,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        targetLanguageCode: 'jp',
        explanationLanguageCode: 'en',
      );

      await tester.pumpWidget(createWidget(config: unsupportedConfig));
      await tester.pumpAndSettle();

      expect(find.byType(SessionUnavailableView), findsOneWidget);
      expect(
        find.text(AppStrings.sessionLanguageUnavailableTitle),
        findsOneWidget,
      );
    });

    testWidgets('failed delivery shows retry and delete options', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      mockRepository.simulateNetworkError = true;

      // Attempt sending suggestion
      await tester.tap(find.text("Un café, s'il vous plaît."));
      await tester.pumpAndSettle();

      // Error delivery state displayed
      expect(find.text(AppStrings.sessionMessageFailed), findsOneWidget);
      expect(find.text(AppStrings.sessionRetrySend), findsOneWidget);
      expect(find.text(AppStrings.sessionDeleteFailedMessage), findsOneWidget);

      // Turning network back on and tapping retry
      mockRepository.simulateNetworkError = false;
      await tester.tap(find.text(AppStrings.sessionRetrySend));
      await tester.pumpAndSettle();

      // Success
      expect(find.text(AppStrings.sessionMessageFailed), findsNothing);
      expect(
        find.text('Très bien, un café ! Avec du lait ou sans lait ?'),
        findsOneWidget,
      );
    });

    testWidgets('voice mode renders mic button and level dots', (tester) async {
      const voiceConfig = SessionConfig(
        missionId: 'order_coffee',
        mode: MissionMode.voice,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        targetLanguageCode: 'fr',
        explanationLanguageCode: 'en',
      );

      await tester.pumpWidget(createWidget(config: voiceConfig));
      await tester.pumpAndSettle();

      expect(find.byType(VoiceInputBar), findsOneWidget);
      expect(find.byType(MicButton), findsOneWidget);
      expect(find.byType(LevelDots), findsOneWidget);
      expect(find.text(AppStrings.sessionTypeInstead), findsOneWidget);
    });
  });

  group('MissionSessionScreen - User Isolation (AGENTS.md §6)', () {
    test('user session state resets when user changes', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => CurrentUserNotifier(
              ref.watch(profileRepositoryProvider),
              testUser,
            ),
          ),
          conversationRepositoryProvider.overrideWithValue(mockRepository),
          translationRepositoryProvider.overrideWithValue(
            mockTranslationRepository,
          ),
          textToSpeechServiceProvider.overrideWithValue(fakeTtsService),
          speechRecognizerServiceProvider.overrideWithValue(
            fakeSpeechRecognizer,
          ),
        ],
      );
      addTearDown(container.dispose);

      final subA = container.listen(
        missionSessionNotifierProvider(defaultFrenchConfig),
        (previous, next) {},
      );

      // Let session initialize
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final stateA = container.read(
        missionSessionNotifierProvider(defaultFrenchConfig),
      );
      expect(stateA.messages.isNotEmpty, isTrue);

      // Send a message
      await container
          .read(missionSessionNotifierProvider(defaultFrenchConfig).notifier)
          .sendUserMessage("Un café, s'il vous plaît.");

      final updatedA = container.read(
        missionSessionNotifierProvider(defaultFrenchConfig),
      );
      expect(updatedA.messages.length, greaterThanOrEqualTo(2));
      subA.close();

      // Switch to User B in a new container
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
          conversationRepositoryProvider.overrideWithValue(mockRepository),
          translationRepositoryProvider.overrideWithValue(
            mockTranslationRepository,
          ),
          textToSpeechServiceProvider.overrideWithValue(fakeTtsService),
          speechRecognizerServiceProvider.overrideWithValue(
            fakeSpeechRecognizer,
          ),
        ],
      );
      addTearDown(containerB.dispose);

      final subB = containerB.listen(
        missionSessionNotifierProvider(defaultFrenchConfig),
        (previous, next) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final stateB = containerB.read(
        missionSessionNotifierProvider(defaultFrenchConfig),
      );

      // User B sees only the initial greeting, no user messages from User A
      expect(stateB.messages.length, 1);
      expect(stateB.hasUserSpoken, isFalse);
      subB.close();
    });
  });

  group('MissionSessionScreen - Responsive Breakpoints (AGENTS.md §4.8)', () {
    final viewports = <String, Size>{
      'Compact Phone (360x640)': const Size(360, 640),
      'iPhone (390x844)': const Size(390, 844),
      'Large Phone (430x932)': const Size(430, 932),
      'Tablet Portrait (800x1280)': const Size(800, 1280),
      'Tablet Landscape (1280x800)': const Size(1280, 800),
      'iPad Pro (1024x1366)': const Size(1024, 1366),
      'Split-Screen (700x900)': const Size(700, 900),
    };

    for (final entry in viewports.entries) {
      testWidgets('renders cleanly at ${entry.key} in Light mode (1.0x text)', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(
            brightness: Brightness.light,
            textScale: 1.0,
            size: entry.value,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MissionSessionScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders cleanly at ${entry.key} in Dark mode (2.0x text)', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(
            brightness: Brightness.dark,
            textScale: 2.0,
            size: entry.value,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MissionSessionScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
