import '../../auth/domain/user_profile.dart';

/// Access status evaluation for starting Free Talk.
enum FreeTalkAccess { allowed, needsPremium, limitReached }

/// Pure domain access rules determining whether a user can start Free Talk.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class FreeTalkAccessRules {
  /// Evaluates whether [user] can start a Free Talk session.
  ///
  /// Currently returns [FreeTalkAccess.allowed] for all users.
  /// Free tier may enforce daily conversation quotas in the future.
  /// TODO(question: define free user conversation limits and premium entitlement policies).
  static FreeTalkAccess evaluate(UserProfile? user) {
    return FreeTalkAccess.allowed;
  }
}
