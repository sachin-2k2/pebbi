import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/path/data/mock_unit_guide_repository.dart';
import 'package:peddi/features/path/presentation/providers/unit_guide_provider.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/guide_note_card.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/guide_phrase_row.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/listen_unit_button.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/mini_player_bar.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/unit_guide_sheet.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/unit_guide_skeleton.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/unit_guide_unavailable.dart';
import 'package:peddi/l10n/app_strings.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';

void main() {
  late FakeSpeechService fakeTts;

  setUp(() {
    fakeTts = FakeSpeechService();
    UnitGuideSheet.clearSavedScrollOffsets();
  });

  Widget createSubject({
    required String unitId,
    Size surfaceSize = const Size(390, 844),
    AppSettings? settings,
    FocusNode? bookIconFocusNode,
  }) {
    return ProviderScope(
      overrides: [
        textToSpeechServiceProvider.overrideWithValue(fakeTts),
        if (settings != null)
          appSettingsProvider.overrideWith(
            (ref) => _FakeSettingsNotifier(settings),
          ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(size: surfaceSize, disableAnimations: true),
            child: Builder(
              builder: (context) {
                return Center(
                  child: Focus(
                    focusNode: bookIconFocusNode,
                    child: ElevatedButton(
                      onPressed: () {
                        UnitGuideSheet.show(
                          context,
                          unitId: unitId,
                          returnFocusNode: bookIconFocusNode,
                        );
                      },
                      child: const Text('Open Guide'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  group('UnitGuideSheet Widget Tests', () {
    testWidgets('renders French guidebook matching 3 design screenshots', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(unitId: 'unit_1'));
      await tester.pumpAndSettle();

      // Tap to open sheet
      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      // Verify Header elements (Screenshot 1 top)
      expect(find.byType(UnitGuideSheet), findsOneWidget);
      expect(find.text('First conversations'), findsOneWidget);
      expect(find.text('Your guidebook for this unit'), findsOneWidget);
      expect(find.byType(ListenUnitButton), findsOneWidget);
      expect(find.text('Listen to the unit'), findsOneWidget);

      // Section labels
      expect(find.text('KEY PHRASES'), findsOneWidget);

      // Verify Phrase Rows (Screenshot 1 & 2)
      expect(find.byType(GuidePhraseRow), findsWidgets);
      expect(find.text('Bonjour'), findsOneWidget);
      expect(find.text('Hello, good day'), findsOneWidget);
      expect(find.text('Bonsoir'), findsOneWidget);
      expect(find.text('Good evening'), findsOneWidget);
      expect(find.text('Salut !'), findsOneWidget);
      expect(find.text('Comment ça va ?'), findsOneWidget);

      // Scroll to bottom (Screenshot 3)
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();

      // Verify Notes section and Note Cards
      expect(find.text('NOTES'), findsOneWidget);
      expect(find.byType(GuideNoteCard), findsNWidgets(3));
      expect(find.text('tu or vous?'), findsOneWidget);
      expect(find.text('grammar'), findsNWidgets(2));
      expect(find.text('Bonjour first'), findsOneWidget);
      expect(find.text('culture'), findsOneWidget);
    });

    testWidgets('single row tap plays phrase audio once', (tester) async {
      await tester.pumpWidget(createSubject(unitId: 'unit_1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      // Tap on 'Bonjour' row
      await tester.tap(find.text('Bonjour'));
      await tester.pump();

      expect(fakeTts.isSpeaking, isTrue);
      expect(fakeTts.lastSpokenText, 'Bonjour');
      expect(fakeTts.lastLocale, 'fr-FR');
    });

    testWidgets(
      'Listen to the unit plays sequentially, highlights row and shows MiniPlayerBar',
      (tester) async {
        await tester.pumpWidget(createSubject(unitId: 'unit_1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Guide'));
        await tester.pumpAndSettle();

        // Tap 'Listen to the unit'
        await tester.tap(find.byType(ListenUnitButton));
        await tester.pump();

        // State changes to Stop on both buttons
        expect(
          find.descendant(
            of: find.byType(ListenUnitButton),
            matching: find.text('Stop'),
          ),
          findsOneWidget,
        );
        expect(fakeTts.isSpeaking, isTrue);
        expect(fakeTts.lastSpokenText, 'Bonjour');

        // Mini player bar appears with '1 of 16'
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(find.text('1 of 16'), findsOneWidget);

        // Tap Stop on mini player bar
        await tester.tap(
          find.descendant(
            of: find.byType(MiniPlayerBar),
            matching: find.text('Stop'),
          ),
        );
        await tester.pump();

        expect(find.text('Listen to the unit'), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsNothing);
      },
    );

    testWidgets('Escape key dismisses the sheet', (tester) async {
      await tester.pumpWidget(createSubject(unitId: 'unit_1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitGuideSheet), findsOneWidget);

      // Simulate Escape key press
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(UnitGuideSheet), findsNothing);
    });

    testWidgets('Focus returns to book icon after sheet closes', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createSubject(unitId: 'unit_1', bookIconFocusNode: focusNode),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();
      expect(find.byType(UnitGuideSheet), findsOneWidget);

      // Close sheet via Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(UnitGuideSheet), findsNothing);
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets(
      'scroll position survives rotation / window resizing with sheet open',
      (tester) async {
        await tester.pumpWidget(
          createSubject(unitId: 'unit_1', surfaceSize: const Size(390, 844)),
        );
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.text('Open Guide'));
        await tester.pumpAndSettle();

        final scrollableFinder = find.byType(Scrollable).last;
        final initialOffset = tester
            .state<ScrollableState>(scrollableFinder)
            .position
            .pixels;
        expect(initialOffset, 0.0);

        // Scroll down 300 dp
        await tester.drag(scrollableFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        final scrolledOffset = tester
            .state<ScrollableState>(scrollableFinder)
            .position
            .pixels;
        expect(scrolledOffset, greaterThan(250.0));

        // Rotate to landscape (844 x 390)
        await tester.binding.setSurfaceSize(const Size(844, 390));
        await tester.pumpWidget(
          createSubject(unitId: 'unit_1', surfaceSize: const Size(844, 390)),
        );
        await tester.pumpAndSettle();

        // Verify sheet is still open and scroll position is preserved
        expect(find.byType(UnitGuideSheet), findsOneWidget);
        final landscapeOffset = tester
            .state<ScrollableState>(scrollableFinder)
            .position
            .pixels;
        expect(landscapeOffset, greaterThan(250.0));

        // Restore surface size
        await tester.binding.setSurfaceSize(const Size(390, 844));
      },
    );

    testWidgets('helper line is hidden when showHelperLine is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSubject(
          unitId: 'unit_1',
          settings: const AppSettings(showHelperLine: false),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      expect(find.text('bohn-zhoor'), findsNothing);
    });

    testWidgets('helper line is shown when showHelperLine is enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSubject(
          unitId: 'unit_1',
          settings: const AppSettings(showHelperLine: true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      expect(find.text('bohn-zhoor'), findsOneWidget);
    });

    testWidgets('shows unavailable state when guide is not found', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(unitId: 'unit_unavailable'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitGuideUnavailable), findsOneWidget);
      expect(find.text(AppStrings.unitGuideUnavailableMessage), findsOneWidget);

      // Tapping Close dismisses
      await tester.tap(find.text(AppStrings.closeGuidebook));
      await tester.pumpAndSettle();
      expect(find.byType(UnitGuideUnavailable), findsNothing);
    });

    testWidgets('disposal cancels speech and no callbacks fire after close', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(unitId: 'unit_1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Guide'));
      await tester.pumpAndSettle();

      // Start playing
      await tester.tap(find.byType(ListenUnitButton));
      await tester.pump();
      expect(fakeTts.isSpeaking, isTrue);

      // Close sheet immediately while audio is in flight
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(UnitGuideSheet), findsNothing);
      expect(fakeTts.isSpeaking, isFalse);
    });
  });
}

class _FakeSettingsNotifier extends AppSettingsNotifier {
  _FakeSettingsNotifier(super.initial);
}
