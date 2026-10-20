import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/missions/domain/mission_category.dart';
import 'package:peddi/features/missions/domain/mission_summary.dart';
import 'package:peddi/features/missions/domain/today_mission.dart';
import 'package:peddi/features/missions/presentation/providers/missions_provider.dart';
import 'package:peddi/features/missions/presentation/screens/missions_screen.dart';

void main() {
  const viewports = <String, Size>{
    '360x640 (Small Android phone)': Size(360, 640),
    '390x844 (iPhone)': Size(390, 844),
    '430x932 (Large phone)': Size(430, 932),
    '800x1280 (Android tablet portrait)': Size(800, 1280),
    '1280x800 (Android tablet landscape)': Size(1280, 800),
    '1024x1366 (iPad Pro portrait)': Size(1024, 1366),
    '700x900 (Split-screen window)': Size(700, 900),
  };

  final longDataState = MissionsState(
    categories: const [
      MissionCategory(id: 'all', title: 'All situations'),
      MissionCategory(
        id: 'everyday',
        title: 'Everyday conversations & small talk',
      ),
      MissionCategory(id: 'travel', title: 'International travel & navigation'),
    ],
    missions: const [
      MissionSummary(
        id: 'long_1',
        categoryIds: ['everyday'],
        title:
            'Order an iced double caramel macchiato with extra oat milk and two brown sugar packets',
        characterName: 'María de los Ángeles del Carmen Rodríguez-Pérez',
        characterRole: 'Senior Master Barista and Café Shift Supervisor',
        durationMinutes: 12,
        difficulty: 3,
        emoji: '☕',
      ),
      MissionSummary(
        id: 'long_2',
        categoryIds: ['travel'],
        title:
            'Inquire about delayed connecting flights at the international terminal transfer desk',
        characterName: 'Abdelkader Mohammed Al-Mansoor',
        characterRole: 'Aviation Customer Service Coordinator',
        durationMinutes: 15,
        difficulty: 3,
        emoji: '🧭',
        isPremium: true,
      ),
    ],
    todayMission: const TodayMission(
      mission: MissionSummary(
        id: 'long_today',
        categoryIds: ['everyday'],
        title: 'Navigate a complicated subway transfer during peak rush hour',
        characterName: 'Alexandre-Guillaume de la Tour-du-Pin',
        characterRole: 'Metropolitan Transit Customer Assistant',
        durationMinutes: 10,
        difficulty: 2,
        emoji: '🚇',
      ),
    ),
  );

  Widget buildResponsiveTestSubject({
    required Size size,
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return ProviderScope(
      overrides: [missionsStateProvider.overrideWith((ref) => longDataState)],
      child: MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.brandPurple,
            brightness: brightness,
          ),
          useMaterial3: true,
        ),
        home: Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
              platformBrightness: brightness,
            ),
            child: const MissionsScreen(),
          ),
        ),
      ),
    );
  }

  group('MissionsScreen Responsive & Overflow Tests', () {
    for (final entry in viewports.entries) {
      testWidgets('no overflow at ${entry.key} @ 1.0x text scale', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildResponsiveTestSubject(size: entry.value, textScale: 1.0),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('no overflow at ${entry.key} @ 2.0x text scale', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildResponsiveTestSubject(size: entry.value, textScale: 2.0),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('no overflow in dark mode at 390x844', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildResponsiveTestSubject(
          size: const Size(390, 844),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow in RTL (Arabic) layout at 390x844', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildResponsiveTestSubject(
          size: const Size(390, 844),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
