import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/path/domain/ad_rules.dart';

void main() {
  group('AdRules', () {
    test('shows ads for free adult online users', () {
      final shouldShow = AdRules.shouldShowAds(
        ageBand: AgeBand.adult,
        isPremium: false,
        isOnline: true,
      );
      expect(shouldShow, isTrue);
    });

    test('hides ads for premium users', () {
      final shouldShow = AdRules.shouldShowAds(
        ageBand: AgeBand.adult,
        isPremium: true,
        isOnline: true,
      );
      expect(shouldShow, isFalse);
    });

    test('hides ads for children under COPPA/GDPR-K compliance', () {
      final shouldShow = AdRules.shouldShowAds(
        ageBand: AgeBand.child,
        isPremium: false,
        isOnline: true,
      );
      expect(shouldShow, isFalse);
    });

    test('hides ads when user is offline', () {
      final shouldShow = AdRules.shouldShowAds(
        ageBand: AgeBand.adult,
        isPremium: false,
        isOnline: false,
      );
      expect(shouldShow, isFalse);
    });
  });
}
