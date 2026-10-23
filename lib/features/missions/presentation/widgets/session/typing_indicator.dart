import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';

/// Three animated pulsing dots representing character typing activity.
///
/// Follows AGENTS.md §8:
/// - Static dots when Reduce Motion is enabled
/// - Live region screen-reader announcement: "[characterName] is typing"
class TypingIndicator extends ConsumerStatefulWidget {
  const TypingIndicator({super.key, required this.characterName});

  final String characterName;

  @override
  ConsumerState<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends ConsumerState<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduceMotion = ref.watch(
      appSettingsProvider.select((s) => s.reduceMotion),
    );

    return Semantics(
      liveRegion: true,
      label: AppStrings.sessionCharacterTyping(widget.characterName),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: palette.outline, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              if (reduceMotion) {
                return _buildDot(palette.brand, 1.0);
              }

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final phase = (index * 0.25);
                  final progress = (_controller.value - phase) % 1.0;
                  final scale = 0.6 + 0.5 * (1.0 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0);
                  return _buildDot(palette.brand, scale);
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
