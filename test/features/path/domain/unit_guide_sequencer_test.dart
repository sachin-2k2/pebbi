import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/domain/guide_phrase.dart';
import 'package:peddi/features/path/domain/unit.dart';
import 'package:peddi/features/path/domain/unit_guide_rules.dart';
import 'package:peddi/features/path/domain/unit_guide_sequencer.dart';

void main() {
  group('UnitGuideSequencer', () {
    const p1 = GuidePhrase(
      id: 'p1',
      targetText: 'Bonjour',
      meaning: 'Hello',
      audioLocale: 'fr-FR',
    );
    const p2 = GuidePhrase(
      id: 'p2',
      targetText: 'Comment allez-vous ?',
      meaning: 'How are you?',
      audioLocale: 'fr-FR',
    );
    const p3 = GuidePhrase(
      id: 'p3',
      targetText: 'Merci beaucoup',
      meaning: 'Thank you very much',
      audioLocale: 'fr-FR',
    );

    test('normal sequential completion with 800ms gap', () {
      fakeAsync((async) {
        final stateHistory = <SequencerSnapshot>[];
        final spokenPhrases = <GuidePhrase>[];
        final completions = <void Function()>[];
        int stopCalls = 0;

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2, p3],
          gap: const Duration(milliseconds: 800),
          timeout: const Duration(seconds: 8),
          speakDelegate: (phrase, onComplete) async {
            spokenPhrases.add(phrase);
            completions.add(onComplete);
            return true;
          },
          stopSpeechDelegate: () async {
            stopCalls++;
          },
          onStateChanged: (state) => stateHistory.add(state),
        );

        sequencer.start();
        async.flushMicrotasks();

        expect(sequencer.state.isPlaying, isTrue);
        expect(sequencer.state.currentIndex, 0);
        expect(spokenPhrases, [p1]);

        // Complete phrase 1
        completions[0]();
        async.flushMicrotasks();

        // During gap: still phrase 1 until 800ms elapses
        async.elapse(const Duration(milliseconds: 400));
        expect(sequencer.state.currentIndex, 0);

        // Elapse remaining 400ms gap (total 800ms)
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();

        expect(sequencer.state.currentIndex, 1);
        expect(spokenPhrases, [p1, p2]);

        // Complete phrase 2
        completions[1]();
        async.elapse(const Duration(milliseconds: 800));
        async.flushMicrotasks();

        expect(sequencer.state.currentIndex, 2);
        expect(spokenPhrases, [p1, p2, p3]);

        // Complete phrase 3 (last phrase)
        completions[2]();
        async.elapse(const Duration(milliseconds: 800));
        async.flushMicrotasks();

        // Sequence finishes and returns to idle
        expect(sequencer.state.status, SequencerStatus.idle);
        expect(
          stateHistory.any((s) => s.status == SequencerStatus.finished),
          isTrue,
        );
        expect(stopCalls, 0);

        sequencer.dispose();
      });
    });

    test('per-phrase timeout skips phrase whose completion never arrives', () {
      fakeAsync((async) {
        final spokenPhrases = <GuidePhrase>[];
        int stopCalls = 0;

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2],
          gap: const Duration(milliseconds: 800),
          timeout: const Duration(seconds: 8),
          speakDelegate: (phrase, onComplete) async {
            spokenPhrases.add(phrase);
            // Intentionally never call onComplete for p1
            return true;
          },
          stopSpeechDelegate: () async {
            stopCalls++;
          },
        );

        sequencer.start();
        async.flushMicrotasks();

        expect(sequencer.state.currentIndex, 0);
        expect(spokenPhrases, [p1]);

        // Wait 7.9 seconds - should still be playing phrase 1
        async.elapse(const Duration(milliseconds: 7900));
        expect(sequencer.state.currentIndex, 0);
        expect(stopCalls, 0);

        // At 8.0 seconds timeout triggers, stopping speech
        async.elapse(const Duration(milliseconds: 100));
        expect(stopCalls, 1);

        // Gap of 800ms begins
        async.elapse(const Duration(milliseconds: 800));
        async.flushMicrotasks();

        // Moved to p2
        expect(sequencer.state.currentIndex, 1);
        expect(spokenPhrases, [p1, p2]);

        sequencer.dispose();
      });
    });

    test('quiet failure skip when speak returns false', () {
      fakeAsync((async) {
        final spokenPhrases = <GuidePhrase>[];
        final completions = <void Function()>[];

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2],
          gap: const Duration(milliseconds: 800),
          speakDelegate: (phrase, onComplete) async {
            spokenPhrases.add(phrase);
            if (phrase.id == 'p1') {
              // Simulated voice unavailable / speech initiation failure
              return false;
            }
            completions.add(onComplete);
            return true;
          },
          stopSpeechDelegate: () async {},
        );

        sequencer.start();
        async.flushMicrotasks();

        // p1 failed immediately, gap timer started
        expect(spokenPhrases, [p1]);

        // Advance 800ms gap
        async.elapse(const Duration(milliseconds: 800));
        async.flushMicrotasks();

        // Quietly advanced to p2
        expect(sequencer.state.currentIndex, 1);
        expect(spokenPhrases, [p1, p2]);

        sequencer.dispose();
      });
    });

    test('late completion arrival after timeout is safely ignored', () {
      fakeAsync((async) {
        final spokenPhrases = <GuidePhrase>[];
        late void Function() lateP1Completion;

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2],
          gap: const Duration(milliseconds: 800),
          timeout: const Duration(seconds: 8),
          speakDelegate: (phrase, onComplete) async {
            spokenPhrases.add(phrase);
            if (phrase.id == 'p1') {
              lateP1Completion = onComplete;
            }
            return true;
          },
          stopSpeechDelegate: () async {},
        );

        sequencer.start();
        async.flushMicrotasks();

        // Let p1 time out at 8s + 800ms gap = 8.8s
        async.elapse(const Duration(seconds: 8));
        async.elapse(const Duration(milliseconds: 800));
        async.flushMicrotasks();

        expect(sequencer.state.currentIndex, 1);

        // Now late completion arrives for p1
        lateP1Completion();
        async.flushMicrotasks();

        // Still at p2, sequence not corrupted or double-advanced
        expect(sequencer.state.currentIndex, 1);

        sequencer.dispose();
      });
    });

    test('interruption resets to idle without auto-resuming', () {
      fakeAsync((async) {
        final stateHistory = <SequencerStatus>[];
        int stopCalls = 0;

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2],
          speakDelegate: (phrase, onComplete) async => true,
          stopSpeechDelegate: () async => stopCalls++,
          onStateChanged: (s) => stateHistory.add(s.status),
        );

        sequencer.start();
        async.flushMicrotasks();
        expect(sequencer.state.isPlaying, isTrue);

        // Interrupted by phone call / audio focus loss / backgrounding
        sequencer.interrupt();
        async.flushMicrotasks();

        expect(stopCalls, 1);
        expect(stateHistory, contains(SequencerStatus.interrupted));
        expect(sequencer.state.status, SequencerStatus.idle);

        // Wait to verify no automatic resumption occurs
        async.elapse(const Duration(seconds: 15));
        expect(sequencer.state.status, SequencerStatus.idle);

        sequencer.dispose();
      });
    });

    test('user stop returns state to idle and stops speech', () {
      fakeAsync((async) {
        int stopCalls = 0;

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2],
          speakDelegate: (phrase, onComplete) async => true,
          stopSpeechDelegate: () async => stopCalls++,
        );

        sequencer.start();
        async.flushMicrotasks();
        expect(sequencer.state.isPlaying, isTrue);

        sequencer.stop();
        async.flushMicrotasks();

        expect(stopCalls, 1);
        expect(sequencer.state.status, SequencerStatus.idle);

        sequencer.dispose();
      });
    });

    test(
      'disposal safety: cancels all timers and speech; no callbacks fire',
      () {
        fakeAsync((async) {
          int stateChangesAfterDispose = 0;
          int stopCalls = 0;

          final sequencer = UnitGuideSequencer(
            phrases: [p1, p2],
            speakDelegate: (phrase, onComplete) async {
              Timer(const Duration(seconds: 1), onComplete);
              return true;
            },
            stopSpeechDelegate: () async => stopCalls++,
            onStateChanged: (s) {
              // State listener
            },
          );

          sequencer.start();
          async.flushMicrotasks();

          // Dispose while p1 is actively playing
          sequencer.dispose();
          expect(stopCalls, 1);

          // Re-assign listener to track any stray calls
          final deadSequencer = UnitGuideSequencer(
            phrases: [p1],
            speakDelegate: (_, __) async => true,
            stopSpeechDelegate: () async {},
            onStateChanged: (_) => stateChangesAfterDispose++,
          )..dispose();

          deadSequencer.start();
          deadSequencer.stop();
          deadSequencer.interrupt();

          async.elapse(const Duration(seconds: 20));
          expect(stateChangesAfterDispose, 0);
        });
      },
    );

    test('new playback always cancels previous sequence', () {
      fakeAsync((async) {
        final spokenPhrases = <GuidePhrase>[];

        final sequencer = UnitGuideSequencer(
          phrases: [p1, p2, p3],
          gap: const Duration(milliseconds: 800),
          timeout: const Duration(seconds: 8),
          speakDelegate: (phrase, onComplete) async {
            spokenPhrases.add(phrase);
            return true;
          },
          stopSpeechDelegate: () async {},
        );

        sequencer.start();
        async.flushMicrotasks();
        expect(sequencer.state.currentIndex, 0);
        expect(spokenPhrases.length, 1);

        // Start again before first phrase finishes
        sequencer.start();
        async.flushMicrotasks();

        expect(sequencer.state.currentIndex, 0);
        expect(spokenPhrases.length, 2);
        expect(spokenPhrases[1], p1);

        sequencer.dispose();
      });
    });

    test('empty phrase list finishes immediately and returns to idle', () {
      final stateHistory = <SequencerStatus>[];
      final sequencer = UnitGuideSequencer(
        phrases: const [],
        speakDelegate: (_, __) async => true,
        stopSpeechDelegate: () async {},
        onStateChanged: (s) => stateHistory.add(s.status),
      );

      sequencer.start();
      expect(stateHistory, [SequencerStatus.finished, SequencerStatus.idle]);
      expect(sequencer.state.status, SequencerStatus.idle);
      sequencer.dispose();
    });
  });

  group('UnitGuideRules', () {
    test('canOpenUnitGuide returns true for any user and unit', () {
      const unit = Unit(
        id: 'unit_1',
        unitNumber: 1,
        title: 'First conversations',
        trackId: 'everyday',
        nodes: [],
      );

      final resultGuest = UnitGuideRules.canOpenUnitGuide(
        user: null,
        unit: unit,
      );
      expect(resultGuest, isTrue);

      final resultUser = UnitGuideRules.canOpenUnitGuide(
        user: {'id': 'user_123'},
        unit: unit,
      );
      expect(resultUser, isTrue);
    });
  });
}
