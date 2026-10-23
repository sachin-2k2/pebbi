/// Assistance and scaffolding level for a role-play mission session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum MissionSupport {
  lightHints('light_hints'),
  guided('guided');

  const MissionSupport(this.id);

  /// Stable identifier stored in user settings / profile.
  final String id;

  /// Resolves a [MissionSupport] from a stored ID, safely defaulting to [guided].
  static MissionSupport fromId(String? id) {
    switch (id) {
      case 'light_hints':
        return MissionSupport.lightHints;
      case 'guided':
      default:
        return MissionSupport.guided;
    }
  }

  /// Whether suggested replies are enabled for this support choice.
  bool get hasSuggestedReplies => this == MissionSupport.guided;
}
