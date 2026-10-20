import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/services/wakelock_controller.dart';
import 'package:peddi/features/emergency/domain/emergency_phrase.dart';
import 'package:peddi/features/emergency/presentation/widgets/show_screen_close_button.dart';
import 'package:peddi/features/emergency/presentation/widgets/show_screen_view.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/audio_play_button.dart';

void main() {
  const testPhrase = EmergencyPhrase(
    id: 'help',
    targetText: '¡Ayuda!',
    ttsLocale: 'es-ES',
    labels: {'en': 'Help!', 'es': '¡Ayuda!'},
  );

  testWidgets('Wakelock enables on mount and disables on unmount', (
    tester,
  ) async {
    final fakeWakelock = FakeWakelockController();
    final fakeSpeech = FakeSpeechService();

    expect(fakeWakelock.isEnabled, isFalse);
    expect(fakeWakelock.enableCount, equals(0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wakelockControllerProvider.overrideWithValue(fakeWakelock),
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ShowScreenView(
              phrase: testPhrase,
              explanationLanguageCode: 'en',
              targetLanguageCode: 'es',
            ),
          ),
        ),
      ),
    );

    // Wakelock enabled on mount
    expect(fakeWakelock.isEnabled, isTrue);
    expect(fakeWakelock.enableCount, equals(1));

    // Pop the widget by navigating away
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wakelockControllerProvider.overrideWithValue(fakeWakelock),
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
        ],
        child: const MaterialApp(home: Scaffold(body: Text('Gone'))),
      ),
    );

    // Wakelock disabled on unmount
    expect(fakeWakelock.isEnabled, isFalse);
    expect(fakeWakelock.disableCount, equals(1));
  });

  testWidgets('ShowScreenView plays audio and handles close button', (
    tester,
  ) async {
    final fakeWakelock = FakeWakelockController();
    final fakeSpeech = FakeSpeechService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wakelockControllerProvider.overrideWithValue(fakeWakelock),
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ShowScreenView(
                        phrase: testPhrase,
                        explanationLanguageCode: 'en',
                        targetLanguageCode: 'es',
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    // Open view
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ShowScreenView), findsOneWidget);
    expect(find.text('Help!'), findsOneWidget);
    expect(find.text('¡Ayuda!'), findsOneWidget);
    expect(fakeWakelock.isEnabled, isTrue);

    // Tap audio play button
    final playBtn = find.byType(AudioPlayButton);
    expect(playBtn, findsOneWidget);
    await tester.tap(playBtn);
    await tester.pumpAndSettle();

    expect(fakeSpeech.lastSpokenText, equals('¡Ayuda!'));
    expect(fakeSpeech.lastLocale, equals('es'));

    // Tap close button
    final closeBtn = find.byType(ShowScreenCloseButton);
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ShowScreenView), findsNothing);
    expect(fakeWakelock.isEnabled, isFalse);
  });
}
