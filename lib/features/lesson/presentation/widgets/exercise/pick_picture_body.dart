import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../domain/exercise.dart';
import 'exercise_prompt.dart';
import 'picture_option_grid.dart';

/// Middle body layout for "Pick the picture" exercises.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// autoplays target word on entry when settings allow, passes callbacks down.
class PickPictureBody extends ConsumerStatefulWidget {
  const PickPictureBody({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.onOptionSelected,
    required this.onHearIt,
    this.isPlayingAudio = false,
  });

  final PickPictureExercise exercise;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onHearIt;
  final bool isPlayingAudio;

  @override
  ConsumerState<PickPictureBody> createState() => _PickPictureBodyState();
}

class _PickPictureBodyState extends ConsumerState<PickPictureBody> {
  @override
  void initState() {
    super.initState();
    _triggerAutoplayIfNeeded();
  }

  @override
  void didUpdateWidget(PickPictureBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exercise.id != oldWidget.exercise.id) {
      _triggerAutoplayIfNeeded();
    }
  }

  void _triggerAutoplayIfNeeded() {
    final autoplay = ref.read(appSettingsProvider).autoplay;
    if (autoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onHearIt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExercisePrompt(
          prompt: widget.exercise.prompt,
          onHearIt: widget.onHearIt,
          isPlayingAudio: widget.isPlayingAudio,
        ),
        PictureOptionGrid(
          options: widget.exercise.options,
          selectedOptionId: widget.selectedOptionId,
          removedOptionIds: widget.removedOptionIds,
          isLocked: widget.isLocked,
          onOptionSelected: widget.onOptionSelected,
        ),
      ],
    );
  }
}

