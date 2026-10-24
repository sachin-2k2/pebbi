import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_palette.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/domain/accent_option.dart';
import 'package:peddi/features/settings/presentation/widgets/appearance_section.dart';
import 'package:peddi/features/settings/presentation/widgets/text_size_slider.dart';

void main() {
  group('AppearanceSection & TextSizeSlider accent color tests', () {
    testWidgets(
      'TextSizeSlider updates its active bar and thumb color when accent color changes',
      (tester) async {
        String currentAccent = 'violet';
        double currentScale = 1.0;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                theme: AppTheme.light(
                  Color(AccentOption.findById(currentAccent).colorValue),
                ),
                home: Scaffold(
                  body: AppearanceSection(
                    selectedThemeMode: 'light',
                    onThemeModeChanged: (_) {},
                    selectedAccentId: currentAccent,
                    onAccentChanged: (newAccent) {
                      setState(() {
                        currentAccent = newAccent;
                      });
                    },
                    textScale: currentScale,
                    onTextScaleChanged: (newScale) {
                      setState(() {
                        currentScale = newScale;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initially violet
        Slider slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.activeColor, equals(const Color(0xFF6C4DF6)));

        SliderTheme sliderTheme = tester.widget<SliderTheme>(
          find.byType(SliderTheme),
        );
        expect(
          sliderTheme.data.activeTrackColor,
          equals(const Color(0xFF6C4DF6)),
        );
        expect(sliderTheme.data.thumbColor, equals(const Color(0xFF6C4DF6)));

        // 2. Tap Green swatch
        await tester.tap(find.bySemanticsLabel(RegExp('Green, option 2 of 6')));
        await tester.pumpAndSettle();

        slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.activeColor, equals(const Color(0xFF2DD4A4)));

        sliderTheme = tester.widget<SliderTheme>(find.byType(SliderTheme));
        expect(
          sliderTheme.data.activeTrackColor,
          equals(const Color(0xFF2DD4A4)),
        );
        expect(sliderTheme.data.thumbColor, equals(const Color(0xFF2DD4A4)));

        // 3. Tap Orange swatch
        await tester.tap(find.bySemanticsLabel(RegExp('Orange, option 3 of 6')));
        await tester.pumpAndSettle();

        slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.activeColor, equals(const Color(0xFFFF7A00)));

        sliderTheme = tester.widget<SliderTheme>(find.byType(SliderTheme));
        expect(
          sliderTheme.data.activeTrackColor,
          equals(const Color(0xFFFF7A00)),
        );
        expect(sliderTheme.data.thumbColor, equals(const Color(0xFFFF7A00)));

        // 4. Tap Blue swatch
        await tester.tap(find.bySemanticsLabel(RegExp('Blue, option 4 of 6')));
        await tester.pumpAndSettle();

        slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.activeColor, equals(const Color(0xFF0EA5E9)));

        sliderTheme = tester.widget<SliderTheme>(find.byType(SliderTheme));
        expect(
          sliderTheme.data.activeTrackColor,
          equals(const Color(0xFF0EA5E9)),
        );
        expect(sliderTheme.data.thumbColor, equals(const Color(0xFF0EA5E9)));
      },
    );
  });
}
