import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/accent_option.dart';
import 'package:peddi/features/onboarding/domain/meet_pebbi_rules.dart';
import 'package:peddi/features/onboarding/domain/sticker_option.dart';

void main() {
  group('AccentOption Domain Tests', () {
    test('contains 6 defined accent options with violet as default', () {
      expect(AccentOption.options.length, 6);
      expect(AccentOption.defaultAccentId, 'violet');
      expect(AccentOption.options.first.id, 'violet');
    });

    test('findById returns matching option or falls back to violet', () {
      expect(AccentOption.findById('green').id, 'green');
      expect(AccentOption.findById('orange').id, 'orange');
      expect(AccentOption.findById('blue').id, 'blue');
      expect(AccentOption.findById('pink').id, 'pink');
      expect(AccentOption.findById('slate').id, 'slate');
      expect(AccentOption.findById('unknown_id').id, 'violet');
    });

    test('all 6 options have unique non-zero ARGB color values', () {
      final ids = <String>{};
      final colors = <int>{};
      for (final opt in AccentOption.options) {
        expect(ids.add(opt.id), isTrue, reason: 'Duplicate ID: ${opt.id}');
        expect(colors.add(opt.colorValue), isTrue, reason: 'Duplicate Color');
        expect(opt.colorValue & 0xFF000000, 0xFF000000);
      }
    });
  });

  group('StickerOption Domain Tests', () {
    test(
      'contains 3 starter stickers with stable IDs: wave, sparkle, wellsaid',
      () {
        expect(StickerOption.options.length, 3);
        expect(StickerOption.options[0].id, 'wave');
        expect(StickerOption.options[0].emoji, '👋');
        expect(StickerOption.options[1].id, 'sparkle');
        expect(StickerOption.options[1].emoji, '✨');
        expect(StickerOption.options[2].id, 'wellsaid');
        expect(StickerOption.options[2].emoji, '👍');
      },
    );

    test('findById returns matching sticker or null for invalid/null id', () {
      expect(StickerOption.findById('wave')?.title, 'First hello');
      expect(StickerOption.findById('sparkle')?.title, 'Little spark');
      expect(StickerOption.findById('wellsaid')?.title, 'Well said');
      expect(StickerOption.findById('invalid'), isNull);
      expect(StickerOption.findById(null), isNull);
    });
  });

  group('MeetPebbiRules Domain Tests', () {
    test('default accent is valid and canContinue is true without sticker', () {
      expect(
        MeetPebbiRules.isValidAccent(MeetPebbiRules.defaultAccentId),
        isTrue,
      );
      expect(
        MeetPebbiRules.canContinue(
          accentId: MeetPebbiRules.defaultAccentId,
          stickerId: null,
        ),
        isTrue,
      );
    });

    test(
      'toggleSticker selects when different and deselects when tapped again',
      () {
        // Initially no sticker selected, tap 'wave'
        final selected = MeetPebbiRules.toggleSticker(
          currentSelectedId: null,
          tappedId: 'wave',
        );
        expect(selected, 'wave');

        // Tap 'wave' again -> deselects to null
        final deselected = MeetPebbiRules.toggleSticker(
          currentSelectedId: 'wave',
          tappedId: 'wave',
        );
        expect(deselected, isNull);

        // Switching from 'wave' to 'sparkle'
        final switched = MeetPebbiRules.toggleSticker(
          currentSelectedId: 'wave',
          tappedId: 'sparkle',
        );
        expect(switched, 'sparkle');
      },
    );
  });
}
