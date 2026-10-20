import 'package:flutter/material.dart';

/// Renders the emoji icon representing a learning reason option.
///
/// Follows AGENTS.md §3: under 100 lines, const constructor, scalable glyph.
class ReasonIcon extends StatelessWidget {
  const ReasonIcon({super.key, required this.emoji, this.size = 22.0});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(emoji, style: TextStyle(fontSize: size, height: 1.1));
  }
}
