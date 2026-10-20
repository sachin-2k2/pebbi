import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../onboarding/domain/placement_result.dart';
import '../../../onboarding/presentation/providers/onboarding_flow_provider.dart';
import '../../domain/exercise.dart';
import '../providers/exercise_session_notifier.dart';
import '../providers/exercise_session_state.dart';
import '../providers/lesson_providers.dart';
import '../providers/lesson_settings_provider.dart';
import '../widgets/exercise/exercise_bottom_bar.dart';
import '../widgets/exercise/exercise_header.dart';
import '../widgets/exercise/exercise_host.dart';
import '../widgets/exercise/exit_confirm_sheet.dart';
import '../widgets/exercise/feedback_panel.dart';
import '../widgets/exercise/why_sheet.dart';

/// Primary host screen for interactive exercises (placement check & curriculum lessons).
///
/// Follows AGENTS.md §3 & §4: under 120 lines, responsive constraints,
/// autoDispose state machine, handles audio, hints, and feedback sheets.
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({
    super.key,
    this.targetLanguageCode = 'es',
    this.onCompleted,
  });

  final String targetLanguageCode;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(exerciseSessionProvider.notifier)
          .loadPlacement(widget.targetLanguageCode);
    });
  }

  Future<void> _handleExit(BuildContext context) async {
    final leave = await ExitConfirmSheet.show(context);
    if (!leave || !context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-6');
    }
  }

  void _handleContinue(ExerciseSessionNotifier notifier) {
    notifier.next();
    final session = ref.read(exerciseSessionProvider);
    if (session.status == ExerciseStatus.completed) {
      final placementResult = PlacementResult.fromSession(
        exercises: session.mainExercises,
        results: session.results,
      );
      ref
          .read(onboardingFlowProvider.notifier)
          .recordPlacementEvaluation(placementResult);

      widget.onCompleted?.call();
      if (widget.onCompleted == null && mounted) {
        context.go('/onboarding/placement-results');
      }
    }
  }

  Future<void> _handlePlayAudio(Exercise exercise) async {
    setState(() => _isPlayingAudio = true);
    await ref
        .read(textToSpeechServiceProvider)
        .speak(exercise.audioText, locale: exercise.audioLocale);
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseSessionProvider);
    final notifier = ref.read(exerciseSessionProvider.notifier);
    final settings = ref.watch(lessonSettingsProvider);
    final exercise = state.currentExercise;

    if (state.isLoading || exercise == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.brandPurple),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              ExerciseHeader(
                currentNumber: state.displayCurrentNumber,
                totalNumber: state.displayTotalNumber,
                progress: state.progressFraction,
                onClose: () => _handleExit(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ContentWidthLimiter(
                    maxWidth: AppSpacing.maxContentWidthCompact,
                    child: ExerciseHost(
                      exercise: exercise,
                      selectedOptionId: state.selectedOptionId,
                      placedTileIds: state.placedTileIds,
                      removedOptionIds: state.removedOptionIds,
                      isLocked: state.status == ExerciseStatus.checked,
                      isPlayingAudio: _isPlayingAudio,
                      showHelperLine: settings.showHelperLine,
                      onOptionSelected: notifier.selectOption,
                      onPlaceTile: notifier.placeTile,
                      onRemoveTile: notifier.removeTile,
                      onPlayAudio: () => _handlePlayAudio(exercise),
                      onHearIt: () => _handlePlayAudio(exercise),
                    ),
                  ),
                ),
              ),
              if (state.status == ExerciseStatus.checked &&
                  state.feedbackKind != null)
                FeedbackPanel(
                  kind: state.feedbackKind!,
                  exercise: exercise,
                  onContinue: () => _handleContinue(notifier),
                  onWhy: () => WhySheet.show(context, exercise.explanationText),
                )
              else
                ExerciseBottomBar(
                  canCheck: state.canCheck,
                  canUseHint: state.canUseHint,
                  showHint: exercise is! BuildSentenceExercise,
                  onCheck: notifier.checkAnswer,
                  onHint: notifier.useHint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
