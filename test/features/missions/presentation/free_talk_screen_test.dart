import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/back_link.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/design_system/notice_banner.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/missions/domain/correction_style.dart';
import 'package:peddi/features/missions/presentation/providers/free_talk_provider.dart';
import 'package:peddi/features/missions/presentation/screens/free_talk_screen.dart';
import 'package:peddi/features/missions/presentation/screens/mission_session_placeholder_screen.dart';
import 'package:peddi/features/missions/presentation/widgets/free_talk/correction_style_card.dart';
import 'package:peddi/features/missions/presentation/widgets/free_talk/custom_topic_sheet.dart';
import 'package:peddi/features/missions/presentation/widgets/free_talk/topic_chip.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  const spanishUser = UserProfile(
    userId: 'user_es',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: {},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1},
    remindersEnabled: false,
    accentId: 'violet',
    plan: 'free',
  );

  const frenchUser = UserProfile(
    userId: 'user_fr',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'fr',
    reasonIds: {},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1},
    remindersEnabled: false,
    accentId: 'violet',
    plan: 'free',
  );

  void setTestViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildSubject({
    UserProfile currentUser = spanishUser,
    bool isOffline = false,
    CorrectionStyle? initialStyle,
  }) {
    final router = GoRouter(
      initialLocation: '/missions/free-talk',
      routes: [
        GoRoute(
          path: '/missions',
          builder: (context, state) =>
              const Scaffold(body: Text('Missions Tab')),
        ),
        GoRoute(
          path: '/missions/free-talk',
          builder: (context, state) => const FreeTalkScreen(),
        ),
        GoRoute(
          path: '/missions/session',
          builder: (context, state) {
            final topicId = state.uri.queryParameters['topicId'] ?? '';
            final style = state.uri.queryParameters['style'] ?? 'gentle';
            return MissionSessionPlaceholderScreen(
              topicId: topicId,
              correctionStyle: style,
            );
          },
        ),
        GoRoute(
          path: '/premium',
          builder: (context, state) =>
              const Scaffold(body: Text('Premium Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(initialProfile: currentUser),
        ),
        freeTalkIsOfflineProvider.overrideWith((ref) => isOffline),
        if (initialStyle != null)
          freeTalkCorrectionStyleProvider.overrideWith(
            (ref) => FreeTalkCorrectionStyleNotifier(
              ref.watch(freeTalkRepositoryProvider),
              currentUser.userId,
            )..selectStyle(initialStyle),
          ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
          useMaterial3: true,
        ),
      ),
    );
  }

  testWidgets('renders all visual elements matching design screenshot', (
    tester,
  ) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pumpAndSettle();

    // Back link
    expect(find.byType(BackLink), findsOneWidget);
    expect(find.text(AppStrings.missionsLink), findsOneWidget);

    // Title & dynamic subtitle
    expect(find.text(AppStrings.freeTalkScreenTitle), findsOneWidget);
    expect(
      find.text(AppStrings.freeTalkScreenSubtitle('Spanish')),
      findsOneWidget,
    );

    // All 8 topic chips from design screenshot
    expect(find.byType(TopicChip), findsNWidgets(8));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Hobbies'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Dreams'), findsOneWidget);
    expect(find.text('My own'), findsOneWidget);

    // Correction style card
    expect(find.byType(CorrectionStyleCard), findsOneWidget);
    expect(find.text(AppStrings.correctionStyleLabel), findsOneWidget);
    expect(find.text(AppStrings.correctionStyleGentle), findsOneWidget);
    expect(find.text(AppStrings.correctionStyleLive), findsOneWidget);
    expect(find.text(AppStrings.correctionStyleNone), findsOneWidget);

    // Default style is Gentle with check icon and debrief helper line
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text(AppStrings.correctionHelperGentle), findsOneWidget);
  });

  testWidgets(
    'interpolates target language name dynamically in subtitle for French',
    (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildSubject(currentUser: frenchUser));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.freeTalkScreenSubtitle('French')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tapping a normal topic chip immediately starts session with selected style',
    (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap 'Food'
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Navigates to session placeholder
      expect(find.byType(MissionSessionPlaceholderScreen), findsOneWidget);
      expect(find.text('Topic: food'), findsOneWidget);
      expect(find.text('Correction style: gentle'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping My own opens CustomTopicSheet and validates input before starting',
    (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap 'My own'
      await tester.tap(find.text('My own'));
      await tester.pumpAndSettle();

      // Sheet is visible
      expect(find.byType(CustomTopicSheet), findsOneWidget);
      expect(find.text(AppStrings.customTopicSheetTitle), findsOneWidget);

      // Button3D should be disabled when text field is empty
      final buttonFinder = find.widgetWithText(
        Button3D,
        AppStrings.customTopicStart,
      );
      expect(buttonFinder, findsOneWidget);
      final buttonWidget = tester.widget<Button3D>(buttonFinder);
      expect(buttonWidget.onPressed, isNull);

      // Enter valid custom topic
      await tester.enterText(find.byType(TextField), 'Space exploration');
      await tester.pumpAndSettle();

      // Button3D is now enabled
      final enabledButton = tester.widget<Button3D>(buttonFinder);
      expect(enabledButton.onPressed, isNotNull);

      // Tap button to submit
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Navigates to session placeholder with custom text
      expect(find.byType(MissionSessionPlaceholderScreen), findsOneWidget);
      expect(find.text('Topic: Space exploration'), findsOneWidget);
      expect(find.text('Correction style: gentle'), findsOneWidget);
    },
  );

  testWidgets(
    'changing correction style updates helper text and passes updated style to session',
    (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pumpAndSettle();

      // Initially gentle
      expect(find.text(AppStrings.correctionHelperGentle), findsOneWidget);

      // Switch to Live
      await tester.ensureVisible(find.text(AppStrings.correctionStyleLive));
      await tester.tap(find.text(AppStrings.correctionStyleLive));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.correctionHelperLive), findsOneWidget);

      // Switch to None
      await tester.ensureVisible(find.text(AppStrings.correctionStyleNone));
      await tester.tap(find.text(AppStrings.correctionStyleNone));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.correctionHelperNone), findsOneWidget);

      // Tap a topic now; should carry 'none'
      await tester.ensureVisible(find.text('Work'));
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      expect(find.byType(MissionSessionPlaceholderScreen), findsOneWidget);
      expect(find.text('Topic: work'), findsOneWidget);
      expect(find.text('Correction style: none'), findsOneWidget);
    },
  );

  testWidgets(
    'offline mode displays notice banner and blocks starting conversation with SnackBar',
    (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildSubject(isOffline: true));
      await tester.pump();
      await tester.pumpAndSettle();

      // Notice banner is visible
      expect(find.byType(NoticeBanner), findsOneWidget);
      expect(
        find.text(AppStrings.freeTalkOfflineNotice),
        findsAtLeastNWidgets(1),
      );

      // Tap a topic chip
      await tester.tap(find.text('Food'));
      await tester.pump();

      // SnackBar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(AppStrings.freeTalkOfflineNotice),
        findsAtLeastNWidgets(2),
      );

      // Did not navigate to session
      expect(find.byType(MissionSessionPlaceholderScreen), findsNothing);
    },
  );
}
