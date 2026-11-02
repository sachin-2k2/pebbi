import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/services/wakelock_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/emergency_phrase.dart';
import 'show_screen_controls.dart';
import 'show_screen_disclaimer.dart';
import 'show_screen_pager_card.dart';
import 'show_screen_top_bar.dart';

/// Full-screen "Show Your Screen" view designed for arm's length visibility in urgent moments.
///
/// Follows AGENTS.md §3 (<150 lines), §4.1 (responsive, max width 640), and §5.1 (offline-first).
class ShowScreenView extends ConsumerStatefulWidget {
  const ShowScreenView({
    super.key,
    this.phrase,
    this.phrases,
    this.initialIndex = 0,
    required this.explanationLanguageCode,
    required this.targetLanguageCode,
    this.targetLanguageName = 'Spanish',
    this.showHelperLine = false,
    this.disclaimer,
  }) : assert(phrase != null || (phrases != null && phrases.length > 0));

  final EmergencyPhrase? phrase;
  final List<EmergencyPhrase>? phrases;
  final int initialIndex;
  final String explanationLanguageCode;
  final String targetLanguageCode;
  final String targetLanguageName;
  final bool showHelperLine;
  final String? disclaimer;

  @override
  ConsumerState<ShowScreenView> createState() => _ShowScreenViewState();
}

class _ShowScreenViewState extends ConsumerState<ShowScreenView> {
  late final AppLifecycleListener _listener;
  late final WakelockController _wakelock;
  late final TextToSpeechService _tts;
  late final PageController _pageController;
  late int _currentIndex;
  bool _isPlaying = false;
  String? _ttsNotice;

  List<EmergencyPhrase> get _phrases =>
      widget.phrases ?? (widget.phrase != null ? [widget.phrase!] : const []);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, (_phrases.length - 1).clamp(0, 99));
    _pageController = PageController(initialPage: _currentIndex);
    _wakelock = ref.read(wakelockControllerProvider)..enable();
    _tts = ref.read(textToSpeechServiceProvider);
    _listener = AppLifecycleListener(
      onPause: _wakelock.disable,
      onResume: _wakelock.enable,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listener.dispose();
    _wakelock.disable();
    _tts.stop();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying || _phrases.isEmpty) return;
    setState(() {
      _isPlaying = true;
      _ttsNotice = null;
    });
    final ok = await _tts.speak(_phrases[_currentIndex].targetText, locale: widget.targetLanguageCode);
    if (mounted) {
      setState(() {
        _isPlaying = false;
        if (!ok) _ttsNotice = AppStrings.emergencyOfflineVoiceUnavailable;
      });
    }
  }

  void _goTo(int idx) {
    if (idx >= 0 && idx < _phrases.length) {
      _pageController.animateToPage(idx, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrases = _phrases;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disclaimer = widget.disclaimer ?? AppStrings.emergencyNoteMessage(widget.targetLanguageName);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 640,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              children: [
                ShowScreenTopBar(currentIndex: _currentIndex, total: phrases.length),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: phrases.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (_, i) => ShowScreenPagerCard(
                      phrase: phrases[i],
                      explanationLanguageCode: widget.explanationLanguageCode,
                      targetLanguageCode: widget.targetLanguageCode,
                      showHelperLine: widget.showHelperLine,
                    ),
                  ),
                ),
                ShowScreenControls(
                  onPrev: () => _goTo(_currentIndex - 1),
                  onNext: () => _goTo(_currentIndex + 1),
                  onPlay: _playAudio,
                  hasPrev: _currentIndex > 0,
                  hasNext: _currentIndex < phrases.length - 1,
                  isPlaying: _isPlaying,
                ),
                const SizedBox(height: AppSpacing.md),
                ShowScreenDisclaimer(disclaimerText: disclaimer, ttsNotice: _ttsNotice),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
