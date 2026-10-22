import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/services/text_to_speech_service.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../../domain/audio_playback_rates.dart';
import '../../../../domain/exercise.dart';
import '../../../../domain/phrase_token.dart';
import 'new_phrase_card_body_content.dart';

/// Body widget presenting a "New phrase" teach card (Items 1-4).
///
/// Follows AGENTS.md §3 & §4: under 120 lines, handles autoplay lifecycle.
class NewPhraseCardBody extends ConsumerStatefulWidget {
  const NewPhraseCardBody({
    super.key,
    required this.exercise,
    required this.savedTokenIds,
    required this.onTokenTap,
  });

  final NewPhraseCardExercise exercise;
  final Set<String> savedTokenIds;
  final ValueChanged<PhraseToken> onTokenTap;

  @override
  ConsumerState<NewPhraseCardBody> createState() => _NewPhraseCardBodyState();
}

class _NewPhraseCardBodyState extends ConsumerState<NewPhraseCardBody> {
  bool _isPlaying = false;
  late final TextToSpeechService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(textToSpeechServiceProvider);
    _triggerAutoplayIfNeeded();
  }

  @override
  void didUpdateWidget(NewPhraseCardBody oldWidget) {
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
        if (mounted) _playAudio(AudioPlaybackRates.normal);
      });
    }
  }

  Future<void> _playAudio(double rate) async {
    setState(() => _isPlaying = true);
    await _ttsService.speak(
      widget.exercise.audioText,
      locale: widget.exercise.audioLocale,
      speechRate: rate,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: NewPhraseCardBodyContent(
        exercise: widget.exercise,
        savedTokenIds: widget.savedTokenIds,
        isPlaying: _isPlaying,
        onTokenTap: widget.onTokenTap,
        onNormal: () => _playAudio(AudioPlaybackRates.normal),
        onSlow: () => _playAudio(widget.exercise.slowAudioRate),
      ),
    );
  }
}
