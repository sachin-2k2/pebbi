import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/premium/domain/premium_feature.dart';
import 'package:peddi/features/premium/domain/premium_rules.dart';
import 'package:peddi/features/premium/domain/subscription_plan.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('SubscriptionPlan Domain Model', () {
    const planA = SubscriptionPlan(
      id: 'pebbi_monthly',
      title: 'Pebbi Monthly',
      formattedPrice: r'$3.99',
      billingPeriod: 'month',
      trialDays: 7,
      isMostPopular: true,
      trialEligible: true,
      benefits: ['Benefit 1', 'Benefit 2'],
    );

    const planB = SubscriptionPlan(
      id: 'pebbi_monthly',
      title: 'Pebbi Monthly',
      formattedPrice: r'$3.99',
      billingPeriod: 'month',
      trialDays: 7,
      isMostPopular: true,
      trialEligible: true,
      benefits: ['Benefit 1', 'Benefit 2'],
    );

    test('value equality and hashCode match for identical properties', () {
      expect(planA, equals(planB));
      expect(planA.hashCode, equals(planB.hashCode));
    });

    test('copyWith updates specified attributes', () {
      final updated = planA.copyWith(
        formattedPrice: r'$4.99',
        trialEligible: false,
      );

      expect(updated.formattedPrice, r'$4.99');
      expect(updated.trialEligible, isFalse);
      expect(updated.id, 'pebbi_monthly');
    });

    test('price and period come strictly from plan data', () {
      const euroPlan = SubscriptionPlan(
        id: 'pebbi_annual',
        title: 'Pebbi Annual',
        formattedPrice: '€39.99',
        billingPeriod: 'year',
        trialDays: 14,
        benefits: [],
      );

      expect(euroPlan.formattedPrice, '€39.99');
      expect(euroPlan.billingPeriod, 'year');
      expect(AppStrings.billingPeriodSuffix(euroPlan.billingPeriod), '/year');
    });
  });

  group('PremiumFeature Domain Model', () {
    test('defaultFeatures contains exactly 6 canonical value items', () {
      expect(PremiumFeature.defaultFeatures.length, 6);
      expect(PremiumFeature.defaultFeatures.map((f) => f.id).toList(), [
        'units',
        'languages',
        'missions',
        'no_ads',
        'offline',
        'exams',
      ]);
    });
  });

  group('PremiumRules.canShowPaywall', () {
    test('returns true across all age bands by default', () {
      expect(PremiumRules.canShowPaywall(AgeBand.child), isTrue);
      expect(PremiumRules.canShowPaywall(AgeBand.teen), isTrue);
      expect(PremiumRules.canShowPaywall(AgeBand.adult), isTrue);
      expect(PremiumRules.canShowPaywall(null), isTrue);
    });
  });

  group('Trial Eligibility and Text Formatting', () {
    test('trialDaysLine generates plural and singular sentence', () {
      expect(
        AppStrings.trialDaysLine(7),
        'First 7 days free · cancel any time, in one tap',
      );
      expect(
        AppStrings.trialDaysLine(1),
        'First 1 day free · cancel any time, in one tap',
      );
    });

    test(
      'trial eligibility changes button label from Free Week to Subscribe',
      () {
        String getButtonLabel(bool eligible) =>
            eligible ? AppStrings.startMyFreeWeek : AppStrings.subscribeAction;

        expect(getButtonLabel(true), AppStrings.startMyFreeWeek);
        expect(getButtonLabel(false), AppStrings.subscribeAction);
      },
    );
  });
}
