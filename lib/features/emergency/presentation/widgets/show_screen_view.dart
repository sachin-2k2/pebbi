import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/services/wakelock_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/lesson/presentation/widgets/exercise/audio_play_button.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/emergency_phrase.dart';
import 'phrase_display_text.dart';
import 'show_screen_close_button.dart';

/// Full-screen "Show Your Screen" view designed for arm's length visibility in urgent moments.
///
/// Follows AGENTS.md §3 (under 150 lines, build under 50 lines), §4.1 (responsive, max width 640),
/// and §5.1 (offline-first):
/// - Keeps device awake while open via [WakelockController].
/// - Releases wakelock immediately when dismissed, popped, or backgrounded.
/// - Big play button plays target audio or shows offline voice guidance if missing.
class ShowScreenView extends ConsumerStatefulWidget {
  const ShowScreenView({
    super.key,
    required this.phrase,
    required this.explanationLanguageCode,
    required this.targetLanguageCode,
    this.showHelperLine = false,
  });

  final EmergencyPhrase phrase;
  final String explanationLanguageCode;
  final String targetLanguageCode;
  final bool showHelperLine;

  @override
  ConsumerState<ShowScreenView> createState() => _ShowScreenViewState();
}

class _ShowScreenViewState extends ConsumerState<ShowScreenView> {
  late final AppLifecycleListener _lifecycleListener;
  late final WakelockController _wakelock;
  late final TextToSpeechService _tts;
  bool _isPlaying = false;
  String? _ttsNotice;

  @override
  void initState() {
    super.initState();
    _wakelock = ref.read(wakelockControllerProvider);
    _tts = ref.read(textToSpeechServiceProvider);
    _wakelock.enable();
    _lifecycleListener = AppLifecycleListener(
      onPause: () => _wakelock.disable(),
      onResume: () => _wakelock.enable(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _wakelock.disable();
    _tts.stop();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _ttsNotice = null;
    });

    final success = await _tts.speak(
      widget.phrase.targetText,
      locale: widget.targetLanguageCode,
    );

    if (mounted) {
      setState(() {
        _isPlaying = false;
        if (!success) {
          _ttsNotice = AppStrings.emergencyOfflineVoiceUnavailable;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meaning = widget.phrase.getLabel(widget.explanationLanguageCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 640,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: ShowScreenCloseButton(),
                ),
                const Spacer(flex: 2),
                Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.emergencyLabelRed,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PhraseDisplayText(
                  phrase: widget.phrase,
                  targetLanguageCode: widget.targetLanguageCode,
                  showHelperLine: widget.showHelperLine,
                ),
                const Spacer(flex: 2),
                AudioPlayButton(isPlaying: _isPlaying, onPressed: _playAudio),
                const SizedBox(height: AppSpacing.md),
                if (_ttsNotice != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _ttsNotice!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.emergencyLabelRed,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
