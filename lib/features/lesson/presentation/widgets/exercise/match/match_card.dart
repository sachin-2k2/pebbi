import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Single selectable card in Match the Pairs supporting idle, selected, matched, and soft shake.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines, 48dp minimum tap target.
/// Visual states estimated with design tokens. TODO(question): Confirm exact states with design team.
class MatchCard extends StatefulWidget {
  const MatchCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.isShaking,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool isShaking;
  final VoidCallback onTap;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(MatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      if (!MediaQuery.disableAnimationsOf(context)) {
        _shakeController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = widget.isMatched
        ? const Color(0xFFE8FAF3)
        : widget.isSelected
        ? const Color(0xFFEDE9FE)
        : isDark
        ? AppColors.darkSurface
        : AppColors.surface;

    final borderColor = widget.isMatched
        ? const Color(0xFF1AD199)
        : widget.isSelected
        ? AppColors.brandPurple
        : isDark
        ? AppColors.darkBorder
        : const Color(0xFFE5DEFF);

    final semanticLabel = widget.isMatched
        ? '${widget.text}, matched'
        : widget.isSelected
        ? AppStrings.matchPairsCardSelected(widget.text)
        : widget.text;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0.0),
          child: child,
        );
      },
      child: Semantics(
        button: !widget.isMatched,
        label: semanticLabel,
        child: Opacity(
          opacity: widget.isMatched ? 0.75 : 1.0,
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: InkWell(
              onTap: widget.isMatched ? null : widget.onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: Container(
                constraints: const BoxConstraints(minHeight: 64.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: borderColor,
                    width: widget.isSelected ? 2.0 : 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.text,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (widget.isMatched) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18.0,
                        color: Color(0xFF1AD199),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
