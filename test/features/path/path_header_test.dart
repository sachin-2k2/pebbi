import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/presentation/widgets/top_pills.dart';
import 'package:peddi/features/path/presentation/widgets/track_chips.dart';

void main() {
  group('TopPills Widget', () {
    testWidgets('renders language, streak, and stars with tap events', (
      tester,
    ) async {
      var languageTapped = false;
      var streakTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopPills(
              language: 'Español',
              streakCount: 3,
              starsCount: 42,
              onLanguageTap: () => languageTapped = true,
              onStreakTap: () => streakTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Español'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);

      await tester.tap(find.text('Español'));
      expect(languageTapped, isTrue);

      await tester.tap(find.text('3'));
      expect(streakTapped, isTrue);
    });
  });

  group('TrackChips Widget', () {
    testWidgets('switches track selection when tapped', (tester) async {
      String selectedTrack = 'everyday';

      const tracks = [
        TrackChipData(
          id: 'everyday',
          label: 'Everyday talk',
          icon: Icons.chat_bubble_outline_rounded,
        ),
        TrackChipData(
          id: 'travel',
          label: 'Travel',
          icon: Icons.flight_takeoff_rounded,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TrackChips(
                  tracks: tracks,
                  selectedTrackId: selectedTrack,
                  onTrackSelected: (id) => setState(() => selectedTrack = id),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Everyday talk'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);

      await tester.tap(find.text('Travel'));
      await tester.pumpAndSettle();

      expect(selectedTrack, equals('travel'));
    });
  });
}
