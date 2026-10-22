import 'self_check_reason.dart';
import 'speaking_config.dart';

/// Current visual and execution state of a speaking exercise.
enum SpeakFlowState {
  /// Screen A: Microphone ready, waiting for user tap.
  ready,

  /// Screen A: Microphone active and recording audio; level meter active.
  listening,

  /// Full speech match achieved; triggers correct FeedbackPanel with full credit.
  matched,

  /// Screen B: Self-check fallback active.
  selfCheck,

  /// Learner confirmed "I said it ✓"; triggers FeedbackPanel with half credit.
  selfChecked,

  /// Learner tapped "Skip for now"; advances without penalty or credit.
  skipped,
}

/// Pure Dart state machine modeling the complete lifecycle of a speaking exercise.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
class SpeakingStateMachine {
  SpeakingStateMachine({
    SpeakFlowState initial = SpeakFlowState.ready,
    SelfCheckReason? selfCheckReason,
  })  : _flowState = initial,
        _selfCheckReason = selfCheckReason;

  SpeakFlowState _flowState;
  SelfCheckReason? _selfCheckReason;
  double _soundLevel = 0.0;
  double _credit = SpeakingConfig.zeroCreditValue;

  SpeakFlowState get flowState => _flowState;
  SelfCheckReason? get selfCheckReason => _selfCheckReason;
  double get soundLevel => _soundLevel;
  double get credit => _credit;

  bool get isReady => _flowState == SpeakFlowState.ready;
  bool get isListening => _flowState == SpeakFlowState.listening;
  bool get isMatched => _flowState == SpeakFlowState.matched;
  bool get isSelfCheck => _flowState == SpeakFlowState.selfCheck;
  bool get isSelfChecked => _flowState == SpeakFlowState.selfChecked;
  bool get isSkipped => _flowState == SpeakFlowState.skipped;

  /// Starts listening if in [SpeakFlowState.ready] state.
  void startListening() {
    if (_flowState != SpeakFlowState.ready) return;
    _flowState = SpeakFlowState.listening;
    _soundLevel = 0.0;
  }

  /// Cancels listening and returns to [SpeakFlowState.ready].
  void stopListening() {
    if (_flowState != SpeakFlowState.listening) return;
    _flowState = SpeakFlowState.ready;
    _soundLevel = 0.0;
  }

  /// Records a successful speech recognition match with full credit (1.0).
  void onSpeechMatched() {
    if (_flowState != SpeakFlowState.listening) return;
    _flowState = SpeakFlowState.matched;
    _credit = SpeakingConfig.fullCreditValue;
    _soundLevel = 0.0;
  }

  /// Transitions to Screen B (self-check fallback) with a specific [SelfCheckReason].
  ///
  /// A failed recognition is NEVER treated as a wrong answer (no red panel, no redo).
  void toSelfCheck(SelfCheckReason reason) {
    _flowState = SpeakFlowState.selfCheck;
    _selfCheckReason = reason;
    _soundLevel = 0.0;
  }

  /// Records that the user confirmed "I said it ✓" with half credit (0.5).
  void onSelfCheckConfirmed() {
    if (_flowState != SpeakFlowState.selfCheck) return;
    _flowState = SpeakFlowState.selfChecked;
    _credit = SpeakingConfig.halfCreditValue;
  }

  /// Records that the user skipped the speaking exercise with zero credit (0.0).
  void onSkipped() {
    _flowState = SpeakFlowState.skipped;
    _credit = SpeakingConfig.zeroCreditValue;
  }

  /// Updates normalized microphone sound level (0.0 to 1.0) while listening.
  void updateSoundLevel(double level) {
    if (_flowState != SpeakFlowState.listening) return;
    _soundLevel = level.clamp(0.0, 1.0);
  }
}
