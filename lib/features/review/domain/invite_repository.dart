import 'invite_link.dart';

/// Repository interface for fetching user-specific invite/referral links.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class InviteRepository {
  /// Fetches the invite link for [userId].
  Future<InviteLink> getInviteLink({required String userId});
}
