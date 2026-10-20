/// Represents an option in a picture-based exercise.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class PictureOption {
  const PictureOption({
    required this.id,
    required this.imageRef,
    required this.spokenLabel,
  });

  /// Unique identifier of this option within the exercise (e.g. 'opt_ticket').
  final String id;

  /// Visual representation (emoji character or image key, e.g. '🎫').
  final String imageRef;

  /// Accessible spoken label (e.g. 'ticket', 'crescent moon').
  final String spokenLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PictureOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imageRef == other.imageRef &&
          spokenLabel == other.spokenLabel;

  @override
  int get hashCode => Object.hash(id, imageRef, spokenLabel);
}
