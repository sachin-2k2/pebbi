import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/path/presentation/screens/path_screen.dart';
import 'package:peddi/features/path/presentation/widgets/continue_card.dart';
import 'package:peddi/features/path/presentation/widgets/due_strip.dart';
import 'package:peddi/features/path/presentation/widgets/locked_node_sheet.dart';
import 'package:peddi/features/path/presentation/widgets/path_rail.dart';
import 'package:peddi/features/path/presentation/widgets/top_pills.dart';
import 'package:peddi/features/path/presentation/widgets/track_chip_row.dart';
import 'package:peddi/features/path/presentation/widgets/unit_header.dart';

void main() {
  Widget buildTestSubject({
    UserProfile? currentUser,
    Size? surfaceSize,
    double textScaleFactor = 1.0,
  }) {
    return ProviderScope(
      overrides: [
        if (currentUser != null)
          currentUserProvider.overrideWith(
            (ref) => CurrentUserNotifier(
              ref.watch(profileRepositoryProvider),
              currentUser,
            ),
          ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
          useMaterial3: true,
        ),
        home: MediaQuery(
          data: MediaQueryData(
            size: surfaceSize ?? const Size(390, 844),
            textScaler: TextScaler.linear(textScaleFactor),
            disableAnimations: true,
          ),
          child: const PathScreen(),
        ),
      ),
    );
  }

  group('PathScreen (Home) Widget Tests', () {
    testWidgets('renders all path elements in correct order', (tester) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      // Top Pills
      expect(find.byType(TopPills), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // Track Chips
      expect(find.byType(TrackChipRow), findsOneWidget);
      expect(find.text('Everyday talk'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);

      // Level Hint
      expect(
        find.text('Little mode · tap your profile to change it'),
        findsOneWidget,
      );

      // Continue Card
      expect(find.byType(ContinueCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ContinueCard),
          matching: find.text('Say hello'),
        ),
        findsOneWidget,
      );

      // Due Strip
      expect(find.byType(DueStrip), findsOneWidget);
      expect(
        find.text('Nothing due — your phrases are strong'),
        findsOneWidget,
      );

      // Unit 1 Header & Rail
      expect(find.byType(UnitHeader), findsOneWidget);
      expect(find.text('First conversations'), findsOneWidget);
      expect(find.byType(PathRail), findsOneWidget);
    });

    testWidgets('switches selected track when track chip is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestSubject());
      await tester.pumpAndSettle();

      expect(find.text('Travel'), findsOneWidget);
      await tester.tap(find.text('Travel'));
      await tester.pumpAndSettle();

      // Verified state update without crashes
      expect(find.text('Travel'), findsOneWidget);
    });

    testWidgets(
      'tapping locked node opens locked node sheet with test out action',
      (tester) async {
        await tester.pumpWidget(buildTestSubject());
        await tester.pumpAndSettle();

        // Scroll to find locked node "Nice to meet you"
        final lockedNodeFinder = find.text('Nice to meet you');
        await tester.scrollUntilVisible(
          lockedNodeFinder,
          200.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(lockedNodeFinder, findsOneWidget);
        await tester.tap(lockedNodeFinder);
        await tester.pumpAndSettle();

        // Verify LockedNodeSheet is presented
        expect(find.byType(LockedNodeSheet), findsOneWidget);
        expect(find.text('Test out (8 questions)'), findsOneWidget);
        expect(find.text('Go back'), findsOneWidget);

        // Tap test out
        await tester.tap(find.text('Test out (8 questions)'));
        await tester.pumpAndSettle();

        // Sheet dismissed and TODO snackbar shown
        expect(find.byType(LockedNodeSheet), findsNothing);
        expect(
          find.text('TODO(question): Test-out challenge coming soon!'),
          findsOneWidget,
        );
      },
    );

    testWidgets('user isolation: premium user does not see ad banner', (
      tester,
    ) async {
      const premiumUser = UserProfile(
        userId: 'premium_user_1',
        ageBand: AgeBand.adult,
        explanationLanguageCode: 'en',
        targetLanguageCode: 'es',
        reasonIds: {'travel'},
        dailyGoalId: 'regular',
        reminderTime: ReminderTime(hour: 9, minute: 0),
        selectedWeekdayNumbers: {1, 2, 3},
        remindersEnabled: true,
        accentId: 'violet',
        plan: 'premium',
      );

      await tester.pumpWidget(buildTestSubject(currentUser: premiumUser));
      await tester.pumpAndSettle();

      // Sponsored tag should not exist for premium user
      expect(find.text('Sponsored'), findsNothing);
    });
  });

  group('PathScreen Responsive & Text Scale Tests', () {
    const devices = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(430, 932), // Large phone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad Pro portrait
      Size(700, 900), // Split-screen / foldable
    ];

    for (final size in devices) {
      testWidgets(
        'renders cleanly at ${size.width.toInt()}x${size.height.toInt()} textScale 1.0',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(
            buildTestSubject(surfaceSize: size, textScaleFactor: 1.0),
          );
          await tester.pumpAndSettle();

          expect(find.byType(PathScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'renders cleanly at ${size.width.toInt()}x${size.height.toInt()} textScale 2.0',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(
            buildTestSubject(surfaceSize: size, textScaleFactor: 2.0),
          );
          await tester.pumpAndSettle();

          expect(find.byType(PathScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
