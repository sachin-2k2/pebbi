/// Domain model representing a premium value proposition card.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
/// Feature list is data-driven (id, emoji, titleKey, captionKey) to allow updates without code refactoring.
class PremiumFeature {
  const PremiumFeature({
    required this.id,
    required this.emoji,
    required this.titleKey,
    required this.captionKey,
  });

  /// Unique identifier (e.g. `all_units`).
  final String id;

  /// Decorative emoji representing the feature.
  final String emoji;

  /// Key or string identifier for the bold title.
  final String titleKey;

  /// Key or string identifier for the descriptive caption.
  final String captionKey;

  /// Canonical 6 features displayed on the "Unlock all of Pebbi" paywall.
  static const List<PremiumFeature> defaultFeatures = [
    PremiumFeature(
      id: 'units',
      emoji: '🔓',
      titleKey: 'units',
      captionKey: 'units_caption',
    ),
    PremiumFeature(
      id: 'languages',
      emoji: '🌍',
      titleKey: 'languages',
      captionKey: 'languages_caption',
    ),
    PremiumFeature(
      id: 'missions',
      emoji: '🎙️',
      titleKey: 'missions',
      captionKey: 'missions_caption',
    ),
    PremiumFeature(
      id: 'no_ads',
      emoji: '🚫',
      titleKey: 'no_ads',
      captionKey: 'no_ads_caption',
    ),
    PremiumFeature(
      id: 'offline',
      emoji: '📥',
      titleKey: 'offline',
      captionKey: 'offline_caption',
    ),
    PremiumFeature(
      id: 'exams',
      emoji: '🎓',
      titleKey: 'exams',
      captionKey: 'exams_caption',
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumFeature &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          titleKey == other.titleKey &&
          captionKey == other.captionKey;

  @override
  int get hashCode => Object.hash(id, emoji, titleKey, captionKey);
}
