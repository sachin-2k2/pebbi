import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/exercise.dart';
import '../providers/exercise_session_notifier.dart';
import '../providers/lesson_providers.dart';
import '../providers/lesson_settings_provider.dart';
import '../widgets/exercise/exercise_footer.dart';
import '../widgets/exercise/exercise_header.dart';
import '../widgets/exercise/exercise_scroll_area.dart';
import 'exercise_screen_navigation.dart';

/// Primary host screen for interactive exercises (placement check & curriculum lessons).
///
/// Follows AGENTS.md §3 & §4: under 130 lines, build under 45 lines, responsive constraints,
/// autoDispose state machine, handles audio, hints, and feedback sheets.
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({
    super.key,
    this.targetLanguageCode = 'es',
    this.stopId,
    this.finishRoute,
    this.onCompleted,
  });

  final String targetLanguageCode;
  final String? stopId;
  final String? finishRoute;
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
      final notifier = ref.read(exerciseSessionProvider.notifier);
      if (widget.stopId != null) {
        notifier.loadLesson(widget.stopId!);
      } else {
        notifier.loadPlacement(widget.targetLanguageCode);
      }
    });
  }

  void _checkCompleted() => ExerciseScreenNavigation.handleCompleted(
    context,
    ref,
    stopId: widget.stopId,
    finishRoute: widget.finishRoute,
    onCompleted: widget.onCompleted,
  );

  void _handleContinue(ExerciseSessionNotifier n) {
    n.next();
    _checkCompleted();
  }

  void _handleGotIt(ExerciseSessionNotifier n) {
    n.onGotIt();
    _checkCompleted();
  }

  void _handleExit() =>
      ExerciseScreenNavigation.handleExit(context, stopId: widget.stopId);

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
        if (!didPop) _handleExit();
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
                onClose: _handleExit,
              ),
              ExerciseScrollArea(
                exercise: exercise,
                state: state,
                notifier: notifier,
                isPlayingAudio: _isPlayingAudio,
                showHelperLine: settings.showHelperLine,
                onPlayAudio: () => _handlePlayAudio(exercise),
                onSpeakingContinue: () => _handleGotIt(notifier),
              ),
              ExerciseFooter(
                status: state.status,
                feedbackKind: state.feedbackKind,
                exercise: exercise,
                currentStreak: state.currentStreak,
                bottomBarMode: state.bottomBarMode,
                canCheck: state.canCheck,
                canUseHint: state.canUseHint,
                onContinue: () => _handleContinue(notifier),
                onCheck: notifier.checkAnswer,
                onHint: notifier.useHint,
                onGotIt: () => _handleGotIt(notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
