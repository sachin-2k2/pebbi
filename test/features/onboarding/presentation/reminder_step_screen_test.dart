import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/services/fake_notification_scheduler.dart';
import 'package:peddi/core/services/notification_scheduler_provider.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/reminder_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/reminder_note_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/reminder_time_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/weekday_chip.dart';
import 'package:peddi/features/onboarding/presentation/widgets/weekday_chips_row.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    GoRouter? router,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    FakeNotificationScheduler? fakeScheduler,
  }) {
    final effectiveScheduler = fakeScheduler ?? FakeNotificationScheduler();
    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/onboarding/setup/step-8',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) => const ReminderStepScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-9',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 9 Meet Pebbi Placeholder')),
            ),
            GoRoute(
              path: '/onboarding/setup/step-7',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 7 Daily Goal Screen')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        notificationSchedulerProvider.overrideWithValue(effectiveScheduler),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          return MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: effectiveRouter,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          );
        },
      ),
    );
  }

  group('ReminderStepScreen UI & Interaction Tests', () {
    testWidgets(
      'Renders header 8/11 (8/11 fill), relaxed mascot, time card, 7 weekday chips, note card, and Save and continue button',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // 1. Header 8/11 with 8/11 fill
        final header = tester.widget<StepProgressHeader>(
          find.byType(StepProgressHeader),
        );
        expect(header.currentStep, 8);
        expect(header.totalSteps, 11);
        expect(find.text('8/11'), findsOneWidget);

        final fractionBox = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: find.byType(StepProgressHeader),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(fractionBox.widthFactor, closeTo(8 / 11, 0.01));

        // 2. Mascot with relaxed expression
        final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
        expect(mascot.expression, PebbiExpression.relaxed);

        // Title and subtitle
        expect(find.text(AppStrings.reminderTitle), findsOneWidget);
        expect(find.text(AppStrings.reminderSubtitle), findsOneWidget);

        // 3. Reminder time card with default "07:00 PM"
        expect(find.byType(ReminderTimeCard), findsOneWidget);
        expect(find.text(AppStrings.reminderTimeLabel), findsOneWidget);
        expect(find.text('07:00 PM'), findsOneWidget);

        // 4. Row of 7 weekday chips, all selected
        expect(find.byType(WeekdayChipsRow), findsOneWidget);
        final chipWidgets = tester
            .widgetList<WeekdayChip>(find.byType(WeekdayChip))
            .toList();
        expect(chipWidgets.length, 7);
        for (final chip in chipWidgets) {
          expect(chip.isSelected, isTrue);
        }

        // 5. Note card with active reassurance copy
        expect(find.byType(ReminderNoteCard), findsOneWidget);
        expect(find.text(AppStrings.reminderNoteActive), findsOneWidget);

        // 6. Pinned Save and continue button
        expect(find.text(AppStrings.saveAndContinue), findsOneWidget);
        final btn = tester.widget<StepFooterButton>(
          find.byType(StepFooterButton),
        );
        expect(btn.isEnabled, isTrue);
      },
    );

    testWidgets('Tapping weekday chip toggles its selection', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Find Monday chip
      final mondayFinder = find.widgetWithText(WeekdayChip, 'M').first;
      expect(tester.widget<WeekdayChip>(mondayFinder).isSelected, isTrue);

      // Tap Monday to toggle off
      await tester.tap(mondayFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<WeekdayChip>(mondayFinder).isSelected, isFalse);

      // Tap Monday again to toggle back on
      await tester.tap(mondayFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<WeekdayChip>(mondayFinder).isSelected, isTrue);
    });

    testWidgets(
      'Deselecting all 7 days switches note card to reminders off copy without blocking Continue',
      (tester) async {
        late WidgetRef capturedRef;
        final router = GoRouter(
          initialLocation: '/onboarding/setup/step-8',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) => const ReminderStepScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: router,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Toggle off all 7 days
        for (final chip in find.byType(WeekdayChip).evaluate().toList()) {
          await tester.tap(find.byWidget(chip.widget));
          await tester.pumpAndSettle();
        }

        // Note card now displays disabled copy
        expect(find.text(AppStrings.reminderNoteDisabled), findsOneWidget);
        expect(find.text(AppStrings.reminderNoteActive), findsNothing);

        // State reflects remindersEnabled: false
        expect(
          capturedRef.read(onboardingFlowProvider).remindersEnabled,
          isFalse,
        );
        expect(
          capturedRef.read(onboardingFlowProvider).selectedWeekdayNumbers,
          isEmpty,
        );

        // Save and continue remains enabled
        final btn = tester.widget<StepFooterButton>(
          find.byType(StepFooterButton),
        );
        expect(btn.isEnabled, isTrue);
      },
    );

    testWidgets(
      'Save and continue with reminders on requests permission, schedules reminders, and navigates when granted',
      (tester) async {
        final scheduler = FakeNotificationScheduler(
          permissionGrantedResult: true,
        );
        late WidgetRef capturedRef;

        final router = GoRouter(
          initialLocation: '/onboarding/setup/step-8',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) => const ReminderStepScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-9',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 9 Meet Pebbi Placeholder')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notificationSchedulerProvider.overrideWithValue(scheduler),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: router,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Save and continue
        await tester.tap(find.text(AppStrings.saveAndContinue));
        await tester.pumpAndSettle();

        // Permission was requested
        expect(scheduler.wasPermissionRequested, isTrue);

        // Reminders were scheduled
        expect(scheduler.scheduledReminders.length, 1);
        expect(scheduler.scheduledReminders.first['hour'], 19);
        expect(scheduler.scheduledReminders.first['minute'], 0);
        expect(scheduler.scheduledReminders.first['weekdays'], {
          1,
          2,
          3,
          4,
          5,
          6,
          7,
        });

        // State updated
        final state = capturedRef.read(onboardingFlowProvider);
        expect(state.remindersEnabled, isTrue);
        expect(state.notificationPermissionGranted, isTrue);

        // Navigated to step 9
        expect(find.text('Step 9 Meet Pebbi Placeholder'), findsOneWidget);
      },
    );

    testWidgets(
      'Save and continue when permission is denied does not block and shows non-blocking notice',
      (tester) async {
        final scheduler = FakeNotificationScheduler(
          permissionGrantedResult: false,
        );
        late WidgetRef capturedRef;

        final router = GoRouter(
          initialLocation: '/onboarding/setup/step-8',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) => const ReminderStepScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-9',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 9 Meet Pebbi Placeholder')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notificationSchedulerProvider.overrideWithValue(scheduler),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: router,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Save and continue
        await tester.tap(find.text(AppStrings.saveAndContinue));
        await tester.pumpAndSettle();

        // Permission was requested
        expect(scheduler.wasPermissionRequested, isTrue);

        // Notice is shown
        expect(find.text(AppStrings.remindersDisabledNotice), findsOneWidget);

        // State reflects permissionGranted: false
        final state = capturedRef.read(onboardingFlowProvider);
        expect(state.remindersEnabled, isTrue);
        expect(state.notificationPermissionGranted, isFalse);

        // Still navigated to step 9 without blocking
        expect(find.text('Step 9 Meet Pebbi Placeholder'), findsOneWidget);
      },
    );

    testWidgets(
      'Save and continue with 0 days cancels reminders, does not ask permission, and navigates',
      (tester) async {
        final scheduler = FakeNotificationScheduler();
        late WidgetRef capturedRef;

        final router = GoRouter(
          initialLocation: '/onboarding/setup/step-8',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) => const ReminderStepScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-9',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 9 Meet Pebbi Placeholder')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notificationSchedulerProvider.overrideWithValue(scheduler),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: router,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Deselect all days
        for (final chip in find.byType(WeekdayChip).evaluate().toList()) {
          await tester.tap(find.byWidget(chip.widget));
          await tester.pumpAndSettle();
        }

        // Tap Save and continue
        await tester.tap(find.text(AppStrings.saveAndContinue));
        await tester.pumpAndSettle();

        // Permission was NOT requested because reminders are off
        expect(scheduler.wasPermissionRequested, isFalse);
        // Reminders were cancelled
        expect(scheduler.wereRemindersCancelled, isTrue);

        // State has remindersEnabled: false
        expect(
          capturedRef.read(onboardingFlowProvider).remindersEnabled,
          isFalse,
        );

        // Navigated to step 9
        expect(find.text('Step 9 Meet Pebbi Placeholder'), findsOneWidget);
      },
    );

    testWidgets('Selection survives forward and back navigation', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/onboarding/setup/step-8',
        routes: [
          GoRoute(
            path: '/onboarding/setup/step-8',
            builder: (context, state) => const ReminderStepScreen(),
          ),
          GoRoute(
            path: '/onboarding/setup/step-9',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/onboarding/setup/step-8'),
                child: const Text('Go back to 8'),
              ),
            ),
          ),
        ],
      );

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              return MaterialApp.router(
                theme: AppTheme.light(),
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Deselect Sunday (last chip)
      final sundayFinder = find.widgetWithText(WeekdayChip, 'S').last;
      await tester.tap(sundayFinder);
      await tester.pumpAndSettle();

      // Tap Save and continue
      await tester.tap(find.text(AppStrings.saveAndContinue));
      await tester.pumpAndSettle();
      expect(find.text('Go back to 8'), findsOneWidget);

      // Return to step 8
      await tester.tap(find.text('Go back to 8'));
      await tester.pumpAndSettle();

      // Sunday is still unselected (6 days selected)
      expect(capturedRef.read(onboardingFlowProvider).selectedWeekdayNumbers, {
        1,
        2,
        3,
        4,
        5,
        6,
      });
      expect(tester.widget<WeekdayChip>(sundayFinder).isSelected, isFalse);
    });
  });

  group('ReminderStepScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet, portrait
      Size(1280, 800), // Android tablet, landscape
      Size(1024, 1366), // iPad Pro
      Size(700, 400), // Short landscape window
    ];

    for (final size in testSizes) {
      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 1.0x & 2.0x scale (button always visible)',
        (tester) async {
          for (final scale in [1.0, 2.0]) {
            tester.view.physicalSize = size * 2.0;
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(buildTestableScreen(textScale: scale));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            // Save and continue button must always be visible and tappable
            expect(find.text(AppStrings.saveAndContinue), findsOneWidget);
            await tester.tap(find.text(AppStrings.saveAndContinue));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  });
}
