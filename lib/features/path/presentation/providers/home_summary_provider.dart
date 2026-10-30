import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/data/mock_learnable_language_repository.dart';
import '../../data/mock_home_summary_repository.dart';
import '../../domain/home_summary.dart';
import '../../domain/home_summary_repository.dart';
import '../../domain/path_node.dart';
import '../widgets/language_pill.dart';
import 'path_provider.dart';
import 'track_stats_provider.dart';

/// Provider for [HomeSummaryRepository].
final homeSummaryRepositoryProvider = Provider<HomeSummaryRepository>((ref) {
  return MockHomeSummaryRepository();
});

/// Provider loading the display summary for the active user.
///
/// Follows AGENTS.md §2.3 & §6: Derived display values are not recomputed in widgets.
final homeSummaryProvider =
    AsyncNotifierProvider<HomeSummaryNotifier, HomeSummary>(
      HomeSummaryNotifier.new,
    );

class HomeSummaryNotifier extends AsyncNotifier<HomeSummary> {
  @override
  Future<HomeSummary> build() async {
    final repository = ref.watch(homeSummaryRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    final trackStats = ref.watch(trackStatsProvider);
    final activeNode = ref.watch(activePathNodeProvider);
    return _computeSummary(repository, user, trackStats, activeNode);
  }

  Future<void> reloadSilently() async {
    state = const AsyncLoading<HomeSummary>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repository = ref.read(homeSummaryRepositoryProvider);
      final user = ref.read(currentUserProvider);
      final trackStats = ref.read(trackStatsProvider);
      final activeNode = ref.read(activePathNodeProvider);
      return _computeSummary(repository, user, trackStats, activeNode);
    });
  }

  static Future<HomeSummary> _computeSummary(
    HomeSummaryRepository repository,
    dynamic user,
    TrackStats trackStats,
    PathNode? activeNode,
  ) async {
    final userId = user?.userId ?? 'guest_default';
    final summary = await repository.getHomeSummary(userId: userId);

    final effectiveStreak = trackStats.streak > 0
        ? trackStats.streak
        : ((user?.currentStreak ?? 0) > 0
              ? user!.currentStreak
              : summary.streakCount);

    final effectiveStars = trackStats.stars > 0
        ? trackStats.stars
        : ((user?.totalStars ?? 0) > 0 ? user!.totalStars : summary.starsCount);

    final stopId = activeNode?.id ?? summary.currentStopId;
    final stopTitle = activeNode?.title ?? summary.currentStopTitle;

    if (user != null) {
      final targetCode = user.targetLanguageCode;
      const langRepo = MockLearnableLanguageRepository();
      final matched = langRepo
          .getLearnableLanguages()
          .where((l) => l.code == targetCode)
          .firstOrNull;

      final langName =
          matched?.englishName ??
          matched?.nativeName ??
          (targetCode == 'ml'
              ? 'Malayalam'
              : (targetCode == 'en' ? 'English' : summary.language));
      final langGlyph = matched?.glyph ?? LanguagePill.glyphFor(langName);

      final level = user.selectedLevel;
      final levelName =
          level != null ? '${level.label} mode' : summary.levelName;

      return HomeSummary(
        language: langName,
        languageGlyph: langGlyph,
        streakCount: effectiveStreak,
        starsCount: effectiveStars,
        dueCount: summary.dueCount,
        hasAnyPhrases: summary.hasAnyPhrases,
        levelName: levelName,
        levelCaption: summary.levelCaption,
        currentStopId: stopId,
        currentStopTitle: stopTitle,
        estimatedMinutes: summary.estimatedMinutes,
        isPremium: user.isPremium,
      );
    }

    return HomeSummary(
      language: summary.language,
      languageGlyph: summary.languageGlyph,
      streakCount: effectiveStreak,
      starsCount: effectiveStars,
      dueCount: summary.dueCount,
      hasAnyPhrases: summary.hasAnyPhrases,
      levelName: summary.levelName,
      levelCaption: summary.levelCaption,
      currentStopId: stopId,
      currentStopTitle: stopTitle,
      estimatedMinutes: summary.estimatedMinutes,
      isPremium: summary.isPremium,
    );
  }
}
