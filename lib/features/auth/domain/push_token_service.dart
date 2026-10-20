/// Service interface for registering and unregistering push notification device tokens.
///
/// Follows AGENTS.md §2 & §6: Isolated behind interface without third-party package dependencies.
abstract interface class PushTokenService {
  /// Registers the device push notification token with the backend for [userId].
  Future<void> registerToken(String userId);

  /// Unregisters the device push notification token with the backend on logout.
  Future<void> unregisterToken(String userId);
}
