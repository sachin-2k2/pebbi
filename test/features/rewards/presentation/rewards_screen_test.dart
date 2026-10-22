import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/features/review/data/fake_share_service.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/rewards/data/mock_rewards_repository.dart';
import 'package:peddi/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:peddi/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:peddi/features/rewards/presentation/widgets/badge_card.dart';
import 'package:peddi/features/rewards/presentation/widgets/badge_detail_sheet.dart';
import 'package:peddi/features/rewards/presentation/widgets/badge_progress_bar.dart';
import 'package:peddi/features/rewards/presentation/widgets/goal_ring.dart';
import 'package:peddi/features/rewards/presentation/widgets/level_badge.dart';
import 'package:peddi/features/rewards/presentation/widgets/progress_header.dart';
import 'package:peddi/features/rewards/presentation/widgets/stat_tile.dart';
import 'package:peddi/features/rewards/presentation/widgets/streak_card.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildSubject({
    MockRewardsRepository? repository,
    FakeShareService? shareService,
    GoRouter? router,
  }) {
    final repo = repository ?? MockRewardsRepository();
    final fakeShare = shareService ?? FakeShareService();

    if (router != null) {
      return ProviderScope(
        overrides: [
          rewardsRepositoryProvider.overrideWithValue(repo),
          shareServiceProvider.overrideWithValue(fakeShare),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    return ProviderScope(
      overrides: [
        rewardsRepositoryProvider.overrideWithValue(repo),
        shareServiceProvider.overrideWithValue(fakeShare),
      ],
      child: const MaterialApp(home: RewardsScreen()),
    );
  }

  group('RewardsScreen Widget Tests (Faithful to 3 Screenshots)', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Renders all elements of default screenshot state faithfully', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 1. Progress Header
      expect(find.byType(ProgressHeader), findsOneWidget);
      expect(find.text(AppStrings.rewardsTitle), findsOneWidget);
      expect(
        find.text(
          AppStrings.rewardsSubtitle('Spanish', 1, "Pebbi's little scarf"),
        ),
        findsOneWidget,
      );
      final levelBadge = tester.widget<LevelBadge>(find.byType(LevelBadge));
      expect(levelBadge.level, 1);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // 2. Three Stat Tiles
      expect(find.byType(StatTile), findsNWidgets(3));
      expect(find.text(AppStrings.rewardsStopsDoneLabel), findsOneWidget);
      expect(find.text(AppStrings.rewardsPhrasesLabel), findsOneWidget);
      expect(find.text(AppStrings.rewardsStarsLabel), findsOneWidget);
      expect(find.text('0'), findsNWidgets(3)); // 0 stops, 0 phrases, 0 stars

      // 3. Daily Goal Card
      expect(find.text(AppStrings.rewardsDailyGoalTitle(1)), findsOneWidget);
      expect(find.text(AppStrings.rewardsDailyGoalMissed), findsOneWidget);
      expect(find.text(AppStrings.rewardsReminderSet('19:00')), findsOneWidget);
      expect(find.byType(GoalRing), findsOneWidget);
      expect(find.text(AppStrings.rewardsLevelCaption(1)), findsOneWidget);
      expect(
        find.text(AppStrings.rewardsNextLevelCaption(2, 40)),
        findsOneWidget,
      );

      // 4. Streak Card
      expect(find.byType(StreakCard), findsOneWidget);
      expect(find.text(AppStrings.rewardsStreakTitle(1)), findsOneWidget);
      expect(find.text(AppStrings.rewardsStreakSubtitle(1, 2)), findsOneWidget);
      expect(find.text(AppStrings.rewardsCalendarPill), findsOneWidget);

      // 5. Calendar Card
      expect(find.text(AppStrings.rewardsLast4WeeksTitle), findsOneWidget);
      expect(find.text(AppStrings.rewardsCalendarRepairNote), findsOneWidget);

      // 6. Quests Card
      expect(find.text(AppStrings.rewardsQuestsTitle), findsOneWidget);
      expect(find.text(AppStrings.rewardsQuestsDone(0, 4)), findsOneWidget);
      expect(find.text('Practise one lesson today'), findsOneWidget);
      expect(find.text('Finish a real-life mission'), findsOneWidget);
      expect(find.text('Get 10 phrases to strong'), findsOneWidget);
      expect(find.text('Three days in a row'), findsOneWidget);
      expect(find.text('0/1'), findsNWidgets(2));
      expect(find.text('0/10'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text(AppStrings.rewardsChestNote), findsOneWidget);

      // 7. Invite Card
      expect(find.text(AppStrings.inviteCardTitle), findsOneWidget);
      expect(find.text(AppStrings.inviteShareButton), findsOneWidget);

      // 8. Badges Section
      expect(find.text(AppStrings.rewardsBadgesTitle), findsOneWidget);
      expect(find.text(AppStrings.rewardsBadgesEarnedCount(0)), findsOneWidget);
      expect(find.byType(BadgeCard), findsNWidgets(12));

      // 12 badge names
      expect(find.text('First hello'), findsOneWidget);
      expect(find.text('10 stars'), findsOneWidget);
      expect(find.text('Review hero'), findsOneWidget);
      expect(find.text('Conversation starter'), findsOneWidget);
      expect(find.text('Café regular'), findsOneWidget);
      expect(find.text('Voice starter'), findsOneWidget);
      expect(find.text('Three days running'), findsOneWidget);
      expect(find.text('Week of fire'), findsOneWidget);
      expect(find.text('Scene stealer'), findsOneWidget);
      expect(find.text('Script explorer'), findsOneWidget);
      expect(find.text('Polyglot heart'), findsOneWidget);
      expect(find.text('Fifty stars'), findsOneWidget);

      // Progress bars: 9 badges have targetProgress, 3 do not
      expect(find.byType(BadgeProgressBar), findsNWidgets(9));

      // 9. Sticker Book Button
      expect(find.text(AppStrings.rewardsStickerBookButton(0)), findsOneWidget);

      // 10. Next Chapter Note
      expect(find.text(AppStrings.rewardsNextChapterNote), findsOneWidget);
    });

    testWidgets(
      'Renders mid-state correctly (earned badges & completed goal)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = MockRewardsRepository(
          initialSummary: MockRewardsRepository.createMidState(),
        );
        await tester.pumpWidget(buildSubject(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.rewardsDailyGoalDone), findsOneWidget);
        expect(find.text(AppStrings.rewardsStreakTitle(8)), findsOneWidget);
        expect(
          find.text(AppStrings.rewardsStreakSubtitle(8, 1)),
          findsOneWidget,
        );
        expect(
          find.text(AppStrings.rewardsBadgesEarnedCount(3)),
          findsOneWidget,
        );
        expect(find.textContaining('Student cap'), findsOneWidget);
        expect(find.text('Level 3'), findsOneWidget);
        expect(
          find.text(AppStrings.rewardsStickerBookButton(3)),
          findsOneWidget,
        );
      },
    );

    testWidgets('Renders max-level state correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MockRewardsRepository(
        initialSummary: MockRewardsRepository.createMaxLevelState(),
      );
      await tester.pumpWidget(buildSubject(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Level 8'), findsOneWidget);
      expect(find.textContaining('Crown & Cape'), findsOneWidget);
      expect(find.text(AppStrings.rewardsTopLevel), findsOneWidget);
    });

    testWidgets('Tapping badge opens BadgeDetailSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('First hello'),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('First hello'));
      await tester.pumpAndSettle();

      expect(find.byType(BadgeDetailSheet), findsOneWidget);
      expect(find.text('Finish your first stop'), findsOneWidget);

      await tester.tap(find.text(AppStrings.rewardsBadgeDetailClose));
      await tester.pumpAndSettle();

      expect(find.byType(BadgeDetailSheet), findsNothing);
    });

    testWidgets('Tapping Copy on InviteCard copies link', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (message) async {
          if (message.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text(AppStrings.inviteCopy),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(AppStrings.inviteCopy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppStrings.inviteCopied), findsOneWidget);
    });

    testWidgets('Tapping Share on InviteCard invokes ShareService', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeShare = FakeShareService();
      await tester.pumpWidget(buildSubject(shareService: fakeShare));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text(AppStrings.inviteShareButton),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(AppStrings.inviteShareButton));
      await tester.pumpAndSettle();

      expect(fakeShare.shareCount, 1);
    });

    testWidgets('Tapping gear button and sticker book button triggers router', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? lastNavigatedRoute;
      final testRouter = GoRouter(
        initialLocation: '/rewards',
        routes: [
          GoRoute(
            path: '/rewards',
            builder: (context, state) => const RewardsScreen(),
            routes: [
              GoRoute(
                path: 'sticker-book',
                builder: (context, state) {
                  lastNavigatedRoute = '/rewards/sticker-book';
                  return const Scaffold(body: Text('Sticker book page'));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) {
              lastNavigatedRoute = '/settings';
              return const Scaffold(body: Text('Settings page'));
            },
          ),
        ],
      );

      await tester.pumpWidget(buildSubject(router: testRouter));
      await tester.pumpAndSettle();

      // Tap settings button
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, '/settings');

      // Go back to rewards
      testRouter.go('/rewards');
      await tester.pumpAndSettle();

      // Tap sticker book button
      await tester.scrollUntilVisible(
        find.text(AppStrings.rewardsStickerBookButton(0)),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(AppStrings.rewardsStickerBookButton(0)));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, '/rewards/sticker-book');
    });
  });
}
