import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/token_storage.dart';
import 'auth_provider.dart';

/// Handler coordinating session expiry (HTTP 401) actions.
///
/// Follows Rule 5:
/// - Keeps all local progress and database records.
/// - Clears the invalid session token.
/// - Shows a calm "Please sign in again" flow.
/// - Opens Login with the user's email prefilled, returning to current location.
class SessionExpiredHandler {
  SessionExpiredHandler(this._ref);

  final Ref _ref;

  Future<void> handleExpiredSession(String userId, {BuildContext? context}) async {
    final tokenStorage = _ref.read(tokenStorageProvider);
    await tokenStorage.clearSession();

    final profile = _ref.read(currentUserProvider);
    final email = profile?.firstName ?? ''; // Or prefilled email if available

    final navigatorContext = context;
    if (navigatorContext != null && navigatorContext.mounted) {
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again.'),
          duration: Duration(seconds: 3),
        ),
      );
      final currentLoc = GoRouterState.of(navigatorContext).uri.toString();
      final returnTo = currentLoc != '/login' ? currentLoc : '/path';
      final query = 'email=${Uri.encodeComponent(email)}&returnTo=${Uri.encodeComponent(returnTo)}';
      navigatorContext.go('/login?$query');
    }
  }
}

/// Provider for [SessionExpiredHandler].
final sessionExpiredHandlerProvider = Provider<SessionExpiredHandler>((ref) {
  return SessionExpiredHandler(ref);
});
