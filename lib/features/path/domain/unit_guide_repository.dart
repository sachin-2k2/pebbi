import 'unit_guide.dart';

/// Repository interface managing unit guidebook content and offline access.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
abstract class UnitGuideRepository {
  /// Loads the unit guide for [unitId] with content tailored to [languageCode]
  /// and translated explanations in [explanationLanguageCode].
  Future<UnitGuide?> getUnitGuide(
    String unitId, {
    required String languageCode,
    required String explanationLanguageCode,
    bool isOnline = true,
  });

  /// Checks whether the unit guide data is cached locally for offline review.
  bool isGuideCached(String unitId);
}
