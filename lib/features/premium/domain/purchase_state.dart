/// Purchase state machine enum for subscription flows.
///
/// Follows AGENTS.md §2.2: Pure Dart domain logic with zero Flutter imports.
enum PurchaseStatus { idle, loading, success, cancelled, pending, error }

/// Immutable state snapshot of the active purchase attempt.
class PurchaseState {
  const PurchaseState({
    this.status = PurchaseStatus.idle,
    this.activePlanId,
    this.errorMessage,
  });

  final PurchaseStatus status;
  final String? activePlanId;
  final String? errorMessage;

  bool get isLoading => status == PurchaseStatus.loading;
  bool get isSuccess => status == PurchaseStatus.success;
  bool get isError => status == PurchaseStatus.error;
  bool get isCancelled => status == PurchaseStatus.cancelled;
  bool get isPending => status == PurchaseStatus.pending;

  PurchaseState copyWith({
    PurchaseStatus? status,
    String? activePlanId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      activePlanId: activePlanId ?? this.activePlanId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          activePlanId == other.activePlanId &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, activePlanId, errorMessage);
}
