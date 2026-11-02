import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/speech_recognizer_service.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../../lesson/presentation/widgets/exercise/speaking/level_dots.dart';
import '../../../../lesson/presentation/widgets/exercise/speaking/mic_button.dart';

/// Voice mode input bar: round [MicButton], audio [LevelDots], and a "Type instead" toggle.
///
/// Follows AGENTS.md §8 & §13: Reuses [MicButton] & [LevelDots], listens locally to
/// audio level stream without rebuilding the parent conversation tree.
class VoiceInputBar extends ConsumerStatefulWidget {
  const VoiceInputBar({
    super.key,
    required this.isListening,
    required this.onMicTap,
    required this.onTypeInsteadTap,
    this.soundLevel,
    this.isEnabled = true,
  });

  final bool isListening;
  final VoidCallback onMicTap;
  final VoidCallback onTypeInsteadTap;
  final double? soundLevel;
  final bool isEnabled;

  @override
  ConsumerState<VoiceInputBar> createState() => _VoiceInputBarState();
}

class _VoiceInputBarState extends ConsumerState<VoiceInputBar> {
  StreamSubscription<double>? _soundSubscription;
  double _localSoundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.isListening) {
      _subscribeSound();
    }
  }

  @override
  void didUpdateWidget(VoiceInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _subscribeSound();
    } else if (!widget.isListening && oldWidget.isListening) {
      _unsubscribeSound();
    }
  }

  void _subscribeSound() {
    _unsubscribeSound();
    final recognizer = ref.read(speechRecognizerServiceProvider);
    _soundSubscription = recognizer.soundLevelStream.listen((lvl) {
      if (mounted) {
        setState(() => _localSoundLevel = lvl);
      }
    });
  }

  void _unsubscribeSound() {
    _soundSubscription?.cancel();
    _soundSubscription = null;
    if (_localSoundLevel != 0.0 && mounted) {
      setState(() => _localSoundLevel = 0.0);
    }
  }

  @override
  void dispose() {
    _soundSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final soundLevel = widget.soundLevel ?? _localSoundLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MicButton(
                isListening: widget.isListening,
                isEnabled: widget.isEnabled,
                onPressed: widget.isEnabled ? widget.onMicTap : () {},
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 140.0,
                child: LevelDots(
                  soundLevel: soundLevel,
                  isListening: widget.isListening,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: widget.onTypeInsteadTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(48.0, 48.0),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text(
              AppStrings.sessionTypeInstead,
              style: AppTypography.caption.copyWith(
                color: palette.brand,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
