import 'package:flutter/material.dart';
import '../../../../../core/design_system/icon_tile.dart';
import '../../../../../core/theme/app_palette.dart';

/// Small circular peach avatar tile displaying the character's scene emoji.
///
/// Follows AGENTS.md §3 & §8:
/// - Reuses core [IconTile.emoji] with peach/coralTint background
/// - Circular 44dp shape matching the design screenshot
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.emoji,
    this.size = 44.0,
  });

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IconTile(
      size: size,
      borderRadius: size / 2,
      backgroundColor: palette.coralTint,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 22.0),
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}
