import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../domain/guide_phrase.dart';
import '../../domain/unit_guide_sequencer.dart';

/// Player status options.
enum PlayerStatus { idle, playing, stopped, interrupted, finished }

/// State representation for unit guide sequential and individual playback.
class UnitGuidePlayerState {
  const UnitGuidePlayerState({
    this.status = PlayerStatus.idle,
    this.currentIndex = -1,
    this.currentPhrase,
    this.isSinglePhrase = false,
  });

  final PlayerStatus status;
  final int currentIndex;
  final GuidePhrase? currentPhrase;
  final bool isSinglePhrase;

  bool get isPlaying => status == PlayerStatus.playing;
  bool get canPlay => status != PlayerStatus.playing;
  String? get playingPhraseId => currentPhrase?.id;
}

/// Auto-disposing notifier managing sequential and individual phrase playback.
///
/// Follows AGENTS.md §2.3: session state that resets when user leaves sheet.
class UnitGuidePlayer extends StateNotifier<UnitGuidePlayerState> {
  UnitGuidePlayer({
    required this.ttsService,
    this.gap = const Duration(milliseconds: 800),
    this.timeout = const Duration(milliseconds: 8000),
  }) : super(const UnitGuidePlayerState());

  final TextToSpeechService ttsService;
  final Duration gap;
  final Duration timeout;

  UnitGuideSequencer? _sequencer;
  bool _isDisposed = false;

  /// Starts or restarts sequential playback for the entire unit.
  void playUnit(List<GuidePhrase> phrases) {
    if (_isDisposed) return;
    _cancelAnyPlayback();

    _sequencer = UnitGuideSequencer(
      phrases: phrases,
      gap: gap,
      timeout: timeout,
      speakDelegate: (phrase, onComplete) {
        return ttsService.speak(
          phrase.targetText,
          locale: phrase.audioLocale,
          onCompletion: onComplete,
        );
      },
      stopSpeechDelegate: () => ttsService.stop(),
      onStateChanged: (snapshot) {
        if (_isDisposed) return;
        state = UnitGuidePlayerState(
          status: _mapStatus(snapshot.status),
          currentIndex: snapshot.currentIndex,
          currentPhrase: snapshot.currentPhrase,
          isSinglePhrase: false,
        );
      },
    );

    _sequencer?.start();
  }

  /// Plays a single tapped phrase once. If unit playback was running, cancels it first.
  Future<void> playSinglePhrase(GuidePhrase phrase) async {
    if (_isDisposed) return;
    _cancelAnyPlayback();

    state = UnitGuidePlayerState(
      status: PlayerStatus.playing,
      currentIndex: -1,
      currentPhrase: phrase,
      isSinglePhrase: true,
    );

    final started = await ttsService.speak(
      phrase.targetText,
      locale: phrase.audioLocale,
      onCompletion: () {
        if (_isDisposed) return;
        if (state.currentPhrase?.id == phrase.id && state.isSinglePhrase) {
          state = const UnitGuidePlayerState(status: PlayerStatus.idle);
        }
      },
    );

    if (!started && !_isDisposed) {
      state = const UnitGuidePlayerState(status: PlayerStatus.idle);
    }
  }

  /// Explicitly stops any active playback (user tap).
  void stop() {
    if (_isDisposed) return;
    _cancelAnyPlayback();
    state = const UnitGuidePlayerState(status: PlayerStatus.stopped);
    state = const UnitGuidePlayerState(status: PlayerStatus.idle);
  }

  /// Halts playback due to external interruption (background, call, focus loss).
  void interrupt() {
    if (_isDisposed) return;
    _cancelAnyPlayback();
    state = const UnitGuidePlayerState(status: PlayerStatus.interrupted);
    state = const UnitGuidePlayerState(status: PlayerStatus.idle);
  }

  /// Immediately cancels sequencer timers and stops in-flight speech without notifying listeners.
  void cancelPlayback() {
    _cancelAnyPlayback();
  }

  void _cancelAnyPlayback() {
    _sequencer?.dispose();
    _sequencer = null;
    ttsService.stop();
  }

  static PlayerStatus _mapStatus(SequencerStatus s) {
    switch (s) {
      case SequencerStatus.idle:
        return PlayerStatus.idle;
      case SequencerStatus.playing:
        return PlayerStatus.playing;
      case SequencerStatus.stopped:
        return PlayerStatus.stopped;
      case SequencerStatus.interrupted:
        return PlayerStatus.interrupted;
      case SequencerStatus.finished:
        return PlayerStatus.finished;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelAnyPlayback();
    super.dispose();
  }
}

/// Riverpod provider for [UnitGuidePlayer].
final unitGuidePlayerProvider =
    StateNotifierProvider.autoDispose<UnitGuidePlayer, UnitGuidePlayerState>((
      ref,
    ) {
      final tts = ref.watch(textToSpeechServiceProvider);
      return UnitGuidePlayer(ttsService: tts);
    });
