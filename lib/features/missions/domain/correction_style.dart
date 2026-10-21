/// Correction style preference for AI role-play and Free Talk conversations.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum CorrectionStyle {
  gentle('gentle'),
  live('live'),
  none('none');

  const CorrectionStyle(this.id);

  /// Stable identifier stored in user settings / profile.
  final String id;

  /// Resolves a [CorrectionStyle] from a stored ID, safely defaulting to [gentle].
  static CorrectionStyle fromId(String? id) {
    switch (id) {
      case 'live':
        return CorrectionStyle.live;
      case 'none':
        return CorrectionStyle.none;
      case 'gentle':
      default:
        return CorrectionStyle.gentle;
    }
  }
}
