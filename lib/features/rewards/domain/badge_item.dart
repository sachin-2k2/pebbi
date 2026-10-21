import 'badge_status.dart';

/// Represents an achievement badge on the Rewards screen.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
class BadgeItem {
  const BadgeItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.howToEarn,
    required this.status,
    this.earnedAt,
    this.currentProgress,
    this.targetProgress,
  });

  final String id;
  final String emoji;
  final String name;
  final String howToEarn;
  final BadgeStatus status;
  final DateTime? earnedAt;
  final int? currentProgress;
  final int? targetProgress;

  /// Progress bar appears only when a target exists and the badge is not yet earned.
  bool get hasProgressBar =>
      targetProgress != null &&
      targetProgress! > 0 &&
      status != BadgeStatus.earned;

  double get progressRatio {
    if (!hasProgressBar) return 0.0;
    final cur = currentProgress ?? 0;
    final tar = targetProgress!;
    return (cur / tar).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          name == other.name &&
          howToEarn == other.howToEarn &&
          status == other.status &&
          earnedAt == other.earnedAt &&
          currentProgress == other.currentProgress &&
          targetProgress == other.targetProgress;

  @override
  int get hashCode =>
      id.hashCode ^
      emoji.hashCode ^
      name.hashCode ^
      howToEarn.hashCode ^
      status.hashCode ^
      earnedAt.hashCode ^
      currentProgress.hashCode ^
      targetProgress.hashCode;
}
