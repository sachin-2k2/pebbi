import 'auth_result.dart';
import 'auth_session.dart';

/// Repository interface managing authentication and guest-to-user session migration.
///
/// Follows AGENTS.md §2.2 & §6: Pure Dart interface with zero Flutter imports.
abstract interface class AuthRepository {
  /// Authenticates using email and password.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new user account using email and password.
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
  });

  /// Initiates a password reset flow for the specified [email].
  ///
  /// Security Rule: Returns success regardless of whether the email is registered
  /// to protect against account enumeration attacks.
  Future<AuthResult> requestPasswordReset({required String email});

  /// Authenticates via Google Sign-In.
  ///
  /// TODO(question): Apple App Store Review Guideline 4.8 requires "Sign in with Apple"
  /// if third-party OAuth (like Google) is offered. The design shows only Google.
  Future<AuthResult> signInWithGoogle();

  /// Ends the current user session and clears stored credentials.
  Future<void> signOut();

  /// Loads the currently active authenticated session, if any.
  Future<AuthSession?> getCurrentSession();

  /// Merges a guest's learning progress into an authenticated user account.
  ///
  /// Rule: If the target account is empty/new, guest progress is transferred.
  /// If the target account already has progress, both are kept safely without collision.
  /// TODO(question): Backend team will provide the authoritative merge/conflict rules.
  Future<void> mergeGuestProgress({
    required String guestId,
    required String userId,
  });
}
