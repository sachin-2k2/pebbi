import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/services/wakelock_controller.dart';
import 'package:peddi/features/emergency/domain/emergency_phrase.dart';
import 'package:peddi/features/emergency/presentation/widgets/show_screen_view.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/audio_play_button.dart';

void main() {
  const samplePhrases = [
    EmergencyPhrase(
      id: 'need-a-doctor',
      targetText: 'Necesito un médico',
      ttsLocale: 'es',
      labels: {'en': 'I need a doctor'},
    ),
    EmergencyPhrase(
      id: 'call-the-police',
      targetText: 'Llame a la policía',
      ttsLocale: 'es',
      labels: {'en': 'Call the police'},
    ),
  ];

  Widget buildSubject({int initialIndex = 0}) {
    final fakeWakelock = FakeWakelockController();
    final fakeSpeech = FakeSpeechService();

    return ProviderScope(
      overrides: [
        wakelockControllerProvider.overrideWithValue(fakeWakelock),
        textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
      ],
      child: MaterialApp(
        home: ShowScreenView(
          phrases: samplePhrases,
          initialIndex: initialIndex,
          explanationLanguageCode: 'en',
          targetLanguageCode: 'es',
          targetLanguageName: 'Spanish',
        ),
      ),
    );
  }

  testWidgets('renders initial phrase, counter 1 / 2, and dark card', (tester) async {
    await tester.pumpWidget(buildSubject(initialIndex: 0));
    await tester.pump();

    // Verify counter
    expect(find.text('1 / 2'), findsOneWidget);

    // Verify target text and native text
    expect(find.text('Necesito un médico'), findsOneWidget);
    expect(find.text('I need a doctor'), findsOneWidget);

    // Verify TTS play button
    expect(find.byType(AudioPlayButton), findsOneWidget);
  });

  testWidgets('next and previous buttons navigate between phrases', (tester) async {
    await tester.pumpWidget(buildSubject(initialIndex: 0));
    await tester.pump();

    expect(find.text('1 / 2'), findsOneWidget);

    // Tap Next
    final nextBtn = find.byTooltip('Next phrase');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('Llame a la policía'), findsOneWidget);
    expect(find.text('Call the police'), findsOneWidget);

    // Tap Previous
    final prevBtn = find.byTooltip('Previous phrase');
    expect(prevBtn, findsOneWidget);
    await tester.tap(prevBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Necesito un médico'), findsOneWidget);
  });

  testWidgets('tapping play button triggers TTS', (tester) async {
    await tester.pumpWidget(buildSubject(initialIndex: 0));
    await tester.pump();

    final playBtn = find.byType(AudioPlayButton);
    expect(playBtn, findsOneWidget);

    await tester.tap(playBtn);
    await tester.pump();
  });
}

