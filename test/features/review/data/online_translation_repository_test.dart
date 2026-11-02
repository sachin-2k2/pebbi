import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/review/data/online_translation_repository.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  group('OnlineTranslationRepository Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late Dio dio;
    late OnlineTranslationRepository repo;

    setUp(() {
      fakeAdapter = FakeHttpClientAdapter();
      dio = Dio()..httpClientAdapter = fakeAdapter;
      repo = OnlineTranslationRepository(dio: dio);
    });

    test('returns clean translatedText from MyMemory API', () async {
      fakeAdapter.onJson(
        '/get',
        jsonEncode({
          'responseData': {
            'translatedText': 'ഒരു കാപ്പി, ദയവായി.',
            'match': 0.85,
          },
        }),
      );

      final result = await repo.translate(
        query: 'one coffee please',
        targetLanguageCode: 'ml',
        explanationLanguageCode: 'en',
      );

      expect(result, 'ഒരു കാപ്പി, ദയവായി.');
    });

    test('unescapes HTML entities in API response', () async {
      fakeAdapter.onJson(
        '/get',
        jsonEncode({
          'responseData': {
            'translatedText': "Un caf&#39;e &amp; de l&#39;eau &quot;s&#39;il vous plait&quot;",
          },
        }),
      );

      final result = await repo.translate(
        query: 'coffee and water please',
        targetLanguageCode: 'fr',
        explanationLanguageCode: 'en',
      );

      expect(result, 'Un caf\'e & de l\'eau "s\'il vous plait"');
    });

    test('falls back to offline heuristic for Malayalam when API call fails', () async {
      fakeAdapter.throwException((options) {
        return DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      final result = await repo.translate(
        query: 'coffee with milk please',
        targetLanguageCode: 'ml',
        explanationLanguageCode: 'en',
      );

      expect(result, 'പാൽ ഉള്ള ഒരു കോഫി, ദയവായി.');
    });

    test('returns exact text when source and target languages match', () async {
      final result = await repo.translate(
        query: 'ഹലോ',
        targetLanguageCode: 'ml',
        explanationLanguageCode: 'ml',
      );

      expect(result, 'ഹലോ');
    });
  });
}
