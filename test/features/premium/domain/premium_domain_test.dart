import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/premium/data/mock_offer_repository.dart';
import 'package:peddi/features/premium/domain/premium_rules.dart';
import 'package:peddi/features/premium/domain/subscription_offer.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('PremiumRules.shouldShowOffer', () {
    test('returns true for default user without existing entitlement', () {
      final shouldShow = PremiumRules.shouldShowOffer();
      expect(shouldShow, isTrue);
    });

    test('returns false if user already has active premium entitlement', () {
      final shouldShow = PremiumRules.shouldShowOffer(isAlreadyPremium: true);
      expect(shouldShow, isFalse);
    });

    test('handles child age bands without error', () {
      expect(PremiumRules.shouldShowOffer(ageBand: AgeBand.child), isTrue);
      expect(
        PremiumRules.shouldShowOffer(
          ageBand: AgeBand.child,
          isAlreadyPremium: true,
        ),
        isFalse,
      );
      expect(PremiumRules.shouldShowOffer(ageBand: AgeBand.teen), isTrue);
    });
  });

  group('AppStrings.premiumOfferCaption', () {
    test('formats plural-safe trial days for 7 days', () {
      final caption = AppStrings.premiumOfferCaption(
        trialDays: 7,
        formattedPrice: r'$3.99',
        period: 'month',
        canWatchAdForFreeDay: true,
      );
      expect(
        caption,
        r'7 days free, then $3.99 a month. Or watch a short ad for a free day.',
      );
    });

    test('formats singular trial day for 1 day', () {
      final caption = AppStrings.premiumOfferCaption(
        trialDays: 1,
        formattedPrice: r'$3.99',
        period: 'month',
        canWatchAdForFreeDay: true,
      );
      expect(
        caption,
        r'1 day free, then $3.99 a month. Or watch a short ad for a free day.',
      );
    });

    test('omits ad watch sentence when canWatchAdForFreeDay is false', () {
      final caption = AppStrings.premiumOfferCaption(
        trialDays: 14,
        formattedPrice: r'$3.99',
        period: 'month',
        canWatchAdForFreeDay: false,
      );
      expect(caption, r'14 days free, then $3.99 a month.');
    });

    test('formats diverse currencies and billing periods correctly', () {
      final gbp = AppStrings.premiumOfferCaption(
        trialDays: 7,
        formattedPrice: '£3.49',
        period: 'month',
      );
      expect(gbp, '7 days free, then £3.49 a month.');

      final eurAnnual = AppStrings.premiumOfferCaption(
        trialDays: 30,
        formattedPrice: '€39.99',
        period: 'year',
        canWatchAdForFreeDay: true,
      );
      expect(
        eurAnnual,
        '30 days free, then €39.99 a year. Or watch a short ad for a free day.',
      );
    });
  });

  group('SubscriptionOffer and MockOfferRepository', () {
    test('MockOfferRepository returns realistic introductory offer', () async {
      const repository = MockOfferRepository();
      final offer = await repository.getIntroductoryOffer();

      expect(offer.trialDays, 7);
      expect(offer.formattedPrice, r'$3.99');
      expect(offer.period, 'month');
      expect(offer.canWatchAdForFreeDay, isTrue);
    });

    test(
      'MockOfferRepository throws StateError when shouldFail is true',
      () async {
        const repository = MockOfferRepository(shouldFail: true);
        expect(() => repository.getIntroductoryOffer(), throwsStateError);
      },
    );

    test('SubscriptionOffer equality and hashCode work correctly', () {
      const offer1 = SubscriptionOffer(
        trialDays: 7,
        formattedPrice: r'$3.99',
        period: 'month',
        canWatchAdForFreeDay: true,
      );
      const offer2 = SubscriptionOffer(
        trialDays: 7,
        formattedPrice: r'$3.99',
        period: 'month',
        canWatchAdForFreeDay: true,
      );
      const offer3 = SubscriptionOffer(
        trialDays: 14,
        formattedPrice: r'$4.99',
        period: 'year',
        canWatchAdForFreeDay: false,
      );

      expect(offer1, equals(offer2));
      expect(offer1.hashCode, equals(offer2.hashCode));
      expect(offer1, isNot(equals(offer3)));
    });
  });
}
