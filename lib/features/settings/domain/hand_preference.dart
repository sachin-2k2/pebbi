/// Pure Dart domain model representing user hand dexterity preference.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum HandPreference {
  rightHanded,
  leftHanded;

  bool get isLeftHanded => this == HandPreference.leftHanded;
}
