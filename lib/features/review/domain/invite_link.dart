/// Domain model representing a referral or invite URL.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class InviteLink {
  const InviteLink({required this.url, required this.shareText, this.code});

  final String url;
  final String shareText;
  final String? code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InviteLink &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          shareText == other.shareText &&
          code == other.code;

  @override
  int get hashCode => Object.hash(url, shareText, code);
}
