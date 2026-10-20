import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/benefit_chip.dart';
import 'package:peddi/core/design_system/crown_icon.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/premium_offer_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/premium/data/mock_offer_repository.dart';
import 'package:peddi/features/premium/domain/offer_repository.dart';
import 'package:peddi/features/premium/domain/subscription_offer.dart';
import 'package:peddi/features/premium/presentation/providers/offer_provider.dart';
import 'package:peddi/features/premium/presentation/screens/premium_screen.dart';
import 'package:peddi/features/premium/presentation/widgets/benefit_check_row.dart';
import 'package:peddi/features/premium/presentation/widgets/premium_offer_card.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    GoRouter? router,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    OfferRepository? offerRepository,
    void Function(WidgetRef ref)? onInit,
  }) {
    final effectiveRepo = offerRepository ?? const MockOfferRepository();
    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/onboarding/setup/step-10',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-10',
              builder: (context, state) => const PremiumOfferStepScreen(),
            ),
            GoRoute(
              path: '/premium/options',
              builder: (context, state) => const PremiumScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-11',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 11 Course Ready')),
            ),
            GoRoute(
              path: '/onboarding/setup/step-9',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 9 Meet Pebbi')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [offerRepositoryProvider.overrideWithValue(effectiveRepo)],
      child: Consumer(
        builder: (context, ref, child) {
          if (onInit != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onInit(ref));
          }
          final settings = ref.watch(appSettingsProvider);
          return MaterialApp.router(
            routerConfig: effectiveRouter,
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

  group('PremiumOfferStepScreen Layout & Visual Verification', () {
    testWidgets('renders all design elements matching specification', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Header with 10/11 progress
      expect(find.byType(StepProgressHeader), findsOneWidget);
      expect(find.text('10/11'), findsOneWidget);

      // Hero mascot with surprised expression and purple accent
      final mascotFinder = find.byType(PebbiMascot);
      expect(mascotFinder, findsOneWidget);
      final mascot = tester.widget<PebbiMascot>(mascotFinder);
      expect(mascot.expression, PebbiExpression.surprised);
      expect(mascot.accentColor, AppColors.brandPurple);

      // Centered Title and Subtitle
      expect(find.text(AppStrings.premiumOfferTitle), findsOneWidget);
      expect(find.text(AppStrings.premiumOfferSubtitle), findsOneWidget);

      // Crown pill ("One last thing")
      expect(find.text(AppStrings.oneLastThing), findsOneWidget);
      expect(find.byType(CrownIcon), findsOneWidget);
      expect(find.byType(BenefitChip), findsOneWidget);

      // Premium Card with Title and 3 Checklist Rows
      expect(find.byType(PremiumOfferCard), findsOneWidget);
      expect(find.text(AppStrings.premiumCardTitle), findsOneWidget);
      expect(find.byType(BenefitCheckRow), findsNWidgets(3));
      expect(find.text(AppStrings.premiumBenefit1), findsOneWidget);
      expect(find.text(AppStrings.premiumBenefit2), findsOneWidget);
      expect(find.text(AppStrings.premiumBenefit3), findsOneWidget);

      // Dynamic price caption from mock offer
      expect(
        find.text(
          r'7 days free, then $3.99 a month. Or watch a short ad for a free day.',
        ),
        findsOneWidget,
      );

      // Primary Mint Button3D
      expect(find.text(AppStrings.seePremiumOptions), findsOneWidget);

      // Secondary Muted Action
      expect(find.text(AppStrings.startFreeAction), findsOneWidget);
    });

    testWidgets('dynamic caption adapts to custom offer repository data', (
      tester,
    ) async {
      const customOffer = SubscriptionOffer(
        trialDays: 14,
        formattedPrice: '£4.99',
        period: 'month',
        canWatchAdForFreeDay: false,
      );
      const customRepo = MockOfferRepository(offer: customOffer);

      await tester.pumpWidget(buildTestableScreen(offerRepository: customRepo));
      await tester.pumpAndSettle();

      expect(find.text('14 days free, then £4.99 a month.'), findsOneWidget);
      expect(find.textContaining('watch a short ad'), findsNothing);
    });

    testWidgets(
      'shows skeleton while offer is loading without blocking screen',
      (tester) async {
        const delayedRepo = MockOfferRepository(
          delay: Duration(milliseconds: 500),
        );

        await tester.pumpWidget(
          buildTestableScreen(offerRepository: delayedRepo),
        );
        await tester.pump(); // Frame 0: loading

        // Screen, title, card and primary buttons are visible immediately
        expect(find.text(AppStrings.premiumOfferTitle), findsOneWidget);
        expect(find.text(AppStrings.premiumCardTitle), findsOneWidget);
        expect(find.text(AppStrings.seePremiumOptions), findsOneWidget);
        expect(find.text(AppStrings.startFreeAction), findsOneWidget);

        // Offer caption text is not yet present; skeleton is visible
        expect(find.textContaining('7 days free'), findsNothing);

        // Settle loading delay
        await tester.pump(const Duration(milliseconds: 550));
        await tester.pumpAndSettle();
        expect(find.textContaining('7 days free'), findsOneWidget);
      },
    );

    testWidgets(
      'handles offer error by omitting caption and keeping buttons active',
      (tester) async {
        const failingRepo = MockOfferRepository(shouldFail: true);

        await tester.pumpWidget(
          buildTestableScreen(offerRepository: failingRepo),
        );
        await tester.pumpAndSettle();

        // Pricing caption is omitted gracefully
        expect(find.textContaining('days free'), findsNothing);
        expect(find.textContaining(r'$3.99'), findsNothing);

        // Benefits and buttons remain functional
        expect(find.text(AppStrings.premiumBenefit1), findsOneWidget);
        expect(find.text(AppStrings.seePremiumOptions), findsOneWidget);
        expect(find.text(AppStrings.startFreeAction), findsOneWidget);
      },
    );
  });

  group('PremiumOfferStepScreen Navigation and State Interactions', () {
    testWidgets(
      'tapping "See premium options" opens options placeholder and can return',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.seePremiumOptions));
        await tester.pumpAndSettle();

        // Navigated to PremiumScreen ("Unlock all of Pebbi")
        expect(find.text(AppStrings.unlockAllTitle), findsOneWidget);

        // Tapping close (X) button goes back to Step 10
        await tester.tap(find.bySemanticsLabel(AppStrings.closeSemantics));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.premiumOfferTitle), findsOneWidget);
      },
    );

    testWidgets(
      'tapping "Start free" saves free plan and advances to Step 11',
      (tester) async {
        late WidgetRef capturedRef;
        await tester.pumpWidget(
          buildTestableScreen(onInit: (ref) => capturedRef = ref),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.startFreeAction));
        await tester.pumpAndSettle();

        // State updated
        expect(capturedRef.read(onboardingFlowProvider).selectedPlan, 'free');
        expect(capturedRef.read(onboardingFlowProvider).currentStep, 11);

        // Navigated to Step 11 placeholder
        expect(find.text('Step 11 Course Ready'), findsOneWidget);
      },
    );

    testWidgets('back button navigates to Step 9 preserving prior state', (
      tester,
    ) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        buildTestableScreen(
          onInit: (ref) {
            capturedRef = ref;
            ref.read(onboardingFlowProvider.notifier).setStep(10);
            ref.read(onboardingFlowProvider.notifier).setAccent('orange');
          },
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byTooltip(AppStrings.backSemantics);
      final backFinder = backButton.evaluate().isNotEmpty
          ? backButton
          : find.byIcon(Icons.chevron_left);
      await tester.tap(backFinder);
      await tester.pumpAndSettle();

      expect(capturedRef.read(onboardingFlowProvider).accentId, 'orange');
      expect(find.text('Step 9 Meet Pebbi'), findsOneWidget);
    });
  });

  group('Contrast and Accessibility Checks', () {
    test('verifies WCAG AA and AAA color contrast on gradient and surfaces', () {
      // Relative luminance calculation
      double luminance(Color c) => c.computeLuminance();
      double contrast(Color c1, Color c2) {
        final l1 = luminance(c1);
        final l2 = luminance(c2);
        return (l1 > l2)
            ? (l1 + 0.05) / (l2 + 0.05)
            : (l2 + 0.05) / (l1 + 0.05);
      }

      // White on gradient start (#6C4DF6): passes WCAG AA (> 4.5:1)
      final contrastStart = contrast(
        Colors.white,
        AppColors.premiumGradientStart,
      );
      expect(contrastStart, greaterThan(4.5));

      // White on gradient end (#4B33C4): passes WCAG AAA (> 7.0:1)
      final contrastEnd = contrast(Colors.white, AppColors.premiumGradientEnd);
      expect(contrastEnd, greaterThan(7.0));

      // Muted text (#6E6A8A) on background (#F5F4FB): passes WCAG AA (> 4.5:1)
      final contrastMuted = contrast(AppColors.textMuted, AppColors.background);
      expect(contrastMuted, greaterThan(4.5));
    });
  });

  group('Responsive and Overflow Tests Across All Window Sizes', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad Pro portrait
    ];

    for (final size in testSizes) {
      testWidgets(
        'renders cleanly without overflow at ${size.width}x${size.height} (1.0x and 2.0x)',
        (tester) async {
          for (final scale in [1.0, 2.0]) {
            tester.view.physicalSize = Size(
              size.width * 2.0,
              size.height * 2.0,
            );
            tester.view.devicePixelRatio = 2.0;
            addTearDown(() => tester.view.resetPhysicalSize());

            await tester.pumpWidget(buildTestableScreen(textScale: scale));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            // Pinned bottom buttons must remain fully visible and on screen
            expect(find.text(AppStrings.seePremiumOptions), findsOneWidget);
            expect(find.text(AppStrings.startFreeAction), findsOneWidget);
          }
        },
      );
    }
  });
}
