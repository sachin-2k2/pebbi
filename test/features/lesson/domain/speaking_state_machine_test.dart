import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/lesson/domain/self_check_reason.dart';
import 'package:peddi/features/lesson/domain/speaking_config.dart';
import 'package:peddi/features/lesson/domain/speaking_safety_rules.dart';
import 'package:peddi/features/lesson/domain/speaking_state_machine.dart';

void main() {
  group('SpeakingStateMachine', () {
    test('initial state is ready with zero credit', () {
      final sm = SpeakingStateMachine();

      expect(sm.isReady, isTrue);
      expect(sm.isListening, isFalse);
      expect(sm.credit, equals(SpeakingConfig.zeroCreditValue));
      expect(sm.selfCheckReason, isNull);
    });

    test('startListening transitions from ready to listening', () {
      final sm = SpeakingStateMachine();
      sm.startListening();

      expect(sm.isListening, isTrue);
      expect(sm.isReady, isFalse);
    });

    test('stopListening returns from listening to ready', () {
      final sm = SpeakingStateMachine();
      sm.startListening();
      sm.stopListening();

      expect(sm.isReady, isTrue);
      expect(sm.isListening, isFalse);
    });

    test('onSpeechMatched awards full credit (1.0)', () {
      final sm = SpeakingStateMachine();
      sm.startListening();
      sm.onSpeechMatched();

      expect(sm.isMatched, isTrue);
      expect(sm.credit, equals(SpeakingConfig.fullCreditValue));
    });

    test('toSelfCheck transitions with specified reason', () {
      final sm = SpeakingStateMachine();
      sm.toSelfCheck(SelfCheckReason.notHeard);

      expect(sm.isSelfCheck, isTrue);
      expect(sm.selfCheckReason, equals(SelfCheckReason.notHeard));
    });

    test('onSelfCheckConfirmed awards half credit (0.5)', () {
      final sm = SpeakingStateMachine();
      sm.toSelfCheck(SelfCheckReason.userChose);
      sm.onSelfCheckConfirmed();

      expect(sm.isSelfChecked, isTrue);
      expect(sm.credit, equals(SpeakingConfig.halfCreditValue));
    });

    test('onSkipped records skipped with zero credit (0.0)', () {
      final sm = SpeakingStateMachine();
      sm.toSelfCheck(SelfCheckReason.notHeard);
      sm.onSkipped();

      expect(sm.isSkipped, isTrue);
      expect(sm.credit, equals(SpeakingConfig.zeroCreditValue));
    });

    test('sound level updates only while listening and clamps 0.0 to 1.0', () {
      final sm = SpeakingStateMachine();
      sm.updateSoundLevel(0.5);
      expect(sm.soundLevel, equals(0.0)); // ignored while ready

      sm.startListening();
      sm.updateSoundLevel(0.85);
      expect(sm.soundLevel, equals(0.85));

      sm.updateSoundLevel(1.5);
      expect(sm.soundLevel, equals(1.0)); // clamped

      sm.updateSoundLevel(-0.2);
      expect(sm.soundLevel, equals(0.0)); // clamped
    });
  });

  group('SpeakingSafetyRules', () {
    test('disallows speaking for child age band', () {
      expect(SpeakingSafetyRules.shouldAllowSpeaking(AgeBand.child), isFalse);
    });

    test('allows speaking for adult and teen age bands', () {
      expect(SpeakingSafetyRules.shouldAllowSpeaking(AgeBand.adult), isTrue);
      expect(SpeakingSafetyRules.shouldAllowSpeaking(AgeBand.teen), isTrue);
      expect(SpeakingSafetyRules.shouldAllowSpeaking(null), isTrue);
    });
  });
}
