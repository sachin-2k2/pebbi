import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// State notifier tracking whether the device is considered offline.
///
/// Follows Rules 3 & 4:
/// - Listens to [Connectivity] but does not trust it blindly:
///   real network failure (timeouts/connection errors) also marks offline.
/// - Does NOT treat HTTP 5xx server errors as offline.
/// - Announces once to screen readers when entering offline state.
class NetworkStatusNotifier extends StateNotifier<bool> {
  NetworkStatusNotifier({Connectivity? connectivity, bool initialOffline = false})
      : _connectivity = connectivity ?? Connectivity(),
        super(initialOffline) {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateFromResults);
  }

  void _updateFromResults(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );
    final isOffline = !hasConnection;
    setOffline(isOffline);
  }

  /// Sets the offline status explicitly.
  void setOffline(bool isOffline) {
    if (state == isOffline) return;

    state = isOffline;
    if (isOffline) {
      _announceOfflineOnce();
    }
  }

  /// Called when an HTTP network attempt fails with a connection or timeout error.
  /// (Server errors 5xx MUST NOT call this method, per Rule 4).
  void reportNetworkFailure() {
    setOffline(true);
  }

  /// Called when an HTTP call succeeds.
  void reportNetworkSuccess() {
    setOffline(false);
  }

  void _announceOfflineOnce() {
    try {
      final binding = WidgetsBinding.instance;
      final view = binding.platformDispatcher.views.firstOrNull;
      if (view != null) {
        SemanticsService.sendAnnouncement(
          view,
          "You're offline. Some features need internet.",
          TextDirection.ltr,
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    if (mounted) {
      super.dispose();
    }
  }
}

/// Provider for network offline status.
final isOfflineProvider = StateNotifierProvider<NetworkStatusNotifier, bool>((ref) {
  return NetworkStatusNotifier();
});

/// Calm, non-blocking offline notice strip conforming to Rule 3.
/// Docked directly at the bottom with theme-aware styling and safe-area support.
class OfflineNoticeBanner extends StatelessWidget {
  const OfflineNoticeBanner({super.key});

  static const String offlineMessage = "You're offline. Some features need internet.";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF261D11) : const Color(0xFFFEF3C7);
    final borderColor = isDark ? const Color(0xFF452B0E) : const Color(0xFFFDE68A);
    final textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
    final iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: iconColor,
                size: 16.0,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  offlineMessage,
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
