import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/notice_banner.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/missions/data/mock_mission_repository.dart';
import 'package:peddi/features/missions/domain/mission_category.dart';
import 'package:peddi/features/missions/domain/mission_summary.dart';
import 'package:peddi/features/missions/domain/today_mission.dart';
import 'package:peddi/features/missions/presentation/providers/missions_provider.dart';
import 'package:peddi/features/missions/presentation/screens/emergency_phrasebook_placeholder_screen.dart';
import 'package:peddi/features/missions/presentation/screens/free_talk_placeholder_screen.dart';
import 'package:peddi/features/missions/presentation/screens/mission_brief_placeholder_screen.dart';
import 'package:peddi/features/missions/presentation/screens/missions_screen.dart';
import 'package:peddi/features/missions/presentation/widgets/category_chip_row.dart';
import 'package:peddi/features/missions/presentation/widgets/mission_tile.dart';
import 'package:peddi/features/missions/presentation/widgets/missions_header.dart';
import 'package:peddi/features/missions/presentation/widgets/quick_action_row.dart';
import 'package:peddi/features/missions/presentation/widgets/today_mission_card.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/premium/presentation/screens/premium_screen.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  const testUser = UserProfile(
    userId: 'user_test',
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

  Widget buildTestSubject({
    UserProfile? currentUser = testUser,
    MockMissionRepository? customRepo,
    MissionsState? overrideState,
    Size surfaceSize = const Size(390, 844),
    double textScale = 1.0,
  }) {
    final repo = customRepo ?? MockMissionRepository();

    final router = GoRouter(
      initialLocation: '/missions',
      routes: [
        GoRoute(
          path: '/missions',
          builder: (context, state) => const MissionsScreen(),
        ),
        GoRoute(
          path: '/missions/brief/:id',
          builder: (context, state) => MissionBriefPlaceholderScreen(
            missionId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/missions/emergency-phrasebook',
          builder: (context, state) =>
              const EmergencyPhrasebookPlaceholderScreen(),
        ),
        GoRoute(
          path: '/missions/free-talk',
          builder: (context, state) => const FreeTalkPlaceholderScreen(),
        ),
        GoRoute(
          path: '/premium/options',
          builder: (context, state) => const PremiumScreen(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        missionRepositoryProvider.overrideWithValue(repo),
        if (currentUser != null)
          currentUserProvider.overrideWith(
            (ref) => CurrentUserNotifier(
              ref.watch(profileRepositoryProvider),
              currentUser,
            ),
          ),
        if (overrideState != null)
          missionsStateProvider.overrideWith((ref) => overrideState),
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

  group('MissionsScreen Widget Tests', () {
    testWidgets('renders all screen sections and elements in order', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.byType(MissionsHeader), findsOneWidget);
      expect(find.text(AppStrings.missionsTitle), findsOneWidget);
      expect(find.text(AppStrings.missionsSubtitle), findsOneWidget);

      // 2. Today's Mission Card
      expect(find.byType(TodayMissionCard), findsOneWidget);
      expect(find.text(AppStrings.todaysMissionOverline), findsOneWidget);
      expect(find.text('Order a coffee'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Lucía, barista'), findsAtLeastNWidgets(1));

      // 3. Quick Action Cards
      expect(find.byType(QuickActionRow), findsOneWidget);
      expect(find.text(AppStrings.emergencyPhrasebook), findsOneWidget);
      expect(find.text(AppStrings.freeTalk), findsOneWidget);

      // 4. Section Title
      expect(find.text(AppStrings.situationsTitle), findsOneWidget);

      // 5. Category Chips
      expect(find.byType(CategoryChipRow), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Everyday'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);

      // 6. Mission Tiles
      expect(find.text('Ask for directions'), findsOneWidget);
      expect(find.text('Check into a hotel'), findsOneWidget);
      expect(find.text('At the pharmacy'), findsOneWidget);
      expect(find.text('Shop at the market'), findsOneWidget);
    });

    testWidgets('category chips filter the displayed mission list', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      // Before filtering: 'Order a coffee' and 'Ask for directions' are both present
      expect(find.text('Order a coffee'), findsAtLeastNWidgets(1));
      expect(find.text('Ask for directions'), findsOneWidget);

      // Tap 'Travel' category chip
      await tester.tap(find.text('Travel'));
      await tester.pumpAndSettle();

      // 'Travel' missions should be present in the list
      expect(find.text('Ask for directions'), findsOneWidget);
      expect(find.text('Check into a hotel'), findsOneWidget);

      // 'Order a coffee' (Everyday) is not in the filtered mission list
      final coffeeInList = find.descendant(
        of: find.byType(MissionTile),
        matching: find.text('Order a coffee'),
      );
      expect(coffeeInList, findsNothing);
    });

    testWidgets(
      'tapping Today Mission card opens brief placeholder with correct ID',
      (tester) async {
        await tester.pumpWidget(buildTestSubject());
        await tester.pumpAndSettle();

        // Tap the hero card
        await tester.tap(find.byType(TodayMissionCard));
        await tester.pumpAndSettle();

        // Navigated to brief screen
        expect(find.byType(MissionBriefPlaceholderScreen), findsOneWidget);
        expect(find.text('Mission ID: order_coffee'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a mission row opens brief placeholder with correct ID',
      (tester) async {
        await tester.pumpWidget(buildTestSubject());
        await tester.pumpAndSettle();

        // Tap 'Ask for directions'
        await tester.tap(find.text('Ask for directions'));
        await tester.pumpAndSettle();

        // Navigated to brief screen
        expect(find.byType(MissionBriefPlaceholderScreen), findsOneWidget);
        expect(find.text('Mission ID: ask_directions'), findsOneWidget);
      },
    );

    testWidgets('tapping Emergency phrasebook opens emergency placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.emergencyPhrasebook));
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyPhrasebookPlaceholderScreen), findsOneWidget);
    });

    testWidgets('tapping Free talk opens free talk placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.freeTalk));
      await tester.pumpAndSettle();

      expect(find.byType(FreeTalkPlaceholderScreen), findsOneWidget);
    });

    testWidgets('tapping premium-locked row opens Premium options screen', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      // Scroll down to reveal 'Job interview'
      await tester.scrollUntilVisible(
        find.text('Job interview'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Job interview'), findsOneWidget);
      await tester.tap(find.text('Job interview'));
      await tester.pumpAndSettle();

      // Navigated to PremiumScreen
      expect(find.byType(PremiumScreen), findsOneWidget);
    });

    testWidgets(
      'renders offline banner and blocks mission start with dialog when offline',
      (tester) async {
        final offlineState = MissionsState(
          isOffline: true,
          categories: const [MissionCategory(id: 'all', title: 'All')],
          missions: const [
            MissionSummary(
              id: 'offline_scene',
              categoryIds: ['all'],
              title: 'Offline Scene',
              characterName: 'Leo',
              characterRole: 'guide',
              durationMinutes: 5,
              difficulty: 1,
              emoji: '🗺️',
            ),
          ],
        );

        await tester.pumpWidget(buildTestSubject(overrideState: offlineState));
        await tester.pumpAndSettle();

        // Offline banner shown
        expect(find.byType(NoticeBanner), findsOneWidget);
        expect(find.text(AppStrings.offlineBannerNotice), findsOneWidget);

        // Tap mission -> triggers "Internet required" dialog
        await tester.tap(find.text('Offline Scene'));
        await tester.pumpAndSettle();

        expect(
          find.text(AppStrings.offlineMissionBlockedTitle),
          findsOneWidget,
        );
        expect(
          find.text(AppStrings.offlineMissionBlockedMessage),
          findsOneWidget,
        );

        // Dismiss dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Emergency Phrasebook STILL opens offline!
        await tester.tap(find.text(AppStrings.emergencyPhrasebook));
        await tester.pumpAndSettle();
        expect(
          find.byType(EmergencyPhrasebookPlaceholderScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets('omits Today Mission card when todayMission is null', (
      tester,
    ) async {
      final noTodayState = MissionsState(
        categories: const [MissionCategory(id: 'all', title: 'All')],
        missions: const [
          MissionSummary(
            id: 'scene_1',
            categoryIds: ['all'],
            title: 'Scene 1',
            characterName: 'Leo',
            characterRole: 'guide',
            durationMinutes: 5,
            difficulty: 1,
            emoji: '🗺️',
          ),
        ],
        todayMission: null,
      );

      await tester.pumpWidget(buildTestSubject(overrideState: noTodayState));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMissionCard), findsNothing);
      expect(find.text(AppStrings.todaysMissionOverline), findsNothing);
      expect(find.text('Scene 1'), findsOneWidget);
    });

    testWidgets('shows Done tag on completed today mission', (tester) async {
      final doneToday = TodayMission(
        mission: const MissionSummary(
          id: 'done_scene',
          categoryIds: ['all'],
          title: 'Done Scene',
          characterName: 'Leo',
          characterRole: 'guide',
          durationMinutes: 5,
          difficulty: 1,
          emoji: '☕',
          status: MissionStatus.done,
        ),
        isCompleted: true,
      );

      final state = MissionsState(
        categories: const [MissionCategory(id: 'all', title: 'All')],
        missions: const [],
        todayMission: doneToday,
      );

      await tester.pumpWidget(buildTestSubject(overrideState: state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.missionTagDone), findsOneWidget);
    });
  });
}
