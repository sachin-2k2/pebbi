/// Domain model for placement intro greeting message.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class PlacementIntro {
  const PlacementIntro({
    required this.pebbiSays,
    required this.subtitle,
    this.nativeLanguage,
    this.targetLanguage,
    this.title,
    this.estimatedMinutes,
  });

  final String pebbiSays;
  final String subtitle;
  final String? nativeLanguage;
  final String? targetLanguage;
  final String? title;
  final int? estimatedMinutes;
}
