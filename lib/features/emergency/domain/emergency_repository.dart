import 'emergency_phrasebook.dart';

/// Abstract contract for fetching offline emergency phrasebooks.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract class EmergencyRepository {
  /// Fetches the emergency phrasebook for the given [targetLanguageCode],
  /// or null if the language is not recognized.
  Future<EmergencyPhrasebook?> getPhrasebook({
    required String targetLanguageCode,
  });

  /// Fetches all language codes defined in the catalog.
  Future<List<String>> getSupportedLanguages();
}
