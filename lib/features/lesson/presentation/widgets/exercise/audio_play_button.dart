import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';

/// Large round 3D purple audio button with speaker icon and playing state animation.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// clamped responsive size (72-88dp), respects Reduce motion.
class AudioPlayButton extends StatefulWidget {
  const AudioPlayButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
  });

  final VoidCallback onPressed;
  final bool isPlaying;

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AudioPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final size = (MediaQuery.sizeOf(context).width * 0.2).clamp(72.0, 88.0);

    return Semantics(
      button: true,
      label: widget.isPlaying ? AppStrings.playingAudio : AppStrings.playAudio,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = (!disableAnimations && widget.isPlaying)
              ? _scaleAnimation.value
              : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: Button3D.circular(
          label: '',
          size: size,
          depth: AppSpacing.depthMd,
          backgroundColor: AppColors.brandPurple,
          depthColor: AppColors.brandPurpleDepth,
          onPressed: widget.onPressed,
          icon: Icon(
            widget.isPlaying
                ? Icons.volume_up_rounded
                : Icons.volume_up_outlined,
            size: size * 0.45,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
