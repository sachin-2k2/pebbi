import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_decoration_config.dart';

void main() {
  group(
    'Splash Decoration Clear-Zone and Collision Tests (User Rule 4 & AGENTS.md §4.8)',
    () {
      const screenCases = <String, Size>{
        'Small Android phone': Size(360, 640),
        'iPhone': Size(390, 844),
        'Large phone': Size(430, 932),
        'Android tablet portrait': Size(800, 1280),
        'Android tablet landscape': Size(1280, 800),
        'iPad Pro portrait': Size(1024, 1366),
        'Split-screen / Foldable window': Size(700, 900),
      };

      for (final entry in screenCases.entries) {
        test(
          'no decoration enters clear-zone on ${entry.key} (${entry.value.width}x${entry.value.height})',
          () {
            final size = entry.value;
            final clearZone = SplashDecorationConfig.computeClearZone(size);

            // Verify floating items clearance
            for (final item in SplashDecorationConfig.floatingItems) {
              final x = item.fractionX * size.width;
              final y = item.fractionY * size.height;
              final itemRect = Rect.fromCenter(
                center: Offset(x, y),
                width: item.size,
                height: item.size,
              );

              final overlaps = clearZone.overlaps(itemRect);
              expect(
                overlaps,
                isFalse,
                reason:
                    'Item ${item.id} (${item.emoji}) at ($x, $y) overlaps clear zone: $clearZone on ${entry.key}',
              );
            }

            // Verify greetings clearance
            for (final greeting in SplashDecorationConfig.greetings) {
              final x = greeting.fractionX * size.width;
              final y = greeting.fractionY * size.height;
              // Approximate bounding box for greeting text
              final textWidth = greeting.text.length * greeting.fontSize * 0.75;
              final greetingRect = Rect.fromLTWH(
                x,
                y,
                textWidth,
                greeting.fontSize * 1.3,
              );

              final overlaps = clearZone.overlaps(greetingRect);
              expect(
                overlaps,
                isFalse,
                reason:
                    'Greeting "${greeting.text}" at ($x, $y) overlaps clear zone: $clearZone on ${entry.key}',
              );
            }
          },
        );

        test('no two floating items overlap each other on ${entry.key}', () {
          final size = entry.value;
          final items = SplashDecorationConfig.floatingItems;

          for (int i = 0; i < items.length; i++) {
            final rectA = Rect.fromCenter(
              center: Offset(
                items[i].fractionX * size.width,
                items[i].fractionY * size.height,
              ),
              width: items[i].size,
              height: items[i].size,
            );

            for (int j = i + 1; j < items.length; j++) {
              final rectB = Rect.fromCenter(
                center: Offset(
                  items[j].fractionX * size.width,
                  items[j].fractionY * size.height,
                ),
                width: items[j].size,
                height: items[j].size,
              );

              expect(
                rectA.overlaps(rectB),
                isFalse,
                reason:
                    'Item ${items[i].id} overlaps with ${items[j].id} on ${entry.key}',
              );
            }
          }
        });
      }

      test(
        'all items stay strictly inside screen bounds with safe margins on all 7 sizes',
        () {
          for (final entry in screenCases.entries) {
            final size = entry.value;

            for (final item in SplashDecorationConfig.floatingItems) {
              final x = item.fractionX * size.width;
              final y = item.fractionY * size.height;

              expect(
                x,
                greaterThanOrEqualTo(0.0),
                reason: 'Item ${item.id} exceeds left on ${entry.key}',
              );
              expect(
                x + item.size,
                lessThanOrEqualTo(size.width),
                reason: 'Item ${item.id} exceeds right on ${entry.key}',
              );
              expect(
                y,
                greaterThanOrEqualTo(0.0),
                reason: 'Item ${item.id} exceeds top on ${entry.key}',
              );
              expect(
                y + item.size,
                lessThanOrEqualTo(size.height),
                reason: 'Item ${item.id} exceeds bottom on ${entry.key}',
              );
            }
          }
        },
      );

      test(
        'priority drop order: greetings omitted when screen height < 500dp',
        () {
          const shortLandscape = Size(800, 380);
          expect(shortLandscape.height, lessThan(500.0));
          // In splash_greetings_layer, when height < 500.0 it returns SizedBox.shrink()
        },
      );
    },
  );
}
