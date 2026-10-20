import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/benefit_chip.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/premium/data/mock_purchase_repository.dart';
import 'package:peddi/features/premium/domain/purchase_repository.dart';
import 'package:peddi/features/premium/domain/purchase_state.dart';
import 'package:peddi/features/premium/domain/subscription_plan.dart';
import 'package:peddi/features/premium/presentation/providers/purchase_provider.dart';
import 'package:peddi/features/premium/presentation/screens/premium_screen.dart';
import 'package:peddi/features/premium/presentation/widgets/already_premium_card.dart';
import 'package:peddi/features/premium/presentation/widgets/benefit_check_row.dart';
import 'package:peddi/features/premium/presentation/widgets/floating_emoji_decoration.dart';
import 'package:peddi/features/premium/presentation/widgets/plan_card.dart';
import 'package:peddi/features/premium/presentation/widgets/plan_card_skeleton.dart';
import 'package:peddi/features/premium/presentation/widgets/premium_feature_card.dart';
import 'package:peddi/features/premium/presentation/widgets/purchase_error_banner.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  const dummyProfile = UserProfile(
    userId: 'guest_test',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: {'travel'},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1, 2, 3, 4, 5},
    remindersEnabled: true,
    accentId: 'violet',
    plan: 'free',
  );

  Widget buildTestableScreen({
    PurchaseRepository? purchaseRepo,
    UserProfile? userProfile = dummyProfile,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    GoRouter? customRouter,
  }) {
    final repo = purchaseRepo ?? MockPurchaseRepository();

    final router =
        customRouter ??
        GoRouter(
          initialLocation: '/premium/options',
          routes: [
            GoRoute(
              path: '/premium/options',
              builder: (context, state) => const PremiumScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-10',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 10')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        purchaseRepositoryProvider.overrideWithValue(repo),
        currentUserProvider.overrideWith((ref) {
          final notifier = CurrentUserNotifier(
            ref.watch(profileRepositoryProvider),
          );
          if (userProfile != null) {
            notifier.saveProfile(userProfile);
          }
          return notifier;
        }),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final settings = ref.watch(appSettingsProvider);
          return MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale * settings.textScale),
                ),
                child: widget!,
              );
            },
          );
        },
      ),
    );
  }

  group('PremiumScreen Visual Hierarchy Matches Screenshot', () {
    testWidgets(
      'renders purple header, logo tile, title, and floating emojis',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Title & Subtitle
        expect(find.text(AppStrings.unlockAllTitle), findsOneWidget);
        expect(find.text(AppStrings.unlockAllSubtitle), findsOneWidget);

        // Logo tile with PebbiMascot
        expect(find.byType(PebbiMascot), findsOneWidget);

        // Floating decorations
        expect(find.byType(FloatingEmojiDecoration), findsOneWidget);

        // Close button with semantic label
        expect(
          find.bySemanticsLabel(AppStrings.closeSemantics),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders all 6 feature cards with exact titles and captions', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.byType(PremiumFeatureCard), findsNWidgets(6));

      expect(find.text(AppStrings.premiumFeatureUnitsTitle), findsOneWidget);
      expect(find.text(AppStrings.premiumFeatureUnitsCaption), findsOneWidget);

      expect(
        find.text(AppStrings.premiumFeatureLanguagesTitle),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.premiumFeatureLanguagesCaption),
        findsOneWidget,
      );

      expect(find.text(AppStrings.premiumFeatureMissionsTitle), findsOneWidget);
      expect(
        find.text(AppStrings.premiumFeatureMissionsCaption),
        findsOneWidget,
      );

      expect(find.text(AppStrings.premiumFeatureNoAdsTitle), findsOneWidget);
      expect(find.text(AppStrings.premiumFeatureNoAdsCaption), findsOneWidget);

      expect(find.text(AppStrings.premiumFeatureOfflineTitle), findsOneWidget);
      expect(
        find.text(AppStrings.premiumFeatureOfflineCaption),
        findsOneWidget,
      );

      expect(find.text(AppStrings.premiumFeatureExamsTitle), findsOneWidget);
      expect(find.text(AppStrings.premiumFeatureExamsCaption), findsOneWidget);
    });

    testWidgets(
      r'renders default plan card with $3.99, /month, trial line, and mint button',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        expect(find.byType(PlanCard), findsOneWidget);
        expect(find.text(AppStrings.defaultPlanTitle), findsOneWidget);
        expect(find.text(AppStrings.mostPopularPill), findsOneWidget);
        expect(find.text(r'$3.99'), findsOneWidget);
        expect(find.text('/month'), findsOneWidget);
        expect(find.text(AppStrings.trialDaysLine(7)), findsOneWidget);

        // 3 check rows
        expect(find.byType(BenefitCheckRow), findsNWidgets(3));
        expect(find.text(AppStrings.planBenefitEveryUnit), findsOneWidget);
        expect(find.text(AppStrings.planBenefitChestsBadges), findsOneWidget);
        expect(find.text(AppStrings.planBenefitCancelAnyTime), findsOneWidget);

        // Full-width Mint button
        expect(find.text(AppStrings.startMyFreeWeek), findsOneWidget);

        // Compliance Legal footer
        expect(find.text(AppStrings.legalTerms), findsOneWidget);
        expect(find.text(AppStrings.legalPrivacy), findsOneWidget);
        expect(find.text(AppStrings.legalRestore), findsOneWidget);
      },
    );
  });

  group('Dynamic Data & Eligibility Variations', () {
    testWidgets(
      'changing mock price and trial days updates displayed strings',
      (tester) async {
        final customRepo = MockPurchaseRepository(
          initialPlans: [
            const SubscriptionPlan(
              id: 'pebbi_monthly',
              title: 'Pebbi Monthly',
              formattedPrice: '£4.99',
              billingPeriod: 'month',
              trialDays: 14,
              isMostPopular: true,
              trialEligible: true,
              benefits: ['Custom benefit'],
            ),
          ],
        );

        await tester.pumpWidget(buildTestableScreen(purchaseRepo: customRepo));
        await tester.pumpAndSettle();

        expect(find.text('£4.99'), findsOneWidget);
        expect(
          find.text('First 14 days free · cancel any time, in one tap'),
          findsOneWidget,
        );
        expect(find.text('Custom benefit'), findsOneWidget);
      },
    );

    testWidgets(
      'trial ineligible hides trial line and updates button to Subscribe',
      (tester) async {
        final ineligibleRepo = MockPurchaseRepository(
          initialPlans: [
            const SubscriptionPlan(
              id: 'pebbi_monthly',
              title: 'Pebbi Monthly',
              formattedPrice: r'$3.99',
              billingPeriod: 'month',
              trialDays: 7,
              isMostPopular: true,
              trialEligible: false,
              benefits: ['Unit 1'],
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableScreen(purchaseRepo: ineligibleRepo),
        );
        await tester.pumpAndSettle();

        // Trial line is hidden
        expect(find.textContaining('days free'), findsNothing);

        // Button reflects ineligible state
        expect(find.text(AppStrings.subscribeAction), findsOneWidget);
        expect(find.text(AppStrings.startMyFreeWeek), findsNothing);
      },
    );

    testWidgets('isMostPopular false hides the Most popular pill', (
      tester,
    ) async {
      final noPillRepo = MockPurchaseRepository(
        initialPlans: [
          const SubscriptionPlan(
            id: 'pebbi_monthly',
            title: 'Pebbi Monthly',
            formattedPrice: r'$3.99',
            billingPeriod: 'month',
            trialDays: 7,
            isMostPopular: false,
            trialEligible: true,
            benefits: ['Unit 1'],
          ),
        ],
      );

      await tester.pumpWidget(buildTestableScreen(purchaseRepo: noPillRepo));
      await tester.pumpAndSettle();

      expect(find.byType(BenefitChip), findsNothing);
      expect(find.text(AppStrings.mostPopularPill), findsNothing);
    });
  });

  group('Offline and Error Handling', () {
    testWidgets(
      'plan load failure displays benefits grid and Retry banner without stale price',
      (tester) async {
        final failingRepo = MockPurchaseRepository(shouldFailLoadPlans: true);

        await tester.pumpWidget(buildTestableScreen(purchaseRepo: failingRepo));
        await tester.pumpAndSettle();

        // Feature cards still display immediately
        expect(find.byType(PremiumFeatureCard), findsNWidgets(6));

        // Stale price and button are NOT rendered
        expect(find.text(r'$3.99'), findsNothing);
        expect(find.text(AppStrings.startMyFreeWeek), findsNothing);

        // Error banner with retry is shown
        expect(find.byType(PurchaseErrorBanner), findsOneWidget);
        expect(find.text(AppStrings.plansLoadError), findsOneWidget);
        expect(find.text(AppStrings.retryAction), findsOneWidget);
      },
    );

    testWidgets('renders PlanCardSkeleton while plan data is loading', (
      tester,
    ) async {
      final slowRepo = MockPurchaseRepository(
        delay: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(buildTestableScreen(purchaseRepo: slowRepo));
      await tester.pump();

      // Skeleton visible while loading
      expect(find.byType(PlanCardSkeleton), findsOneWidget);
      // Feature grid visible without waiting
      expect(find.byType(PremiumFeatureCard), findsNWidgets(6));

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.byType(PlanCardSkeleton), findsNothing);
      expect(find.byType(PlanCard), findsOneWidget);
    });
  });

  group('Already Premium State', () {
    testWidgets(
      'displays calm AlreadyPremiumCard when user profile is premium',
      (tester) async {
        final premiumProfile = dummyProfile.copyWith(plan: 'premium');

        await tester.pumpWidget(
          buildTestableScreen(userProfile: premiumProfile),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AlreadyPremiumCard), findsOneWidget);
        expect(find.text(AppStrings.alreadyPremiumTitle), findsOneWidget);
        expect(find.text(AppStrings.alreadyPremiumSubtitle), findsOneWidget);

        // Plan card and purchase button are hidden
        expect(find.byType(PlanCard), findsNothing);
        expect(find.text(AppStrings.startMyFreeWeek), findsNothing);
      },
    );
  });

  group('Purchase Flow State Machine & Navigation', () {
    testWidgets('successful purchase updates status and returns', (
      tester,
    ) async {
      final repo = MockPurchaseRepository();
      late BuildContext savedContext;

      final router = GoRouter(
        initialLocation: '/onboarding/setup/step-10',
        routes: [
          GoRoute(
            path: '/onboarding/setup/step-10',
            builder: (context, state) {
              savedContext = context;
              return const Scaffold(body: Text('Onboarding Step 10'));
            },
          ),
          GoRoute(
            path: '/premium/options',
            builder: (context, state) => const PremiumScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableScreen(purchaseRepo: repo, customRouter: router),
      );
      await tester.pumpAndSettle();

      // Navigate from step 10 to premium options
      savedContext.push('/premium/options');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.unlockAllTitle), findsOneWidget);

      // Tap purchase button
      await tester.ensureVisible(find.text(AppStrings.startMyFreeWeek));
      await tester.tap(find.text(AppStrings.startMyFreeWeek));
      await tester.pumpAndSettle();

      // Screen returned to Step 10
      expect(find.text('Onboarding Step 10'), findsOneWidget);
      expect(repo.purchaseCallCount, 1);
    });

    testWidgets(
      'purchase error displays non-blocking banner and allows retry',
      (tester) async {
        final errorRepo = MockPurchaseRepository(
          purchaseResult: PurchaseStatus.error,
        );

        await tester.pumpWidget(buildTestableScreen(purchaseRepo: errorRepo));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text(AppStrings.startMyFreeWeek));
        await tester.tap(find.text(AppStrings.startMyFreeWeek));
        await tester.pumpAndSettle();

        expect(find.byType(PurchaseErrorBanner), findsOneWidget);
        expect(find.text(AppStrings.purchaseErrorBanner), findsOneWidget);
        expect(find.text(AppStrings.retryAction), findsOneWidget);
      },
    );

    testWidgets(
      'user cancellation returns to idle silently without error banner',
      (tester) async {
        final cancelRepo = MockPurchaseRepository(
          purchaseResult: PurchaseStatus.cancelled,
        );

        await tester.pumpWidget(buildTestableScreen(purchaseRepo: cancelRepo));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text(AppStrings.startMyFreeWeek));
        await tester.tap(find.text(AppStrings.startMyFreeWeek));
        await tester.pumpAndSettle();

        expect(find.byType(PurchaseErrorBanner), findsNothing);
        expect(find.text(AppStrings.startMyFreeWeek), findsOneWidget);
      },
    );

    testWidgets('tapping close (X) button pops the screen', (tester) async {
      late BuildContext savedContext;

      final router = GoRouter(
        initialLocation: '/onboarding/setup/step-10',
        routes: [
          GoRoute(
            path: '/onboarding/setup/step-10',
            builder: (context, state) {
              savedContext = context;
              return const Scaffold(body: Text('Step 10 Target'));
            },
          ),
          GoRoute(
            path: '/premium/options',
            builder: (context, state) => const PremiumScreen(),
          ),
        ],
      );

      await tester.pumpWidget(buildTestableScreen(customRouter: router));
      await tester.pumpAndSettle();

      savedContext.push('/premium/options');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.unlockAllTitle), findsOneWidget);

      // Tap Close button
      await tester.tap(find.bySemanticsLabel(AppStrings.closeSemantics));
      await tester.pumpAndSettle();

      expect(find.text('Step 10 Target'), findsOneWidget);
    });
  });

  group('Responsive & Overflow Tests Across Required Devices', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(430, 932), // Large phone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad Pro
      Size(700, 900), // Split-screen / foldable
    ];

    for (final size in testSizes) {
      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 1.0x text scale',
        (tester) async {
          tester.view.physicalSize = Size(size.width, size.height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(buildTestableScreen(textScale: 1.0));
          await tester.pumpAndSettle();

          expect(find.text(AppStrings.unlockAllTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 2.0x text scale',
        (tester) async {
          tester.view.physicalSize = Size(size.width, size.height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(buildTestableScreen(textScale: 2.0));
          await tester.pumpAndSettle();

          expect(find.text(AppStrings.unlockAllTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'handles exceptionally long price strings and plan titles without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final longDataRepo = MockPurchaseRepository(
          initialPlans: [
            const SubscriptionPlan(
              id: 'pebbi_monthly',
              title: 'Pebbi All-Access Super Extended Global Pass Monthly',
              formattedPrice: 'US\$ 123,456.99',
              billingPeriod: 'month',
              trialDays: 7,
              isMostPopular: true,
              trialEligible: true,
              benefits: [
                'Very long descriptive benefit statement that spans multiple lines to test wrapping behavior',
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableScreen(purchaseRepo: longDataRepo, textScale: 2.0),
        );
        await tester.pumpAndSettle();

        expect(find.text('US\$ 123,456.99'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
