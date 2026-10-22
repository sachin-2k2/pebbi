import 'package:flutter/material.dart';
import '../../../domain/exercise.dart';
import '../../providers/exercise_session_state.dart';
import 'exercise_bottom_bar.dart';
import 'feedback_panel.dart';
import 'why_sheet.dart';

/// Dynamic footer area alternating between [FeedbackPanel] and [ExerciseBottomBar].
///
/// Follows AGENTS.md §3 & §4: under 80 lines, build under 50 lines.
class ExerciseFooter extends StatelessWidget {
  const ExerciseFooter({
    super.key,
    required this.status,
    required this.feedbackKind,
    required this.exercise,
    required this.currentStreak,
    required this.bottomBarMode,
    required this.canCheck,
    required this.canUseHint,
    required this.onContinue,
    required this.onCheck,
    required this.onHint,
    required this.onGotIt,
  });

  final ExerciseStatus status;
  final FeedbackKind? feedbackKind;
  final Exercise exercise;
  final int currentStreak;
  final BottomBarMode bottomBarMode;
  final bool canCheck;
  final bool canUseHint;
  final VoidCallback onContinue;
  final VoidCallback onCheck;
  final VoidCallback onHint;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    if (status == ExerciseStatus.checked && feedbackKind != null) {
      return FeedbackPanel(
        kind: feedbackKind!,
        exercise: exercise,
        currentStreak: currentStreak,
        onContinue: onContinue,
        onWhy: () => WhySheet.show(context, exercise.explanationText),
      );
    }

    return ExerciseBottomBar(
      mode: bottomBarMode,
      canCheck: canCheck,
      canUseHint: canUseHint,
      showHint: exercise is! BuildSentenceExercise,
      onCheck: onCheck,
      onHint: onHint,
      onGotIt: onGotIt,
    );
  }
}
