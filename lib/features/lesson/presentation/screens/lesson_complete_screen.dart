import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/star_row.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../path/presentation/providers/home_summary_provider.dart';
import '../../../path/presentation/providers/path_provider.dart';
import '../../../rewards/domain/rewards_safety_rules.dart';
import '../../domain/lesson_completion.dart';
import '../providers/lesson_completion_provider.dart';
import '../widgets/finish/complete_hero.dart';
import '../widgets/finish/completion_bottom_bar.dart';
import '../widgets/finish/completion_stat_row.dart';
import '../widgets/finish/first_try_line.dart';
import '../widgets/finish/learned_phrases_card.dart';

/// Screen celebrating lesson completion.
///
/// Follows AGENTS.md §3: under 150 lines, build under 50 lines,
/// thin composition delegating all UI pieces to dedicated widgets.
class LessonCompleteScreen extends ConsumerStatefulWidget {
  const LessonCompleteScreen({
    super.key,
    required this.stopId,
  });

  final String stopId;

  @override
  ConsumerState<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends ConsumerState<LessonCompleteScreen> {
  bool _hasCelebrated = false;

  void _celebrateOnce(LessonCompletion completion) {
    if (_hasCelebrated) return;
    _hasCelebrated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(audioFeedbackServiceProvider).playSuccess();
      SemanticsService.sendAnnouncement(
        View.of(context),
        AppStrings.lessonCompleteAnnouncement(
          stars: completion.starsEarned,
          correct: completion.firstTryCorrectCount,
          total: completion.scoredCount,
        ),
        TextDirection.ltr,
      );
    });
  }

  void _onContinue(BuildContext context) {
    // Invalidate path providers so completed stop and stars reflect immediately
    ref.invalidate(unitsProvider);
    ref.invalidate(homeSummaryProvider);

    // TODO(question: Should guest sign-in prompt trigger here after the first completed lesson, or on the Path screen?)

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/path');
    }
  }

  @override
  Widget build(BuildContext context) {
    final completionAsync = ref.watch(lessonCompletionProvider(widget.stopId));
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onContinue(context);
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: completionAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (completion) {
              _celebrateOnce(completion);
              return ContentWidthLimiter(
                maxWidth: 580.0,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          children: [
                            CompleteHero(starsEarned: completion.starsEarned),
                            const SizedBox(height: AppSpacing.sm),
                            StarRow(
                              starsEarned: completion.starsEarned,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FirstTryLine(
                              correctCount: completion.firstTryCorrectCount,
                              scoredCount: completion.scoredCount,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            LearnedPhrasesCard(
                              phrases: completion.learnedPhrases,
                              onPlayPhrase: (phrase) => ref
                                  .read(textToSpeechServiceProvider)
                                  .speak(
                                    phrase.audioText,
                                    locale: phrase.audioLocale,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CompletionStatRow(
                              streakDays: completion.streakDays,
                              dailyGoal: completion.dailyGoal,
                              showStreak:
                                  RewardsSafetyRules.shouldShowRewardsPressureElements(
                                user?.ageBand,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                    CompletionBottomBar(onContinue: () => _onContinue(context)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
