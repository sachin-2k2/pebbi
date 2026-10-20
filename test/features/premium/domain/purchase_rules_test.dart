import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/premium/data/mock_purchase_repository.dart';
import 'package:peddi/features/premium/domain/purchase_state.dart';
import 'package:peddi/features/premium/presentation/providers/purchase_provider.dart';

void main() {
  const dummyProfile = UserProfile(
    userId: 'guest_123',
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

  group('MockPurchaseRepository Behavior', () {
    test(
      r'defaultPlans provides monthly plan with $3.99 and 7 trial days',
      () async {
        final repo = MockPurchaseRepository();
        final plans = await repo.loadPlans();

        expect(plans.length, 1);
        final plan = plans.first;
        expect(plan.id, 'pebbi_monthly');
        expect(plan.formattedPrice, r'$3.99');
        expect(plan.billingPeriod, 'month');
        expect(plan.trialDays, 7);
        expect(plan.isMostPopular, isTrue);
        expect(plan.trialEligible, isTrue);
        expect(plan.benefits.length, 3);
      },
    );

    test('purchase updates internal status on success', () async {
      final repo = MockPurchaseRepository();
      expect(await repo.status(), isFalse);

      final result = await repo.purchase('pebbi_monthly');
      expect(result, PurchaseStatus.success);
      expect(await repo.status(), isTrue);
      expect(repo.purchaseCallCount, 1);
      expect(repo.lastPurchasedPlanId, 'pebbi_monthly');
    });

    test('handles load failure when configured', () async {
      final repo = MockPurchaseRepository(shouldFailLoadPlans: true);
      expect(() => repo.loadPlans(), throwsA(isA<Exception>()));
    });
  });

  group('PurchaseNotifier State Machine & Double-Tap Protection', () {
    test('successful purchase updates user profile plan to premium', () async {
      final repo = MockPurchaseRepository(
        delay: const Duration(milliseconds: 10),
      );
      final container = ProviderContainer(
        overrides: [purchaseRepositoryProvider.overrideWithValue(repo)],
      );
      final sub = container.listen(
        purchaseNotifierProvider,
        (previous, next) {},
      );
      addTearDown(() {
        sub.close();
        container.dispose();
      });

      // Seed current user
      await container
          .read(currentUserProvider.notifier)
          .saveProfile(dummyProfile);

      final notifier = container.read(purchaseNotifierProvider.notifier);
      expect(
        container.read(purchaseNotifierProvider).status,
        PurchaseStatus.idle,
      );

      final future = notifier.purchase('pebbi_monthly');
      expect(container.read(purchaseNotifierProvider).isLoading, isTrue);

      final result = await future;
      expect(result, PurchaseStatus.success);
      expect(container.read(purchaseNotifierProvider).isSuccess, isTrue);

      // Verify user profile updated to 'premium'
      final updatedUser = container.read(currentUserProvider);
      expect(updatedUser?.plan, 'premium');
    });

    test(
      'double-tap protection rejects concurrent purchase requests',
      () async {
        final repo = MockPurchaseRepository(
          delay: const Duration(milliseconds: 50),
        );
        final container = ProviderContainer(
          overrides: [purchaseRepositoryProvider.overrideWithValue(repo)],
        );
        final sub = container.listen(
          purchaseNotifierProvider,
          (previous, next) {},
        );
        addTearDown(() {
          sub.close();
          container.dispose();
        });

        final notifier = container.read(purchaseNotifierProvider.notifier);
        final firstAttempt = notifier.purchase('pebbi_monthly');
        expect(container.read(purchaseNotifierProvider).isLoading, isTrue);

        // Second attempt while first is loading
        final secondAttempt = await notifier.purchase('pebbi_monthly');
        expect(secondAttempt, PurchaseStatus.loading);
        expect(repo.purchaseCallCount, 1);

        await firstAttempt;
        expect(repo.purchaseCallCount, 1);
      },
    );

    test('user cancellation returns silently to idle', () async {
      final repo = MockPurchaseRepository(
        purchaseResult: PurchaseStatus.cancelled,
      );
      final container = ProviderContainer(
        overrides: [purchaseRepositoryProvider.overrideWithValue(repo)],
      );
      final sub = container.listen(
        purchaseNotifierProvider,
        (previous, next) {},
      );
      addTearDown(() {
        sub.close();
        container.dispose();
      });

      final notifier = container.read(purchaseNotifierProvider.notifier);
      final result = await notifier.purchase('pebbi_monthly');

      expect(result, PurchaseStatus.cancelled);
      expect(
        container.read(purchaseNotifierProvider).status,
        PurchaseStatus.idle,
      );
      expect(container.read(purchaseNotifierProvider).errorMessage, isNull);
    });

    test(
      'error state sets non-blocking error message and allows clearing',
      () async {
        final repo = MockPurchaseRepository(
          purchaseResult: PurchaseStatus.error,
        );
        final container = ProviderContainer(
          overrides: [purchaseRepositoryProvider.overrideWithValue(repo)],
        );
        final sub = container.listen(
          purchaseNotifierProvider,
          (previous, next) {},
        );
        addTearDown(() {
          sub.close();
          container.dispose();
        });

        final notifier = container.read(purchaseNotifierProvider.notifier);
        final result = await notifier.purchase('pebbi_monthly');

        expect(result, PurchaseStatus.error);
        final state = container.read(purchaseNotifierProvider);
        expect(state.isError, isTrue);
        expect(state.errorMessage, isNotNull);

        notifier.clearError();
        expect(container.read(purchaseNotifierProvider).isError, isFalse);
      },
    );
  });
}
