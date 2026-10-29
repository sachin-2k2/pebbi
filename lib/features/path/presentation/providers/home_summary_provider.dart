import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/data/mock_learnable_language_repository.dart';
import '../../data/mock_home_summary_repository.dart';
import '../../domain/home_summary.dart';
import '../../domain/home_summary_repository.dart';
import '../widgets/language_pill.dart';

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

  // If user profile is available, align language, glyph, level & premium state
  if (user != null) {
    final targetCode = user.targetLanguageCode;
    const langRepo = MockLearnableLanguageRepository();
    final matched = langRepo
        .getLearnableLanguages()
        .where((l) => l.code == targetCode)
        .firstOrNull;

    final langName = matched?.englishName ??
        matched?.nativeName ??
        (targetCode == 'ml'
            ? 'Malayalam'
            : (targetCode == 'en' ? 'English' : summary.language));
    final langGlyph = matched?.glyph ?? LanguagePill.glyphFor(langName);

    final level = user.selectedLevel;
    final levelName = level != null ? '${level.label} mode' : summary.levelName;

    return HomeSummary(
      language: langName,
      languageGlyph: langGlyph,
      streakCount: summary.streakCount,
      starsCount: summary.starsCount,
      dueCount: summary.dueCount,
      hasAnyPhrases: summary.hasAnyPhrases,
      levelName: levelName,
      levelCaption: summary.levelCaption,
      currentStopId: summary.currentStopId,
      currentStopTitle: summary.currentStopTitle,
      estimatedMinutes: summary.estimatedMinutes,
      isPremium: user.isPremium,
    );
  }

  return summary;
});
