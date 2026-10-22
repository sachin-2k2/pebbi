import 'dart:math' as math;
import 'speaking_config.dart';

/// Pure domain utility for comparing recognized speech hypotheses against target phrases.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
/// Handles punctuation, accents, Arabic diacritics, and space-less scripts (Japanese/Chinese).
abstract final class SpeechMatcher {
  /// Compares [target] and [hypothesis] and returns true if similarity reaches [threshold].
  static bool isMatch({
    required String target,
    required String hypothesis,
    String? locale,
    double threshold = SpeakingConfig.similarityThreshold,
    bool ignoreAccents = SpeakingConfig.ignoreAccents,
  }) {
    final score = similarityScore(
      target: target,
      hypothesis: hypothesis,
      locale: locale,
      ignoreAccents: ignoreAccents,
    );
    return score >= threshold;
  }

  /// Calculates a normalized similarity score between 0.0 and 1.0.
  static double similarityScore({
    required String target,
    required String hypothesis,
    String? locale,
    bool ignoreAccents = SpeakingConfig.ignoreAccents,
  }) {
    final normTarget = normalize(target, locale: locale, ignoreAccents: ignoreAccents);
    final normHypo = normalize(hypothesis, locale: locale, ignoreAccents: ignoreAccents);

    if (normTarget.isEmpty) return normHypo.isEmpty ? 1.0 : 0.0;
    if (normHypo.isEmpty) return 0.0;
    if (normTarget == normHypo) return 1.0;

    final isNoSpaceScript = _isNoSpaceLanguage(locale);
    if (isNoSpaceScript) {
      return _characterSimilarity(normTarget, normHypo);
    }

    final targetTokens = normTarget.split(' ').where((s) => s.isNotEmpty).toList();
    final hypoTokens = normHypo.split(' ').where((s) => s.isNotEmpty).toList();

    if (targetTokens.isEmpty) return hypoTokens.isEmpty ? 1.0 : 0.0;
    if (hypoTokens.isEmpty) return 0.0;

    int matchedCount = 0;
    final usedHypoIndices = <int>{};

    for (final targetToken in targetTokens) {
      int bestIndex = -1;
      double bestScore = 0.0;

      for (int i = 0; i < hypoTokens.length; i++) {
        if (usedHypoIndices.contains(i)) continue;
        final tokenScore = _characterSimilarity(targetToken, hypoTokens[i]);
        if (tokenScore > bestScore) {
          bestScore = tokenScore;
          bestIndex = i;
        }
      }

      if (bestIndex != -1 && bestScore >= 0.75) {
        matchedCount++;
        usedHypoIndices.add(bestIndex);
      }
    }

    return (matchedCount / targetTokens.length).clamp(0.0, 1.0);
  }

  /// Normalizes phrase text for fair linguistic comparison.
  static String normalize(
    String input, {
    String? locale,
    bool ignoreAccents = SpeakingConfig.ignoreAccents,
  }) {
    var text = input.trim().toLowerCase();

    // Remove Spanish inverted marks and general punctuation
    text = text.replaceAll(RegExp(r'[¿¡.,!?:;"\-_(){}\[\]/\\`~*^%$#@]'), ' ');

    if (_isArabic(locale) || _containsArabic(text)) {
      text = _normalizeArabic(text);
    } else if (ignoreAccents) {
      text = _stripDiacritics(text);
    }

    // Collapse whitespace
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _isNoSpaceLanguage(String? locale) {
    if (locale == null) return false;
    final code = locale.toLowerCase();
    return code.startsWith('ja') || code.startsWith('zh');
  }

  static bool _isArabic(String? locale) {
    if (locale == null) return false;
    return locale.toLowerCase().startsWith('ar');
  }

  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  static String _normalizeArabic(String text) {
    return text
        // Remove Arabic tashkeel (fatha, damma, kasra, sukun, shadda, tanwin)
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '')
        // Normalize alif variants to plain alif
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        // Normalize alif maqsura to yaa
        .replaceAll('ى', 'ي')
        // Normalize taa marbuta to haa
        .replaceAll('ة', 'ه');
  }

  static String _stripDiacritics(String text) {
    return text
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u');
  }

  static double _characterSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final distance = _levenshteinDistance(s1, s2);
    final maxLen = math.max(s1.length, s2.length);
    return (1.0 - (distance / maxLen)).clamp(0.0, 1.0);
  }

  static int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final d = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        d[i][j] = math.min(
          d[i - 1][j] + 1,
          math.min(d[i][j - 1] + 1, d[i - 1][j - 1] + cost),
        );
      }
    }

    return d[m][n];
  }
}
