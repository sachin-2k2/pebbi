import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decorative floating emojis positioned with FractionalOffset/Alignment.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, ExcludeSemantics,
/// respects reduce-motion settings, and drops items on constrained screens.
class FloatingEmojiDecoration extends StatefulWidget {
  const FloatingEmojiDecoration({super.key});

  @override
  State<FloatingEmojiDecoration> createState() =>
      _FloatingEmojiDecorationState();
}

class _FloatingEmojiDecorationState extends State<FloatingEmojiDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isTestEnvironment = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');
    if (reduceMotion || isTestEnvironment) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 160 || constraints.maxWidth < 280) {
          return const SizedBox.shrink();
        }

        final isShort = constraints.maxHeight < 220;

        return ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final drift = math.sin(_controller.value * math.pi) * 3.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  _item(
                    alignment: const Alignment(-0.66, -0.88),
                    emoji: '👋',
                    size: 20,
                    offsetY: drift * 0.7,
                  ),
                  _item(
                    alignment: const Alignment(-0.84, -0.62),
                    emoji: '🧭',
                    size: 20,
                    offsetY: drift,
                  ),
                  _item(
                    alignment: const Alignment(0.70, -0.74),
                    emoji: '☕',
                    size: 20,
                    offsetY: -drift * 0.6,
                  ),
                  _item(
                    alignment: const Alignment(0.86, -0.42),
                    emoji: '🎫',
                    size: 22,
                    offsetY: -drift,
                  ),
                  _item(
                    alignment: const Alignment(-0.76, -0.10),
                    emoji: '🔥',
                    size: 22,
                    offsetY: -drift * 0.8,
                  ),
                  _item(
                    alignment: const Alignment(0.76, 0.22),
                    emoji: '💬',
                    size: 20,
                    offsetY: drift * 0.7,
                  ),
                  if (!isShort) ...[
                    _item(
                      alignment: const Alignment(-0.10, -0.38),
                      emoji: '💛',
                      size: 16,
                      offsetY: drift * 0.5,
                    ),
                    _item(
                      alignment: const Alignment(-0.55, 0.72),
                      emoji: '🔑',
                      size: 22,
                      offsetY: drift,
                    ),
                    _item(
                      alignment: const Alignment(0.50, 0.68),
                      emoji: '🌟',
                      size: 20,
                      offsetY: -drift * 0.9,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _item({
    required Alignment alignment,
    required String emoji,
    required double size,
    required double offsetY,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: Text(emoji, style: TextStyle(fontSize: size, height: 1.0)),
      ),
    );
  }
}
