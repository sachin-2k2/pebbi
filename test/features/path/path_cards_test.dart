import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/presentation/widgets/continue_card.dart';
import 'package:peddi/features/path/presentation/widgets/due_strip.dart';
import 'package:peddi/features/path/presentation/widgets/unit_header.dart';

void main() {
  group('ContinueCard Widget', () {
    testWidgets('renders titles and triggers play callback', (tester) async {
      var playTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueCard(
              title: 'Say hello',
              subtitle: 'About 3 min · tap to start',
              onPlayPressed: () => playTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.text('Say hello'), findsOneWidget);
      expect(find.text('About 3 min · tap to start'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(playTapped, isTrue);
    });
  });

  group('DueStrip Widget', () {
    testWidgets('shows start lesson message when user has 0 phrases', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueStrip(dueCount: 0, hasPhrases: false, onReviewTap: () {}),
          ),
        ),
      );

      expect(
        find.text('Start your first lesson to build review phrases'),
        findsOneWidget,
      );
    });

    testWidgets('shows strong phrases message when none due and has phrases', (
      tester,
    ) async {
      var reviewTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueStrip(
              dueCount: 0,
              hasPhrases: true,
              onReviewTap: () => reviewTapped = true,
            ),
          ),
        ),
      );

      expect(
        find.text('Nothing due — your phrases are strong'),
        findsOneWidget,
      );

      await tester.tap(find.text('Review'));
      expect(reviewTapped, isTrue);
    });
  });

  group('UnitHeader Widget', () {
    testWidgets('renders unit details and triggers guidebook callback', (
      tester,
    ) async {
      var guideTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnitHeader(
              unitNumber: 1,
              title: 'First conversations',
              stopsDone: 1,
              totalStops: 3,
              onGuidebookTap: () => guideTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('UNIT 1 · 1 OF 3 STOPS DONE'), findsOneWidget);
      expect(find.text('First conversations'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu_book_rounded));
      expect(guideTapped, isTrue);
    });
  });
}
