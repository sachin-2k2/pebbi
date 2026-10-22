import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_strings.dart';

/// Round 3D purple microphone button with soft pale circular halo ring.
///
/// Follows AGENTS.md §4.6 & §8: 80dp touch target, accessible live states,
/// respects Reduce Motion accessibility setting.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
    this.isEnabled = true,
  });

  final VoidCallback onPressed;
  final bool isListening;
  final bool isEnabled;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final semanticsLabel = !widget.isEnabled
        ? AppStrings.micDisabledSemantics
        : widget.isListening
            ? AppStrings.micListeningSemantics
            : AppStrings.micReadySemantics;

    final haloColor = isDark
        ? AppColors.brandPurple.withValues(alpha: 0.25)
        : AppColors.brandPurple.withValues(alpha: 0.12);

    final buttonColor = !widget.isEnabled
        ? (isDark ? AppColors.darkBorder : AppColors.borderLight)
        : AppColors.brandPurple;

    return Semantics(
      button: true,
      enabled: widget.isEnabled,
      label: semanticsLabel,
      child: Center(
        child: SizedBox(
          width: 110.0,
          height: 110.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pale halo ring
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final scale = (widget.isListening && !reduceMotion)
                      ? _scaleAnimation.value
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 104.0,
                      height: 104.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: haloColor,
                      ),
                    ),
                  );
                },
              ),
              // Main 3D circular button
              Material(
                color: buttonColor,
                shape: const CircleBorder(),
                elevation: widget.isEnabled ? 4.0 : 0.0,
                shadowColor: AppColors.brandPurpleDepth.withValues(alpha: 0.4),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.isEnabled ? widget.onPressed : null,
                  child: Container(
                    width: 78.0,
                    height: 78.0,
                    alignment: Alignment.center,
                    child: Icon(
                      widget.isListening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      size: 38.0,
                      color: widget.isEnabled
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
