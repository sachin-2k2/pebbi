import '../domain/practice_summary.dart';

/// Fake repository supplying practice summary counts and practice session readiness.
///
/// Follows AGENTS.md §1 (fake repo with realistic data) and §2.
class MockPracticeRepository {
  MockPracticeRepository({PracticeSummary? initialSummary})
    : _summary = initialSummary ?? const PracticeSummary();

  PracticeSummary _summary;

  Future<PracticeSummary> getPracticeSummary() async {
    return _summary;
  }

  void updateSummary(PracticeSummary newSummary) {
    _summary = newSummary;
  }
}
