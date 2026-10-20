import '../domain/home_summary.dart';
import '../domain/home_summary_repository.dart';

/// Mock implementation of [HomeSummaryRepository].
///
/// Follows AGENTS.md §1 & §6: Pure mock data driving Home display counters.
class MockHomeSummaryRepository implements HomeSummaryRepository {
  MockHomeSummaryRepository({
    HomeSummary? initialSummary,
    this.simulatedDelay = Duration.zero,
  }) : _summary = initialSummary ?? const HomeSummary();

  HomeSummary _summary;
  final Duration simulatedDelay;

  void updateSummary(HomeSummary updated) {
    _summary = updated;
  }

  @override
  Future<HomeSummary> getHomeSummary({required String userId}) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return _summary;
  }
}
