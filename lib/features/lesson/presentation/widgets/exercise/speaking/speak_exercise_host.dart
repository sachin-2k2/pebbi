import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/services/text_to_speech_service.dart';
import '../../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../../domain/exercise.dart';
import '../../../../domain/self_check_reason.dart';
import '../../../../domain/speaking_config.dart';
import '../../../../domain/speaking_safety_rules.dart';
import '../../../../domain/speaking_state_machine.dart';
import '../../../../domain/speech_matcher.dart';
import '../../../providers/lesson_providers.dart';
import 'self_check_body.dart';
import 'speak_body.dart';

/// Host widget coordinating the speech recognition lifecycle, TTS, and fallback transitions.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines.
class SpeakExerciseHost extends ConsumerStatefulWidget {
  const SpeakExerciseHost({super.key, required this.exercise});

  final SpeakExercise exercise;

  @override
  ConsumerState<SpeakExerciseHost> createState() => _SpeakExerciseHostState();
}

class _SpeakExerciseHostState extends ConsumerState<SpeakExerciseHost> {
  final SpeakingStateMachine _sm = SpeakingStateMachine();
  StreamSubscription<double>? _soundSub;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    final user = ref.read(currentUserProvider);
    if (!settings.speakingPracticeEnabled) {
      _sm.toSelfCheck(SelfCheckReason.settingOff);
    } else if (!SpeakingSafetyRules.shouldAllowSpeaking(user?.ageBand)) {
      _sm.toSelfCheck(SelfCheckReason.policy);
    }

    final recognizer = ref.read(speechRecognizerServiceProvider);
    _soundSub = recognizer.soundLevelStream.listen((lvl) {
      if (_sm.isListening && mounted) setState(() => _sm.updateSoundLevel(lvl));
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _soundSub?.cancel();
    super.dispose();
  }

  Future<void> _onHearIt() async {
    await _stopListeningQuietly();
    await ref.read(textToSpeechServiceProvider).speak(
        widget.exercise.phrase, locale: widget.exercise.audioLocale);
  }

  Future<void> _stopListeningQuietly() async {
    _timeoutTimer?.cancel();
    final recognizer = ref.read(speechRecognizerServiceProvider);
    if (recognizer.isListening) await recognizer.stop();
    if (_sm.isListening && mounted) setState(() => _sm.stopListening());
  }

  Future<void> _onMicTap() async {
    await ref.read(textToSpeechServiceProvider).stop();
    final recognizer = ref.read(speechRecognizerServiceProvider);
    if (_sm.isListening) {
      await _stopListeningQuietly();
      return;
    }

    final ok = await recognizer.initialize();
    if (!ok || !recognizer.hasPermission) {
      if (!mounted) return;
      final reason = recognizer.hasPermission
          ? SelfCheckReason.unavailable
          : SelfCheckReason.permissionDenied;
      setState(() => _sm.toSelfCheck(reason));
      return;
    }

    setState(() => _sm.startListening());
    _timeoutTimer = Timer(SpeakingConfig.maxListeningDuration, () async {
      await recognizer.stop();
      if (mounted && _sm.isListening) setState(() => _sm.toSelfCheck(SelfCheckReason.notHeard));
    });

    await recognizer.listen(
      localeId: widget.exercise.sttLocale,
      onResult: (words, isFinal) async {
        final match = SpeechMatcher.isMatch(
          target: widget.exercise.phrase,
          hypothesis: words,
          locale: widget.exercise.sttLocale,
        );
        if (match) {
          _timeoutTimer?.cancel();
          await recognizer.stop();
          if (!mounted) return;
          setState(() => _sm.onSpeechMatched());
          await ref.read(exerciseSessionProvider.notifier).onSpeakMatched();
        } else if (isFinal) {
          _timeoutTimer?.cancel();
          await recognizer.stop();
          if (mounted) setState(() => _sm.toSelfCheck(SelfCheckReason.notHeard));
        }
      },
    );
  }

  void _onRatherNot() {
    _stopListeningQuietly();
    setState(() => _sm.toSelfCheck(SelfCheckReason.userChose));
  }

  void _onSaidIt() {
    setState(() => _sm.onSelfCheckConfirmed());
    ref.read(exerciseSessionProvider.notifier).onSelfCheckConfirmed(reason: _sm.selfCheckReason);
  }

  void _onSkip() {
    setState(() => _sm.onSkipped());
    ref.read(exerciseSessionProvider.notifier).onSpeakSkipped(reason: _sm.selfCheckReason);
  }

  @override
  Widget build(BuildContext context) {
    return _sm.isSelfCheck
        ? SelfCheckBody(
            exercise: widget.exercise,
            reason: _sm.selfCheckReason,
            onHearAgain: _onHearIt,
            onSaidIt: _onSaidIt,
            onSkip: _onSkip,
          )
        : SpeakBody(
            exercise: widget.exercise,
            isListening: _sm.isListening,
            soundLevel: _sm.soundLevel,
            onMicTap: _onMicTap,
            onHearIt: _onHearIt,
            onRatherNotSpeak: _onRatherNot,
          );
  }
}
