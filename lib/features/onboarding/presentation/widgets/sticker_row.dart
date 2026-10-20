import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/sticker_option.dart';
import 'sticker_card.dart';

/// Row of 3 equal-height starter sticker cards.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, build under 40 lines,
/// equal heights via [IntrinsicHeight], single-selection semantics.
class StickerRow extends StatelessWidget {
  const StickerRow({
    super.key,
    required this.selectedStickerId,
    required this.onSelectSticker,
  });

  final String? selectedStickerId;
  final ValueChanged<String> onSelectSticker;

  @override
  Widget build(BuildContext context) {
    final stickers = StickerOption.options;

    return Semantics(
      label: 'Your first sticker',
      container: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < stickers.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StickerCard(
                  sticker: stickers[i],
                  isSelected: stickers[i].id == selectedStickerId,
                  index: i + 1,
                  total: stickers.length,
                  onTap: () => onSelectSticker(stickers[i].id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
