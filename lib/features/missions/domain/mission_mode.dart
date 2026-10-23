/// Role-play interaction mode (Chat text vs Voice speech).
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum MissionMode {
  chat('chat'),
  voice('voice');

  const MissionMode(this.id);

  /// Stable identifier stored in user settings / profile.
  final String id;

  /// Resolves a [MissionMode] from a stored ID, safely defaulting to [chat].
  static MissionMode fromId(String? id) {
    switch (id) {
      case 'voice':
        return MissionMode.voice;
      case 'chat':
      default:
        return MissionMode.chat;
    }
  }
}
