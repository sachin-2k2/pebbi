import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';

void main() {
  group('FakeSpeechService Unit Tests', () {
    test('speaks text and records history', () async {
      final service = FakeSpeechService();

      final result = await service.speak('¡Hola!', locale: 'es-ES');
      expect(result, isTrue);
      expect(service.isSpeaking, isTrue);
      expect(service.lastSpokenText, equals('¡Hola!'));
      expect(service.lastLocale, equals('es-ES'));
      expect(service.spokenHistory.length, equals(1));
    });

    test('stops speech on request and increments stop count', () async {
      final service = FakeSpeechService();

      await service.speak('Bonjour !', locale: 'fr-FR');
      expect(service.isSpeaking, isTrue);

      await service.stop();
      expect(service.isSpeaking, isFalse);
      expect(service.stopCallCount, greaterThanOrEqualTo(1));
    });

    test('fails quietly when locale is not supported', () async {
      final service = FakeSpeechService(supportedLocales: {'es-ES', 'fr-FR'});

      final ok = await service.speak('¡Hola!', locale: 'es-ES');
      expect(ok, isTrue);

      final failed = await service.speak('مرحبًا', locale: 'ar-SA');
      expect(failed, isFalse);
      expect(service.lastSpokenText, equals('¡Hola!'));
    });
  });
}
