import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/settings/domain/hand_preference.dart';
import 'package:peddi/features/settings/domain/motion_safety_rules.dart';
import 'package:peddi/features/settings/domain/name_safety_rules.dart';
import 'package:peddi/features/settings/domain/text_size_rules.dart';

void main() {
  group('NameSafetyRules', () {
    test('sanitizes whitespace and trims', () {
      expect(NameSafetyRules.sanitize('   Alex   '), equals('Alex'));
      expect(NameSafetyRules.sanitize('   '), equals(''));
    });

    test('clamps length to 30 characters maximum', () {
      const longName =
          'A very long name that exceeds the thirty character limit';
      final sanitized = NameSafetyRules.sanitize(longName);
      expect(sanitized.length, equals(30));
    });

    test('strips emoji characters for privacy and safety', () {
      expect(NameSafetyRules.sanitize('Alex 🎉🚀'), equals('Alex'));
    });

    test('shouldAskForName returns valid boolean', () {
      expect(NameSafetyRules.shouldAskForName(AgeBand.child), isTrue);
      expect(NameSafetyRules.shouldAskForName(AgeBand.teen), isTrue);
      expect(NameSafetyRules.shouldAskForName(AgeBand.adult), isTrue);
    });
  });

  group('TextSizeRules', () {
    test('snaps scale to nearest 5% increment within 0.85 and 1.30', () {
      expect(TextSizeRules.snapScale(0.84), equals(0.85));
      expect(TextSizeRules.snapScale(0.85), equals(0.85));
      expect(TextSizeRules.snapScale(0.98), equals(1.0));
      expect(TextSizeRules.snapScale(1.12), equals(1.10));
      expect(TextSizeRules.snapScale(1.14), equals(1.15));
      expect(TextSizeRules.snapScale(1.35), equals(1.30));
    });

    test('formats percentage label correctly', () {
      expect(TextSizeRules.formatPercent(0.85), equals('85%'));
      expect(TextSizeRules.formatPercent(1.0), equals('100%'));
      expect(TextSizeRules.formatPercent(1.30), equals('130%'));
    });

    test('clamps combined system and in-app scale to 2.0x maximum', () {
      // 1.0 system * 1.0 in-app = 1.0
      expect(
        TextSizeRules.clampCombinedScale(systemScale: 1.0, inAppScale: 1.0),
        equals(1.0),
      );
      // 1.5 system * 1.2 in-app = 1.8 <= 2.0
      expect(
        TextSizeRules.clampCombinedScale(systemScale: 1.5, inAppScale: 1.2),
        closeTo(1.8, 0.001),
      );
      // 2.0 system * 1.3 in-app = 2.6 -> clamped to 2.0
      expect(
        TextSizeRules.clampCombinedScale(systemScale: 2.0, inAppScale: 1.3),
        equals(2.0),
      );
      // 3.0 system * 1.0 in-app -> clamped to 2.0
      expect(
        TextSizeRules.clampCombinedScale(systemScale: 3.0, inAppScale: 1.0),
        equals(2.0),
      );
    });
  });

  group('MotionSafetyRules', () {
    test(
      'shouldReduceMotion returns true if either app or system requests it',
      () {
        expect(
          MotionSafetyRules.shouldReduceMotion(
            appSetting: false,
            systemSetting: false,
          ),
          isFalse,
        );
        expect(
          MotionSafetyRules.shouldReduceMotion(
            appSetting: true,
            systemSetting: false,
          ),
          isTrue,
        );
        expect(
          MotionSafetyRules.shouldReduceMotion(
            appSetting: false,
            systemSetting: true,
          ),
          isTrue,
        );
        expect(
          MotionSafetyRules.shouldReduceMotion(
            appSetting: true,
            systemSetting: true,
          ),
          isTrue,
        );
      },
    );
  });

  group('HandPreference', () {
    test('enum properties and boolean helpers', () {
      expect(HandPreference.rightHanded.isLeftHanded, isFalse);
      expect(HandPreference.leftHanded.isLeftHanded, isTrue);
    });
  });
}
