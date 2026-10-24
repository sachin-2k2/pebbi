import 'dart:async';
import 'guide_phrase.dart';

/// State of the unit guide sequential audio playback.
enum SequencerStatus { idle, playing, stopped, interrupted, finished }

/// Snapshot of the sequencer state at any point in time.
class SequencerSnapshot {
  const SequencerSnapshot({
    required this.status,
    this.currentIndex = -1,
    this.currentPhrase,
  });

  final SequencerStatus status;
  final int currentIndex;
  final GuidePhrase? currentPhrase;

  bool get isPlaying => status == SequencerStatus.playing;
  bool get canPlay => status != SequencerStatus.playing;

  static const idle = SequencerSnapshot(status: SequencerStatus.idle);
}

/// Pure Dart sequencer managing sequential audio playback for guidebook phrases.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
/// Highly testable via dependency-injected timer factories and speech delegates.
class UnitGuideSequencer {
  UnitGuideSequencer({
    required this.phrases,
    required this.speakDelegate,
    required this.stopSpeechDelegate,
    this.gap = const Duration(milliseconds: 800),
    this.timeout = const Duration(milliseconds: 8000),
    this.timerFactory = _defaultTimerFactory,
    this.onStateChanged,
  });

  final List<GuidePhrase> phrases;

  /// Delegate invoking TTS or recorded audio playback.
  /// Receives [phrase] and a completion callback [onComplete] to be called when speech finishes.
  /// Must return `true` if playback started, or `false` on quiet failure.
  final Future<bool> Function(GuidePhrase phrase, void Function() onComplete)
  speakDelegate;

  /// Delegate stopping current in-flight speech.
  final Future<void> Function() stopSpeechDelegate;

  final Duration gap;
  final Duration timeout;
  final Timer Function(Duration duration, void Function() callback)
  timerFactory;
  final void Function(SequencerSnapshot state)? onStateChanged;

  SequencerSnapshot _state = SequencerSnapshot.idle;
  SequencerSnapshot get state => _state;

  Timer? _gapTimer;
  Timer? _timeoutTimer;
  int _activeSequenceGeneration = 0;
  bool _isDisposed = false;

  static Timer _defaultTimerFactory(
    Duration duration,
    void Function() callback,
  ) {
    return Timer(duration, callback);
  }

  void _setState(SequencerSnapshot next) {
    if (_isDisposed) return;
    _state = next;
    onStateChanged?.call(_state);
  }

  /// Starts or restarts sequential playback from the beginning (index 0).
  ///
  /// Any existing playback or pending timers are cancelled first.
  void start() {
    if (_isDisposed) return;
    _cancelInternalTimers();
    _activeSequenceGeneration++;

    if (phrases.isEmpty) {
      _setState(const SequencerSnapshot(status: SequencerStatus.finished));
      _setState(SequencerSnapshot.idle);
      return;
    }

    _playPhraseAtIndex(0, _activeSequenceGeneration);
  }

  /// Stops playback by explicit user action.
  void stop() {
    if (_isDisposed) return;
    _activeSequenceGeneration++;
    _cancelInternalTimers();
    stopSpeechDelegate();
    _setState(const SequencerSnapshot(status: SequencerStatus.stopped));
    _setState(SequencerSnapshot.idle);
  }

  /// Interrupts playback due to external event (phone call, audio focus loss, app background).
  ///
  /// Does not resume automatically; state returns to idle.
  void interrupt() {
    if (_isDisposed) return;
    _activeSequenceGeneration++;
    _cancelInternalTimers();
    stopSpeechDelegate();
    _setState(const SequencerSnapshot(status: SequencerStatus.interrupted));
    _setState(SequencerSnapshot.idle);
  }

  void _playPhraseAtIndex(int index, int sequenceGen) {
    if (_isDisposed || sequenceGen != _activeSequenceGeneration) return;

    if (index >= phrases.length) {
      _setState(const SequencerSnapshot(status: SequencerStatus.finished));
      _setState(SequencerSnapshot.idle);
      return;
    }

    final phrase = phrases[index];
    _setState(
      SequencerSnapshot(
        status: SequencerStatus.playing,
        currentIndex: index,
        currentPhrase: phrase,
      ),
    );

    bool hasCompletedOrTimedOut = false;

    void onPhraseFinished() {
      if (_isDisposed ||
          sequenceGen != _activeSequenceGeneration ||
          hasCompletedOrTimedOut) {
        return;
      }
      hasCompletedOrTimedOut = true;
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      // Schedule advance to next phrase after the configured pause gap
      _gapTimer?.cancel();
      _gapTimer = timerFactory(gap, () {
        if (_isDisposed || sequenceGen != _activeSequenceGeneration) return;
        _playPhraseAtIndex(index + 1, sequenceGen);
      });
    }

    // Set per-phrase timeout in case speech completion never arrives
    _timeoutTimer?.cancel();
    _timeoutTimer = timerFactory(timeout, () {
      if (_isDisposed ||
          sequenceGen != _activeSequenceGeneration ||
          hasCompletedOrTimedOut) {
        return;
      }
      // Timeout fired before completion: skip phrase quietly
      stopSpeechDelegate();
      onPhraseFinished();
    });

    // Invoke speech delegate
    speakDelegate(phrase, onPhraseFinished).then((started) {
      if (_isDisposed || sequenceGen != _activeSequenceGeneration) return;
      if (!started && !hasCompletedOrTimedOut) {
        // Speech initiation failed (e.g. voice unavailable): skip phrase quietly
        onPhraseFinished();
      }
    });
  }

  void _cancelInternalTimers() {
    _gapTimer?.cancel();
    _gapTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Disposes the sequencer, immediately cancelling all timers and speech.
  void dispose() {
    _isDisposed = true;
    _activeSequenceGeneration++;
    _cancelInternalTimers();
    stopSpeechDelegate();
  }
}
