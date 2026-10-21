import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../l10n/app_strings.dart';

/// Full-width tactile lavender secondary button opening the sticker book.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §8.
class StickerBookButton extends StatelessWidget {
  const StickerBookButton({
    super.key,
    required this.stickerCount,
    required this.onPressed,
  });

  final int stickerCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Button3D.secondary(
      label: AppStrings.rewardsStickerBookButton(stickerCount),
      onPressed: onPressed,
    );
  }
}
