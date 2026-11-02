import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/emergency/data/bundled_emergency_repository.dart';
import 'package:peddi/features/emergency/data/remote_emergency_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteEmergencyRepository Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late RemoteEmergencyRepository repo;

    const testPayload = {
      'title': 'Emergency phrasebook',
      'subtitle': 'Tap a card, then show your screen. Works with no connection.',
      'disclaimer': 'Phrases are for Spanish.',
      'learning_language': 'Spanish',
      'phrases': [
        {
          'phrase_id': 'need-a-doctor',
          'native_text': 'I need a doctor',
          'translation': 'Necesito un médico',
        },
      ],
    };

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      repo = RemoteEmergencyRepository(
        apiClient: apiClient,
        fallbackRepository: BundledEmergencyRepository(),
      );
    });

    test('getPhrasebook fetches from API and caches payload online', () async {
      fakeAdapter.onJson(
        '/api/missions/emergency',
        jsonEncode(testPayload),
      );

      final phrasebook = await repo.getPhrasebook(targetLanguageCode: 'es');

      expect(phrasebook, isNotNull);
      expect(phrasebook!.languageName, equals('Spanish'));
      expect(phrasebook.phrases.length, equals(1));
      expect(phrasebook.phrases.first.targetText, equals('Necesito un médico'));

      // Verify cached in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('emergency_phrasebook_cache_es');
      expect(cached, isNotNull);
      expect(cached, contains('Necesito un médico'));
    });

    test('getPhrasebook reads from cache when network throws', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'emergency_phrasebook_cache_es',
        jsonEncode(testPayload),
      );

      // Network throws error
      fakeAdapter.throwException(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.connectionError,
        ),
      );

      final phrasebook = await repo.getPhrasebook(targetLanguageCode: 'es');

      expect(phrasebook, isNotNull);
      expect(phrasebook!.phrases.length, equals(1));
      expect(phrasebook.phrases.first.id, equals('need-a-doctor'));
    });

    test('getPhrasebook falls back to bundled catalog when network & cache fail', () async {
      // Empty cache and failing network
      fakeAdapter.throwException(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.connectionError,
        ),
      );

      final phrasebook = await repo.getPhrasebook(targetLanguageCode: 'es');

      expect(phrasebook, isNotNull);
      expect(phrasebook!.phrases.length, equals(8));
      expect(phrasebook.languageCode, equals('es'));
    });

    test('getSupportedLanguages returns catalog languages', () async {
      final langs = await repo.getSupportedLanguages();
      expect(langs, contains('es'));
      expect(langs, contains('fr'));
    });
  });
}

