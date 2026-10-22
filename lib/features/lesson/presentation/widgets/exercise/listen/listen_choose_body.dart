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
import '../audio_play_button.dart';
import 'cant_listen_link.dart';

/// Body widget for "Tap what you hear" exercise (Item 9).
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class ListenChooseBody extends ConsumerStatefulWidget {
  const ListenChooseBody({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.onOptionSelected,
    required this.onCantListen,
  });

  final ListenChooseExercise exercise;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onCantListen;

  @override
  ConsumerState<ListenChooseBody> createState() => _ListenChooseBodyState();
}

class _ListenChooseBodyState extends ConsumerState<ListenChooseBody> {
  bool _isPlaying = false;
  late final TextToSpeechService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(textToSpeechServiceProvider);
    _triggerAutoplayIfNeeded();
  }

  @override
  void didUpdateWidget(ListenChooseBody oldWidget) {
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
    setState(() => _isPlaying = true);
    await _ttsService.speak(
      widget.exercise.audioText,
      locale: widget.exercise.audioLocale,
    );
    if (mounted) setState(() => _isPlaying = false);
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
            AppStrings.tapWhatYouHearTitle,
            style: AppTypography.screenTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: AudioPlayButton(
              isPlaying: _isPlaying,
              onPressed: _playAudio,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AnswerOptionList(
            options: widget.exercise.options,
            selectedOptionId: widget.selectedOptionId,
            removedOptionIds: widget.removedOptionIds,
            isLocked: widget.isLocked,
            onOptionSelected: widget.onOptionSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          CantListenLink(onTap: widget.onCantListen),
        ],
      ),
    );
  }
}
