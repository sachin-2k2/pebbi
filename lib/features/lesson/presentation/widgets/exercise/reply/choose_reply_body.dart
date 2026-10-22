import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/services/text_to_speech_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../../domain/exercise.dart';
import '../answer_option_list.dart';
import 'reply_prompt_bubble.dart';

/// Body widget for "Choose the reply" exercise (Item 11).
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class ChooseReplyBody extends ConsumerStatefulWidget {
  const ChooseReplyBody({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.onOptionSelected,
  });

  final ChooseReplyExercise exercise;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final ValueChanged<String> onOptionSelected;

  @override
  ConsumerState<ChooseReplyBody> createState() => _ChooseReplyBodyState();
}

class _ChooseReplyBodyState extends ConsumerState<ChooseReplyBody> {
  late final TextToSpeechService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(textToSpeechServiceProvider);
    _triggerAutoplayIfNeeded();
  }

  @override
  void didUpdateWidget(ChooseReplyBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exercise.id != oldWidget.exercise.id) {
      _ttsService.stop();
      _triggerAutoplayIfNeeded();
    }
  }

  void _triggerAutoplayIfNeeded() {
    final autoplay = ref.read(appSettingsProvider).autoplay;
    if (autoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playAudio();
      });
    }
  }

  Future<void> _playAudio() async {
    await _ttsService.speak(
      widget.exercise.audioText,
      locale: widget.exercise.audioLocale,
    );
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.chooseTheReplyTitle,
            style: AppTypography.screenTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ReplyPromptBubble(
            speakerEmoji: widget.exercise.speakerEmoji,
            promptLine: widget.exercise.promptLine,
            onTapToHear: _playAudio,
          ),
          const SizedBox(height: AppSpacing.xl),
          AnswerOptionList(
            options: widget.exercise.options,
            selectedOptionId: widget.selectedOptionId,
            removedOptionIds: widget.removedOptionIds,
            isLocked: widget.isLocked,
            onOptionSelected: widget.onOptionSelected,
          ),
        ],
      ),
    );
  }
}
