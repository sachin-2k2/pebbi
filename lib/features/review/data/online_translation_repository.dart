import 'package:dio/dio.dart';
import '../domain/translation_repository.dart';

/// Real translation repository using the public MyMemory translation API
/// with an offline heuristic fallback for common conversational phrases.
///
/// Follows AGENTS.md §2.1 & §5.1: Zero Flutter imports, pure Dart,
/// gracefully falls back when device is offline or API limit is reached.
class OnlineTranslationRepository implements TranslationRepository {
  OnlineTranslationRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<String> translate({
    required String query,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return '';

    final src = explanationLanguageCode.isNotEmpty
        ? explanationLanguageCode.toLowerCase()
        : 'en';
    final tgt = targetLanguageCode.isNotEmpty
        ? targetLanguageCode.toLowerCase()
        : 'ml';

    // If source and target are the same language, no translation needed
    if (src == tgt) return trimmed;

    try {
      final langPair = '$src|$tgt';
      final uri = 'https://api.mymemory.translated.net/get';
      final response = await _dio.get<Map<String, dynamic>>(
        uri,
        queryParameters: {'q': trimmed, 'langpair': langPair},
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      final data = response.data;
      if (data != null && data['responseData'] is Map) {
        final resData = data['responseData'] as Map<String, dynamic>;
        final translatedText = resData['translatedText']?.toString();
        if (translatedText != null &&
            translatedText.isNotEmpty &&
            !translatedText.toUpperCase().contains('MYMEMORY WARNING')) {
          return _cleanText(translatedText);
        }
      }
    } catch (_) {
      // Fallback to offline heuristic
    }

    return _fallbackOffline(trimmed, tgt);
  }

  String _cleanText(String text) {
    return text
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  String _fallbackOffline(String query, String targetCode) {
    final q = query.toLowerCase();

    if (targetCode == 'ml') {
      if (q.contains('milk coffee') || (q.contains('milk') && q.contains('coffee'))) {
        return 'പാൽ ഉള്ള ഒരു കോഫി, ദയവായി.';
      }
      if (q.contains('coffee')) return 'ഒരു കോഫി, ദയവായി.';
      if (q.contains('tea')) return 'ഒരു കറുത്ത ചായ, പ്ലീസ്.';
      if (q.contains('how much') || q.contains('price') || q.contains('cost')) {
        return 'ഇതിന് എത്ര പണം നൽകണം?';
      }
      if (q.contains('50') || q.contains('rupee')) return 'ഇതാ, 50 രൂപ. നന്ദി!';
      if (q.contains('thank')) return 'നന്ദി!';
      if (q.contains('hello') || q.contains('morning')) return 'ഹലോ! സുപ്രഭാതം.';
      if (q.contains('toilet') || q.contains('restroom')) return 'ടോയ്‌ലറ്റ് എവിടെയാണ്?';
      if (q.contains('excuse') || q.contains('sorry')) return 'ക്ഷമിക്കണം!';
    } else if (targetCode == 'es') {
      if (q.contains('coffee')) return 'Un café, por favor.';
      if (q.contains('how much')) return '¿Cuánto cuesta?';
      if (q.contains('thank')) return '¡Muchas gracias!';
      if (q.contains('toilet') || q.contains('restroom')) return '¿Dónde está el baño?';
    } else if (targetCode == 'fr') {
      if (q.contains('coffee')) return "Un café, s'il vous plaît.";
      if (q.contains('how much')) return "C'est combien ?";
      if (q.contains('thank')) return 'Merci beaucoup !';
      if (q.contains('toilet') || q.contains('restroom')) return 'Où sont les toilettes ?';
    }

    return query;
  }
}

