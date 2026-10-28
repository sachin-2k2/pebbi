import 'package:flutter/foundation.dart';
import '../../domain/language_level.dart';

/// Bidirectional mapping between domain [LanguageLevel] and backend level strings.
///
/// Follows AGENTS.md §2 & API-UPDATES.md §5:
/// - `little` <-> `starter`
/// - `knowABit` <-> `know_a_bit`
/// - `expert` <-> `expert`
abstract final class LevelMapper {
  static const String starter = 'starter';
  static const String knowABit = 'know_a_bit';
  static const String expert = 'expert';

  /// Converts a domain [LanguageLevel] to the backend API string.
  static String toApi(LanguageLevel? level) {
    if (level == null) return starter;
    switch (level) {
      case LanguageLevel.little:
        return starter;
      case LanguageLevel.knowABit:
        return knowABit;
      case LanguageLevel.expert:
        return expert;
    }
  }

  /// Converts a backend API string to domain [LanguageLevel] with tolerant fallback.
  static LanguageLevel fromApi(String? apiLevel) {
    if (apiLevel == null) return LanguageLevel.little;
    switch (apiLevel.toLowerCase().trim()) {
      case starter:
      case 'little':
        return LanguageLevel.little;
      case knowABit:
      case 'knowabit':
        return LanguageLevel.knowABit;
      case expert:
        return LanguageLevel.expert;
      default:
        if (kDebugMode) {
          debugPrint(
            '[LevelMapper] Unknown backend level: "$apiLevel". Falling back to little.',
          );
        }
        return LanguageLevel.little;
    }
  }
}
