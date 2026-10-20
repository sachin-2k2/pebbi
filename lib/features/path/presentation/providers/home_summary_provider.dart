import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_home_summary_repository.dart';
import '../../domain/home_summary.dart';
import '../../domain/home_summary_repository.dart';

/// Provider for [HomeSummaryRepository].
final homeSummaryRepositoryProvider = Provider<HomeSummaryRepository>((ref) {
  return MockHomeSummaryRepository();
});

/// Provider loading the display summary for the active user.
///
/// Follows AGENTS.md §2.3 & §6: Derived display values are not recomputed in widgets.
final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  final repository = ref.watch(homeSummaryRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  final userId = user?.userId ?? 'guest_default';
  final summary = await repository.getHomeSummary(userId: userId);

  // If user profile is available, align language & premium state
  if (user != null) {
    return HomeSummary(
      language: summary.language,
      languageGlyph: summary.languageGlyph,
      streakCount: summary.streakCount,
      starsCount: summary.starsCount,
      dueCount: summary.dueCount,
      hasAnyPhrases: summary.hasAnyPhrases,
      levelName: summary.levelName,
      levelCaption: summary.levelCaption,
      currentStopId: summary.currentStopId,
      currentStopTitle: summary.currentStopTitle,
      estimatedMinutes: summary.estimatedMinutes,
      isPremium: user.isPremium,
    );
  }

  return summary;
});
